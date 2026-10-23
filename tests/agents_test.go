package tests

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

const agentSetup = "./profiles/common/agents/setup.sh"

func TestAgentSetupArguments(t *testing.T) {
	testArguments(t, agentSetup)
}

func TestAgentSetupDryRunDoesntClone(t *testing.T) {
	need(t, "git", "go")
	tmp := t.TempDir()
	repos := filepath.Join(tmp, "repos")
	// setup.sh needs git and go; keep the PATH that has them
	env := append(baseEnv(tmp), "PATH="+os.Getenv("PATH"),
		"FIDGOT_REPOS_DIR="+repos,
		// A local "remote", so the dry run doesn't check for a gh sign-in
		"FIDGOT_REMOTE_BASE="+filepath.Join(tmp, "remotes"))
	r := mustSucceed(t, cmd{name: agentSetup, args: []string{"--profile", "personal", "--dry-run"}, env: env})

	if _, err := os.Stat(repos); !os.IsNotExist(err) {
		t.Errorf("dry run created %s", repos)
	}
	for _, want := range []string{
		"would run: git clone --quiet " + filepath.Join(tmp, "remotes", "agent-config.git"),
		"agent-install: skipped",
		"would run: git clone --quiet " + filepath.Join(tmp, "remotes", "context.git"),
	} {
		if !strings.Contains(r.stdout, want) {
			t.Errorf("output doesn't contain %q:\n%s", want, r.stdout)
		}
	}
}
