package tests

import (
	"io/fs"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"testing"
)

// links is what install.sh's links step should create: link location (under
// HOME) -> path in the repo.
var links = map[string]string{
	".zshrc":                "profiles/common/zsh/zshrc",
	".zprofile":             "profiles/common/zsh/zprofile",
	".config/starship.toml": "profiles/common/starship/starship.toml",
	".config/ghostty":       "profiles/common/ghostty",
	".config/zed":           "profiles/common/zed",
	".config/nvim":          "profiles/common/nvim",
	".gitconfig":            "profiles/common/git/gitconfig",
	".config/git/ignore":    "profiles/common/git/ignore",
	".config/gh/config.yml": "profiles/common/gh/config.yml",
	".ssh/config":           "profiles/common/ssh/config",
	".ssh/github_rscottlundgren_auth_id_ed25519.pub": "profiles/common/ssh/github_rscottlundgren_auth_id_ed25519.pub",
	".ssh/github_studioelif_auth_id_ed25519.pub":     "profiles/common/ssh/github_studioelif_auth_id_ed25519.pub",
}

// installLinks runs install.sh with every step but links skipped, in home.
func installLinks(t *testing.T, home string, extra ...string) result {
	t.Helper()
	args := append([]string{"--profile", "personal", "--skip", "xcode,brew,toolchains,nvim,agents"}, extra...)
	return mustSucceed(t, cmd{name: "./install.sh", args: args, env: baseEnv(home)})
}

// snapshot lists everything under dir: each path, and where it links to if
// it's a symlink.
func snapshot(t *testing.T, dir string) []string {
	t.Helper()
	var entries []string
	err := filepath.WalkDir(dir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		rel, _ := filepath.Rel(dir, path)
		if d.Type()&fs.ModeSymlink != 0 {
			target, _ := os.Readlink(path)
			rel += " -> " + target
		}
		entries = append(entries, rel)
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	return entries
}

func TestInstallCreatesLinks(t *testing.T) {
	home := t.TempDir()
	installLinks(t, home)
	for dest, src := range links {
		got, err := os.Readlink(filepath.Join(home, dest))
		if err != nil {
			t.Errorf("~/%s: not a link: %v", dest, err)
			continue
		}
		if want := filepath.Join(root, src); got != want {
			t.Errorf("~/%s -> %s, want %s", dest, got, want)
		}
	}
	if info, err := os.Stat(filepath.Join(home, ".ssh")); err != nil || info.Mode().Perm() != 0o700 {
		t.Errorf("~/.ssh should be mode 700: %v", err)
	}
	// Every link install.sh made is one this test knows about
	for _, entry := range snapshot(t, home) {
		if dest, _, ok := strings.Cut(entry, " -> "); ok {
			if _, known := links[dest]; !known {
				t.Errorf("install.sh made a link this test doesn't expect: ~/%s", entry)
			}
		}
	}
}

func TestInstallTwiceChangesNothing(t *testing.T) {
	home := t.TempDir()
	installLinks(t, home)
	before := snapshot(t, home)
	r := installLinks(t, home)
	if after := snapshot(t, home); !slices.Equal(before, after) {
		t.Errorf("second run changed HOME\nbefore: %v\nafter:  %v", before, after)
	}
	for _, line := range strings.Split(r.stdout, "\n") {
		if strings.Contains(line, "    link ") || strings.Contains(line, "    backup ") {
			t.Errorf("second run should only report ok, got: %s", line)
		}
	}
}

func TestInstallBacksUpFileInTheWay(t *testing.T) {
	home := t.TempDir()
	mine := filepath.Join(home, ".zshrc")
	if err := os.WriteFile(mine, []byte("# mine\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	installLinks(t, home)

	if _, err := os.Readlink(mine); err != nil {
		t.Errorf("~/.zshrc wasn't replaced by a link: %v", err)
	}
	backups, _ := filepath.Glob(mine + ".bak-*")
	if len(backups) != 1 {
		t.Fatalf("want one ~/.zshrc.bak-*, got %v", backups)
	}
	if b, _ := os.ReadFile(backups[0]); string(b) != "# mine\n" {
		t.Errorf("backup has %q, want the original file", b)
	}
}

func TestInstallDryRunChangesNothing(t *testing.T) {
	home := t.TempDir()
	r := installLinks(t, home, "--dry-run")
	if got := snapshot(t, home); !slices.Equal(got, []string{"."}) {
		t.Errorf("--dry-run created files: %v", got)
	}
	if !strings.Contains(r.stdout, "would run: ln -s") {
		t.Errorf("--dry-run should say what it would link:\n%s", r.stdout)
	}
}

func TestInstallArguments(t *testing.T) {
	testArguments(t, "./install.sh")
}

// testArguments checks a script's argument handling: a missing --profile or
// an unknown argument exits 2, and --help prints the usage.
func testArguments(t *testing.T, script string) {
	for _, tc := range []struct {
		name string
		args []string
		code int
		out  string
	}{
		{"no arguments", nil, 2, ""},
		{"unknown argument", []string{"--bogus"}, 2, ""},
		{"profile without value", []string{"--profile"}, 2, ""},
		{"help", []string{"--help"}, 0, "Usage:"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			r := run(t, cmd{name: script, args: tc.args, env: baseEnv(t.TempDir())})
			if r.code != tc.code {
				t.Errorf("exit %d, want %d\nstderr: %s", r.code, tc.code, r.stderr)
			}
			if !strings.Contains(r.stdout, tc.out) {
				t.Errorf("stdout doesn't contain %q:\n%s", tc.out, r.stdout)
			}
		})
	}
}
