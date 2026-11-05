package tests

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
	"unicode/utf8"
)

// The linters and formatters the repo's files are kept clean with.

func TestShellScripts(t *testing.T) {
	need(t, "shellcheck", "shfmt")
	scripts := tracked(t, "*.sh")
	t.Run("shellcheck", func(t *testing.T) {
		// -s bash: every script is bash (CONVENTIONS.md), shebang or not
		mustSucceed(t, cmd{name: "shellcheck", args: append([]string{"-s", "bash"}, scripts...)})
	})
	t.Run("shfmt", func(t *testing.T) {
		// No -i: shfmt reads the repo's .editorconfig
		mustSucceed(t, cmd{name: "shfmt", args: append([]string{"-d"}, scripts...)})
	})
}

// The zsh config: zshrc, zprofile and the functions/*.zsh files it sources.
func zshFiles(t *testing.T) []string {
	t.Helper()
	return tracked(t, "zshrc", "zprofile", "*.zsh")
}

func TestZshSyntax(t *testing.T) {
	need(t, "zsh")
	for _, f := range zshFiles(t) {
		mustSucceed(t, cmd{name: "zsh", args: []string{"-n", f}})
	}
}

// shellcheck doesn't know zsh, so the zsh config is written in syntax bash also
// parses and says `# shellcheck shell=bash`; this keeps it that way, matching
// what bash-language-server shows in the editor.
func TestZshShellcheck(t *testing.T) {
	need(t, "shellcheck")
	mustSucceed(t, cmd{name: "shellcheck", args: zshFiles(t)})
}

// shellFiles is every shell file CONVENTIONS.md covers: the scripts and the
// zsh config.
func shellFiles(t *testing.T) []string {
	t.Helper()
	return append(tracked(t, "*.sh"), zshFiles(t)...)
}

// Shell files stay within 80 columns (CONVENTIONS.md). A line with a URL is
// the one exception: a URL can't be split.
func TestShellLineLength(t *testing.T) {
	for _, f := range shellFiles(t) {
		for i, line := range lines(t, f) {
			if n := utf8.RuneCountInString(line); n > 80 && !strings.Contains(line, "://") {
				t.Errorf("%s:%d is %d columns, over 80", f, i+1, n)
			}
		}
	}
}

// Section rules run to 80 columns, subsection rules to 60 (CONVENTIONS.md).
func TestShellRules(t *testing.T) {
	for _, f := range shellFiles(t) {
		for i, line := range lines(t, f) {
			want := 0
			switch {
			case strings.HasPrefix(line, "# ------ "):
				want = 60
			case strings.HasPrefix(line, "# --- "):
				want = 80
			}
			if n := utf8.RuneCountInString(line); want != 0 && n != want {
				t.Errorf("%s:%d: rule is %d columns, want %d", f, i+1, n, want)
			}
		}
	}
}

// lines returns a repo file's lines.
func lines(t *testing.T, f string) []string {
	t.Helper()
	data, err := os.ReadFile(filepath.Join(root, f))
	if err != nil {
		t.Fatal(err)
	}
	return strings.Split(string(data), "\n")
}

func TestLuaFormatting(t *testing.T) {
	need(t, "stylua")
	// tests/nvim/.stylua.toml links to the config's, so both format alike
	mustSucceed(t, cmd{name: "stylua", args: []string{"--check", "profiles/common/nvim", "tests/nvim"}})
}

func TestGoFormatting(t *testing.T) {
	need(t, "gofmt")
	r := mustSucceed(t, cmd{name: "gofmt", args: append([]string{"-l"}, tracked(t, "*.go")...)})
	if out := strings.TrimSpace(r.stdout); out != "" {
		t.Errorf("not gofmt-formatted (run gofmt -w tests):\n%s", out)
	}
}

func TestDocs(t *testing.T) {
	need(t, "prettier", "markdownlint-cli2")
	md := tracked(t, "*.md")
	t.Run("prettier", func(t *testing.T) {
		files := append(tracked(t, "*.json", "*.jsonc", ".prettierrc"), md...)
		mustSucceed(t, cmd{name: "prettier", args: append([]string{"--check"}, files...)})
	})
	t.Run("markdownlint", func(t *testing.T) {
		mustSucceed(t, cmd{name: "markdownlint-cli2", args: md})
	})
}
