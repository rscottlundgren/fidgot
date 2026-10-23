//go:build slow

package tests

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"
	"time"
)

// Slow tests (tests/run.sh --slow): each language module against its fixture
// in testdata/, and lua-language-server over the Neovim config.

var languages = []struct {
	fixture string // folder in testdata/
	file    string // file to open, in that folder
	client  string // language server that should attach
	diag    string // text the expected diagnostic contains; empty for none
	save    bool   // save first: the diagnostic comes from a linter run on save
	project bool   // git init the copy: jdtls only type-checks inside a project
}{
	{fixture: "go", file: "main.go", client: "gopls", diag: "declared and not used: x"},
	{fixture: "typescript", file: "index.ts", client: "vtsls", diag: "Type 'string' is not assignable to type 'number'"},
	{fixture: "python", file: "main.py", client: "basedpyright", diag: "is not assignable to declared type"},
	{fixture: "shell", file: "script.sh", client: "bashls", diag: "Double quote to prevent globbing"},
	{fixture: "latex", file: "doc.tex", client: "texlab", diag: "Command terminated with space", save: true},
	{fixture: "java", file: "Main.java", client: "jdtls", diag: "Type mismatch: cannot convert from String to int", project: true},
	{fixture: "css", file: "style.css", client: "cssls", diag: "Unknown property: 'colr'"},
	{fixture: "json", file: "package.json", client: "jsonls", diag: "Incorrect type. Expected \"string\""},
	{fixture: "toml", file: "config.toml", client: "taplo"},
	{fixture: "rust", file: "src/main.rs", client: "rust_analyzer", diag: "mismatched types"},
	{fixture: "zig", file: "main.zig", client: "zls", diag: "unused local constant"},
}

// How long to wait for a language server to attach, and then for its
// diagnostic; jdtls and rust-analyzer take the longest (a few seconds).
const languageWait = 60 * time.Second

func TestLanguages(t *testing.T) {
	for _, lang := range languages {
		t.Run(lang.fixture, func(t *testing.T) {
			t.Parallel()
			// Work on a copy, so build output and lockfiles stay out of the repo
			dir := filepath.Join(t.TempDir(), lang.fixture)
			if err := os.CopyFS(dir, os.DirFS(filepath.Join(root, "tests/testdata", lang.fixture))); err != nil {
				t.Fatal(err)
			}
			if lang.project {
				mustSucceed(t, cmd{name: "git", args: []string{"init", "--quiet", dir}})
			}
			file := filepath.Join(dir, lang.file)
			env := []string{
				"FIDGOT_FILE=" + file,
				"FIDGOT_CLIENT=" + lang.client,
				"FIDGOT_FORMATTED=" + file + ".formatted",
				fmt.Sprintf("FIDGOT_WAIT=%d", languageWait.Milliseconds()),
			}
			if lang.diag != "" {
				env = append(env, "FIDGOT_DIAG="+lang.diag)
			}
			if lang.save {
				env = append(env, "FIDGOT_SAVE=1")
			}
			nvim(t, "language.lua", 2*languageWait+30*time.Second, env...)
		})
	}
}

func TestLuaLanguageServer(t *testing.T) {
	home, _ := os.UserHomeDir()
	luals := filepath.Join(home, ".local/share/nvim/mason/bin/lua-language-server")
	if _, err := os.Stat(luals); err != nil {
		t.Fatalf("lua-language-server isn't installed (Mason installs it when Neovim starts): %v", err)
	}
	mustSucceed(t, cmd{
		name:    luals,
		args:    []string{"--check=" + filepath.Join(root, "profiles/common/nvim"), "--checklevel=Warning", "--logpath=" + t.TempDir()},
		timeout: 3 * time.Minute,
	})
}
