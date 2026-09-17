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
  tmux_test -f /dev/null new-session -d -s test -n ':vim: main.go vim'
  tmux_test new-window -d -t test: -n ':zsh::zsh:'
  tmux_test new-window -d -t test: -n 'a,b}c#d:vim'
  tmux_test new-window -d -t test: -n ':VIM:'
  tmux_test new-window -d -t test: -n ':nvim: :bash: :docker compose: :xvim:'
  tmux_test set-option -g @tab_icons_file "$FIXTURES_DIR/icons.conf"
}

teardown() {
  tmux_test kill-server 2> /dev/null || true
}

run_plugin() {
  tmux_test run-shell "$PROJECT_ROOT/tab_icons.tmux"
}

@test "replaces placeholders whose whole text matches the regex" {
  run_plugin
  [ "$(render test:4)" = "${GLYPH_VIM} ${GLYPH_SHELL} ${GLYPH_DOCKER} :xvim:" ]
}

@test "replaces only text wrapped in colons with glyphs" {
  run_plugin
  [ "$(render test:0)" = "${GLYPH_VIM} main.go vim" ]
  [ "$(render test:1)" = "${GLYPH_SHELL}${GLYPH_SHELL}" ]
}

@test "keeps names without placeholders, including format metacharacters" {
  run_plugin
  [ "$(render test:2)" = "a,b}c#d:vim" ]
}

@test "renders escaped metacharacters from glyphs literally" {
  local mappings="$BATS_TEST_TMPDIR/icons.conf"
  printf '%s\n' 'vim|a:b #x,}:' > "$mappings"
  tmux_test set-option -g @tab_icons_file "$mappings"
  run_plugin
  [ "$(render test:0)" = "#x,}: main.go vim" ]
}

@test "is case-sensitive by default and honours case-insensitive flags" {
  run_plugin
  [ "$(render test:3)" = ":VIM:" ]
  tmux_test set-option -g @tab_icons_flags i
  run_plugin
  [ "$(render test:3)" = "${GLYPH_VIM}" ]
}

@test "falls back to the plain name when the mappings file is missing" {
  tmux_test set-option -g @tab_icons_file "$BATS_TEST_TMPDIR/missing.conf"
  run_plugin
  [ "$(render test:0)" = ":vim: main.go vim" ]
}
