#!/usr/bin/env bats

load test_helper

setup() {
  load_modules
}

@test "parses rules, ignoring comments and blank lines" {
  run parse_mappings < "$FIXTURES_DIR/icons.conf"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" = "n?vim${SEP}${GLYPH_VIM}" ]
  [ "${lines[1]}" = "zsh|bash${SEP}${GLYPH_SHELL}" ]
}

@test "keeps spaces inside the regex and uses the last token as glyph" {
  run parse_mappings < "$FIXTURES_DIR/icons.conf"
  [ "${lines[2]}" = "docker compose${SEP}${GLYPH_DOCKER}" ]
}

@test "reads the last line without a trailing newline" {
  run parse_mappings < "$FIXTURES_DIR/no_trailing_newline.conf"
  [ "$output" = "node${SEP}${GLYPH_NODE}" ]
}

@test "warns and skips lines without a glyph" {
  run --separate-stderr parse_mappings <<< $'vim\nzsh '"$GLYPH_SHELL"
  [ "$output" = "zsh${SEP}${GLYPH_SHELL}" ]
  [[ "$stderr" == *"line 1:"* ]]
}
