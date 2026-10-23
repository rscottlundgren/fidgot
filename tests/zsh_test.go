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
