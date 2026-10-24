package tests

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

const toolsSetup = "./profiles/personal/tools/setup.sh"

func TestToolsSetupArguments(t *testing.T) {
	for _, tc := range []struct {
		name string
		args []string
		code int
		out  string
	}{
		{"unknown argument", []string{"--bogus"}, 2, ""},
		{"help", []string{"--help"}, 0, "Usage:"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			r := run(t, cmd{name: toolsSetup, args: tc.args, env: baseEnv(t.TempDir())})
			if r.code != tc.code {
				t.Errorf("exit %d, want %d\nstderr: %s", r.code, tc.code, r.stderr)
			}
			if !strings.Contains(r.stdout, tc.out) {
				t.Errorf("stdout doesn't contain %q:\n%s", tc.out, r.stdout)
			}
		})
	}
}

func TestToolsSetupDryRunDoesntClone(t *testing.T) {
	need(t, "git", "go")
	tmp := t.TempDir()
	repos := filepath.Join(tmp, "repos")
	env := append(baseEnv(tmp), "PATH="+os.Getenv("PATH"),
		"FIDGOT_REPOS_DIR="+repos,
		// A local "remote", so the dry run doesn't check for a gh sign-in
		"FIDGOT_REMOTE_BASE="+filepath.Join(tmp, "remotes"))
	r := mustSucceed(t, cmd{name: toolsSetup, args: []string{"--dry-run"}, env: env})

	if _, err := os.Stat(repos); !os.IsNotExist(err) {
		t.Errorf("dry run created %s", repos)
	}
	for _, want := range []string{
		"would run: git clone --quiet " + filepath.Join(tmp, "remotes", "fidgot-personal.git"),
		"go install: skipped",
		"check.sh: skipped",
	} {
		if !strings.Contains(r.stdout, want) {
			t.Errorf("output doesn't contain %q:\n%s", want, r.stdout)
		}
	}
}

func TestToolsSetupRunsRepoCheck(t *testing.T) {
	need(t, "git", "go")
	tmp := t.TempDir()
	personal := filepath.Join(tmp, "repos", "fidgot-personal")
	if err := os.MkdirAll(filepath.Join(personal, ".git"), 0o755); err != nil {
		t.Fatal(err)
	}
	check := "#!/usr/bin/env bash\necho '    check ran'\n"
	if err := os.WriteFile(filepath.Join(personal, "check.sh"), []byte(check), 0o755); err != nil {
		t.Fatal(err)
	}
	env := append(baseEnv(tmp), "PATH="+os.Getenv("PATH"), "FIDGOT_REPOS_DIR="+filepath.Join(tmp, "repos"))
	r := mustSucceed(t, cmd{name: toolsSetup, args: []string{"--dry-run"}, env: env})

	for _, want := range []string{
		"would run: git -C " + personal + " pull --ff-only --quiet",
		"would run: go install ./...",
		"check ran",
	} {
		if !strings.Contains(r.stdout, want) {
			t.Errorf("output doesn't contain %q:\n%s", want, r.stdout)
		}
	}
}

func TestInstallSkipsToolsOnWorkProfile(t *testing.T) {
	tmp := t.TempDir()
	r := mustSucceed(t, cmd{name: "./install.sh",
		args: []string{"--profile", "work-example", "--dry-run", "--skip", "xcode,brew,links,toolchains,nvim,agents"},
		env:  baseEnv(tmp)})
	if strings.Contains(r.stdout, "fidgot-personal") {
		t.Errorf("work profile mentions fidgot-personal:\n%s", r.stdout)
	}
}
