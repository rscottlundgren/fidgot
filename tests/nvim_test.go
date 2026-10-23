package tests

import (
	"os"
	"path/filepath"
	"testing"
	"time"
)

// nvim runs one of the Lua scripts in tests/nvim/ in headless Neovim with the
// repo's config (not whatever ~/.config/nvim links to), and fails the test if
// the script reports a failure. Plugins come from the usual data directory;
// state (logs, undo) and cache (jdtls workspaces) go to a temp dir. PATH is
// the terminal's, so Neovim finds the same tools as when started from a
// shell. The script can use FIDGOT_TMP, a temp dir; extra is added to the
// environment.
func nvim(t *testing.T, script string, timeout time.Duration, extra ...string) {
	t.Helper()
	need(t, "nvim")
	path, err := terminalPath()
	if err != nil {
		t.Fatalf("getting a login shell's PATH: %v", err)
	}
	tmp := t.TempDir()
	config := filepath.Join(tmp, "config")
	if err := os.MkdirAll(config, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.Symlink(filepath.Join(root, "profiles/common/nvim"), filepath.Join(config, "nvim")); err != nil {
		t.Fatal(err)
	}
	work := filepath.Join(tmp, "work")
	if err := os.Mkdir(work, 0o755); err != nil {
		t.Fatal(err)
	}

	env := append(os.Environ(),
		"XDG_CONFIG_HOME="+config,
		"XDG_STATE_HOME="+filepath.Join(tmp, "state"),
		"XDG_CACHE_HOME="+filepath.Join(tmp, "cache"),
		"PATH="+path,
		"FIDGOT_TESTS="+filepath.Join(root, "tests"),
		"FIDGOT_TMP="+work,
	)
	r := run(t, cmd{
		name:    "nvim",
		args:    []string{"--headless", "-i", "NONE", "-n", "-c", "luafile " + filepath.Join(root, "tests/nvim", script)},
		env:     append(env, extra...),
		timeout: timeout,
	})
	if r.code != 0 {
		t.Errorf("%s: exit %d\n%s%s", script, r.code, r.stdout, r.stderr)
	}
}

func TestNeovimStartup(t *testing.T) {
	nvim(t, "startup.lua", 30*time.Second)
}

func TestNeovimHealth(t *testing.T) {
	nvim(t, "health.lua", 30*time.Second)
}

func TestNeovimSpell(t *testing.T) {
	nvim(t, "spell.lua", 30*time.Second)
}

func TestNeovimFormatOnSave(t *testing.T) {
	need(t, "stylua", "prettier")
	stylua, err := os.ReadFile(filepath.Join(root, "profiles/common/nvim/.stylua.toml"))
	if err != nil {
		t.Fatal(err)
	}
	// format_on_save.lua writes its files to FIDGOT_TMP; stylua finds this copy
	// of the config's settings there
	tmp := t.TempDir()
	if err := os.WriteFile(filepath.Join(tmp, ".stylua.toml"), stylua, 0o644); err != nil {
		t.Fatal(err)
	}
	nvim(t, "format_on_save.lua", 30*time.Second, "FIDGOT_TMP="+tmp)
}
