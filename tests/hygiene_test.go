package tests

import (
	"strings"
	"testing"
)

// The linters and formatters the repo's files are kept clean with.

func TestShellScripts(t *testing.T) {
	need(t, "shellcheck", "shfmt")
	scripts := tracked(t, "*.sh")
	t.Run("shellcheck", func(t *testing.T) {
		// -s bash: the life-ops files have no shebang (they're sourced)
		mustSucceed(t, cmd{name: "shellcheck", args: append([]string{"-s", "bash"}, scripts...)})
	})
	t.Run("shfmt", func(t *testing.T) {
		// No -i: shfmt reads the repo's .editorconfig
		mustSucceed(t, cmd{name: "shfmt", args: append([]string{"-d"}, scripts...)})
	})
}

func TestZshSyntax(t *testing.T) {
	need(t, "zsh")
	for _, f := range []string{"profiles/common/zsh/zshrc", "profiles/common/zsh/zprofile"} {
		mustSucceed(t, cmd{name: "zsh", args: []string{"-n", f}})
	}
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
