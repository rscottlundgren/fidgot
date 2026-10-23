// Package tests checks fidgot from the outside: it runs the scripts, shells
// and editors the way a person would and looks at what they did. Run it with
// tests/run.sh (see tests/README.md).
package tests

import (
	"bytes"
	"context"
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"syscall"
	"testing"
	"time"
)

// root is the repo checkout these tests belong to (the parent of tests/).
var root = func() string {
	wd, err := os.Getwd()
	if err != nil {
		panic(err)
	}
	return filepath.Dir(wd)
}()

// result is what a command did.
type result struct {
	stdout, stderr string
	code           int
}

// cmd describes a command to run; dir defaults to the repo root, and env (if
// set) replaces the environment rather than adding to it.
type cmd struct {
	name    string
	args    []string
	dir     string
	env     []string
	timeout time.Duration
}

// run runs c and returns its output and exit code. It fails the test only if
// the command can't start or times out; a non-zero exit is for the caller to
// judge. The command gets its own process group, killed when it finishes or
// times out, so what it started in that group doesn't outlive it. (Neovim's
// language servers run detached; nvim/lib.lua kills those.)
func run(t *testing.T, c cmd) result {
	t.Helper()
	if c.timeout == 0 {
		c.timeout = 60 * time.Second
	}
	ctx, cancel := context.WithTimeout(context.Background(), c.timeout)
	defer cancel()

	x := exec.CommandContext(ctx, c.name, c.args...)
	x.Dir = c.dir
	if x.Dir == "" {
		x.Dir = root
	}
	if c.env != nil {
		x.Env = c.env
	}
	x.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
	x.Cancel = func() error { return syscall.Kill(-x.Process.Pid, syscall.SIGKILL) }
	var stdout, stderr bytes.Buffer
	x.Stdout, x.Stderr = &stdout, &stderr
	err := x.Run()
	if x.Process != nil {
		killGroup(x.Process.Pid)
	}

	r := result{stdout: stdout.String(), stderr: stderr.String()}
	var exit *exec.ExitError
	switch {
	case ctx.Err() != nil:
		t.Fatalf("%s timed out after %s\nstdout:\n%s\nstderr:\n%s", c.name, c.timeout, r.stdout, r.stderr)
	case errors.As(err, &exit):
		r.code = exit.ExitCode()
	case err != nil:
		t.Fatalf("running %s: %v", c.name, err)
	}
	return r
}

// killGroup kills a process group and waits (up to 5s) until it's gone: a
// killed process can still finish a call it was in, like creating a file in
// a temp dir the test is about to delete.
func killGroup(pgid int) {
	if syscall.Kill(-pgid, syscall.SIGKILL) != nil {
		return // already empty
	}
	for range 100 {
		if syscall.Kill(-pgid, 0) != nil {
			return
		}
		time.Sleep(50 * time.Millisecond)
	}
}

// mustSucceed runs c and fails the test unless it exits 0.
func mustSucceed(t *testing.T, c cmd) result {
	t.Helper()
	r := run(t, c)
	if r.code != 0 {
		t.Fatalf("%s %s: exit %d\nstdout:\n%s\nstderr:\n%s", c.name, strings.Join(c.args, " "), r.code, r.stdout, r.stderr)
	}
	return r
}

// need fails the test if a tool isn't on PATH; they all come from the
// Brewfiles, so a missing one means the machine isn't set up.
func need(t *testing.T, tools ...string) {
	t.Helper()
	for _, tool := range tools {
		if _, err := exec.LookPath(tool); err != nil {
			t.Fatalf("%s isn't on PATH (install the Brewfiles: install.sh --skip links,toolchains,nvim,agents)", tool)
		}
	}
}

// tracked lists the repo's files whose names match any of the patterns
// (filepath.Match against the base name), relative to the root: what git
// tracks, plus new files it doesn't ignore, so they're checked before they're
// committed. The
// language fixtures in tests/testdata/ are left out: they're unformatted and
// full of errors on purpose.
func tracked(t *testing.T, patterns ...string) []string {
	t.Helper()
	r := mustSucceed(t, cmd{name: "git", args: []string{"ls-files", "--cached", "--others", "--exclude-standard"}})
	var files []string
	for _, f := range strings.Split(strings.TrimSpace(r.stdout), "\n") {
		if strings.HasPrefix(f, "tests/testdata/") {
			continue
		}
		for _, p := range patterns {
			if ok, _ := filepath.Match(p, filepath.Base(f)); ok {
				files = append(files, f)
				break
			}
		}
	}
	if len(files) == 0 {
		t.Fatalf("no tracked files match %v", patterns)
	}
	return files
}

// terminalPath is the PATH an interactive login shell gets on this machine
// (with the real HOME), i.e. what an editor started from a terminal sees.
var terminalPath = sync.OnceValues(func() (string, error) {
	out, err := exec.Command("zsh", "-l", "-i", "-c", `print -r -- "$PATH"`).Output()
	return strings.TrimSpace(string(out)), err
})

// baseEnv is a minimal environment for running scripts as a fresh login
// would: the given HOME, the system PATH plus Homebrew's, and no inherited
// shell settings.
func baseEnv(home string) []string {
	return []string{
		"HOME=" + home,
		"PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
		"USER=" + os.Getenv("USER"),
		"TERM=xterm-256color",
		"LANG=en_US.UTF-8",
	}
}
