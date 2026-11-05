package tests

import (
	"os"
	"path/filepath"
	"slices"
	"strings"
	"testing"
)

// zshHome returns a HOME with the tracked zshrc and zprofile linked in, as
// install.sh links them.
func zshHome(t *testing.T) string {
	t.Helper()
	home := t.TempDir()
	for _, name := range []string{"zshrc", "zprofile"} {
		if err := os.Symlink(filepath.Join(root, "profiles/common/zsh", name), filepath.Join(home, "."+name)); err != nil {
			t.Fatal(err)
		}
	}
	return home
}

// loginShell runs a command in an interactive login zsh with the tracked
// config, the way a new terminal starts.
func loginShell(t *testing.T, home, command string) result {
	t.Helper()
	need(t, "zsh")
	return mustSucceed(t, cmd{name: "zsh", args: []string{"-l", "-i", "-c", command}, env: baseEnv(home)})
}

func TestZshStartsCleanly(t *testing.T) {
	home := zshHome(t)
	r := loginShell(t, home, "true")
	if r.stderr != "" {
		t.Errorf("startup wrote to stderr:\n%s", r.stderr)
	}
}

func TestZshPath(t *testing.T) {
	home := zshHome(t)
	r := loginShell(t, home, `print -r -- "$PATH"`)
	path := strings.Split(strings.TrimSpace(r.stdout), ":")

	want := []string{filepath.Join(home, "go/bin"), filepath.Join(home, ".local/bin")}
	// Homebrew's, and the tools zshrc adds only when they're installed
	for _, dir := range []string{"/opt/homebrew/bin", "/opt/homebrew/opt/rustup/bin", "/opt/homebrew/opt/openjdk/bin"} {
		if _, err := os.Stat(dir); err == nil {
			want = append(want, dir)
		}
	}
	for _, dir := range want {
		if !slices.Contains(path, dir) {
			t.Errorf("PATH is missing %s\nPATH: %s", dir, r.stdout)
		}
	}
}

func TestZshrcLocal(t *testing.T) {
	home := zshHome(t)
	check := `print -r -- "local=${FIDGOT_LOCAL:-no}"`
	if got := loginShell(t, home, check).stdout; !strings.Contains(got, "local=no") {
		t.Errorf("without ~/.zshrc.local: %s", got)
	}

	if err := os.WriteFile(filepath.Join(home, ".zshrc.local"), []byte("export FIDGOT_LOCAL=yes\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	if got := loginShell(t, home, check).stdout; !strings.Contains(got, "local=yes") {
		t.Errorf("~/.zshrc.local wasn't loaded: %s", got)
	}
}

func TestZshEls(t *testing.T) {
	home := zshHome(t)
	// A stand-in eza that prints its arguments, first on PATH (zshrc adds
	// ~/.local/bin)
	bin := filepath.Join(home, ".local/bin")
	if err := os.MkdirAll(bin, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(bin, "eza"), []byte("#!/bin/sh\necho \"eza $*\"\n"), 0o755); err != nil {
		t.Fatal(err)
	}
	want := "eza --group-directories-first --icons --git --time-style=relative -la"
	if got := strings.TrimSpace(loginShell(t, home, "els -la").stdout); got != want {
		t.Errorf("els -la ran %q, want %q", got, want)
	}
}

func TestZshBrewFunctions(t *testing.T) {
	home := zshHome(t)
	// A stand-in brew, first on PATH (zshrc adds ~/.local/bin), that logs each
	// call and fails the subcommand named in $BREW_FAIL
	bin := filepath.Join(home, ".local/bin")
	if err := os.MkdirAll(bin, 0o755); err != nil {
		t.Fatal(err)
	}
	stub := "#!/bin/sh\necho \"brew $*\" >>\"$HOME/brew.log\"\n[ \"$1\" != \"$BREW_FAIL\" ]\n"
	if err := os.WriteFile(filepath.Join(bin, "brew"), []byte(stub), 0o755); err != nil {
		t.Fatal(err)
	}

	tests := []struct {
		command, fail string
		code          int
		calls         []string
	}{
		{"brew-in wget jq", "", 0, []string{"doctor", "update", "upgrade --greedy", "install wget jq", "cleanup", "doctor"}},
		{"brew-un wget", "", 0, []string{"doctor", "update", "upgrade --greedy", "uninstall wget", "cleanup", "doctor"}},
		{"brew-up", "", 0, []string{"doctor", "update", "upgrade --greedy", "cleanup", "doctor"}},
		{"brew-in", "", 2, nil},
		{"brew-un", "", 2, nil},
		{"brew-in wget", "update", 1, []string{"doctor", "update"}},
		{"brew-in wget", "install", 1, []string{"doctor", "update", "upgrade --greedy", "install wget"}},
		{"brew-in wget", "upgrade", 0, []string{"doctor", "update", "upgrade --greedy", "install wget", "cleanup", "doctor"}},
		{"brew-up", "doctor", 0, []string{"doctor", "update", "upgrade --greedy", "cleanup", "doctor"}},
	}
	for _, tt := range tests {
		t.Run(tt.command+"/fail="+tt.fail, func(t *testing.T) {
			log := filepath.Join(home, "brew.log")
			os.Remove(log)
			env := append(baseEnv(home), "BREW_FAIL="+tt.fail)
			r := run(t, cmd{name: "zsh", args: []string{"-l", "-i", "-c", tt.command}, env: env})
			if r.code != tt.code {
				t.Errorf("exit %d, want %d\nstderr:\n%s", r.code, tt.code, r.stderr)
			}
			var calls []string
			if data, err := os.ReadFile(log); err == nil {
				for _, line := range strings.Split(strings.TrimSpace(string(data)), "\n") {
					calls = append(calls, strings.TrimPrefix(line, "brew "))
				}
			}
			if !slices.Equal(calls, tt.calls) {
				t.Errorf("brew calls %q, want %q", calls, tt.calls)
			}
		})
	}
}
