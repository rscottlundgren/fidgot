package tests

import (
	"path/filepath"
	"strings"
	"testing"
)

// Each GitHub alias in the tracked SSH config resolves to github.com as git,
// offering only that account's key. ssh -G prints the settings without
// connecting.
func TestSSHGitHubAliases(t *testing.T) {
	need(t, "ssh")
	config := filepath.Join(root, "profiles/common/ssh/config")
	for _, account := range []string{"rscottlundgren", "studioelif"} {
		t.Run(account, func(t *testing.T) {
			r := mustSucceed(t, cmd{name: "ssh", args: []string{"-G", "-F", config, "github.com-" + account}})
			settings := map[string][]string{}
			for _, line := range strings.Split(r.stdout, "\n") {
				if key, value, ok := strings.Cut(line, " "); ok {
					settings[key] = append(settings[key], value)
				}
			}
			for key, want := range map[string]string{
				"hostname":       "github.com",
				"user":           "git",
				"identitiesonly": "yes",
				"identityfile":   "/.ssh/github_" + account + "_auth_id_ed25519.pub",
			} {
				got := strings.Join(settings[key], " ")
				if key == "identityfile" && !strings.HasSuffix(got, want) || key != "identityfile" && got != want {
					t.Errorf("%s = %q, want %q", key, got, want)
				}
			}
			if agent := strings.Join(settings["identityagent"], " "); !strings.Contains(agent, "1password") {
				t.Errorf("identityagent = %q, want 1Password's agent", agent)
			}
		})
	}
}
