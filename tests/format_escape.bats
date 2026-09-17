#!/usr/bin/env bats

load test_helper

setup() {
  load_modules
}

@test "escapes hashes, commas and closing braces" {
  run escape_format_argument 'a#b,c}d'
  [ "$output" = 'a##b#,c#}d' ]
}

@test "does not double escapes introduced for other characters" {
  run escape_format_argument ',}'
  [ "$output" = '#,#}' ]
}

@test "leaves regex syntax untouched" {
  run escape_format_argument '^(a|b)[0-9]+{2}$'
  [ "$output" = '^(a|b)[0-9]+{2#}$' ]
}

@test "detects unsupported characters" {
  run has_unsupported_chars 'a:b'
  [ "$status" -eq 0 ]
  run ! has_unsupported_chars 'ab'
}

@test "picks the first separator absent from every value" {
  run pick_separator 'a~b' 'c|d'
  [ "$output" = "/" ]
}

@test "fails when every separator is used" {
  run pick_separator "$TAB_ICONS_SEPARATOR_CANDIDATES"
  [ "$status" -ne 0 ]
}
