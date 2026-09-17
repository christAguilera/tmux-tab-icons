#!/usr/bin/env bats

load test_helper

setup() {
  load_modules
}

@test "returns the source variable when there are no rules" {
  run build_format window_name "" < /dev/null
  [ "$output" = '#{window_name}' ]
}

@test "groups the regex between colons, expressed as formats" {
  run build_format window_name "" <<< "vim${SEP}X"
  [ "$output" = '#{s~#{a:58}(vim)#{a:58}~X~:#{window_name}}' ]
}

@test "nests rules with the first one innermost" {
  run build_format window_name "" <<< "a${SEP}1"$'\n'"b${SEP}2"
  [ "$output" = '#{s~#{a:58}(b)#{a:58}~2~:#{s~#{a:58}(a)#{a:58}~1~:#{window_name}}}' ]
}

@test "applies flags and custom source variables" {
  run build_format pane_current_command i <<< "vim${SEP}X"
  [ "$output" = '#{s~#{a:58}(vim)#{a:58}~X~i:#{pane_current_command}}' ]
}

@test "uses another separator when the rule contains the default one" {
  run build_format window_name "" <<< "a~b${SEP}X"
  [ "$output" = '#{s|#{a:58}(a~b)#{a:58}|X|:#{window_name}}' ]
}

@test "escapes the regex" {
  run build_format window_name "" <<< "a,b:c${SEP}X"
  [ "$output" = '#{s~#{a:58}(a#,b#{a:58}c)#{a:58}~X~:#{window_name}}' ]
}

@test "escapes the glyph" {
  run build_format window_name "" <<< "a${SEP}#,:"
  [ "$output" = '#{s~#{a:58}(a)#{a:58}~###,#{a:58}~:#{window_name}}' ]
}

@test "skips rules whose glyph contains every separator and warns" {
  run --separate-stderr build_format window_name "" <<< "a${SEP}${TAB_ICONS_SEPARATOR_CANDIDATES}"
  [ "$output" = '#{window_name}' ]
  [[ "$stderr" == *"skipping 'a'"* ]]
}
