#!/usr/bin/env bats

# End-to-end tests against an isolated tmux server.

load test_helper

TMUX_SOCKET="tab-icons-test-$$"

tmux_test() {
  tmux -L "$TMUX_SOCKET" "$@"
}

render() {
  tmux_test display-message -p -t "$1" '#{E:@tab_icons_window_name}'
}

setup() {
  command -v tmux > /dev/null || skip "tmux is not installed"
  tmux_test -f /dev/null new-session -d -s test -n 'nvim main.go'
  tmux_test new-window -d -t test: -n 'zsh'
  tmux_test new-window -d -t test: -n 'a,b}c#d'
  tmux_test set-option -g @tab_icons_file "$FIXTURES_DIR/icons.conf"
}

teardown() {
  tmux_test kill-server 2> /dev/null || true
}

run_plugin() {
  tmux_test run-shell "$PROJECT_ROOT/tab_icons.tmux"
}

@test "replaces matching substrings with glyphs" {
  run_plugin
  [ "$(render test:0)" = "${GLYPH_VIM} main.go" ]
  [ "$(render test:1)" = "${GLYPH_SHELL}" ]
}

@test "keeps names without matches, including format metacharacters" {
  run_plugin
  [ "$(render test:2)" = "a,b}c#d" ]
}

@test "renders escaped metacharacters from rules literally" {
  local mappings="$BATS_TEST_TMPDIR/icons.conf"
  printf '%s\n' ',b} #' > "$mappings"
  tmux_test set-option -g @tab_icons_file "$mappings"
  run_plugin
  [ "$(render test:2)" = "a#c#d" ]
}

@test "honours case-insensitive flags" {
  local mappings="$BATS_TEST_TMPDIR/icons.conf"
  printf '%s\n' 'NVIM X' > "$mappings"
  tmux_test set-option -g @tab_icons_file "$mappings"
  tmux_test set-option -g @tab_icons_flags i
  run_plugin
  [ "$(render test:0)" = "X main.go" ]
}

@test "falls back to the plain name when the mappings file is missing" {
  tmux_test set-option -g @tab_icons_file "$BATS_TEST_TMPDIR/missing.conf"
  run_plugin
  [ "$(render test:0)" = "nvim main.go" ]
}
