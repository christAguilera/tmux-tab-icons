#!/usr/bin/env bats

load test_helper

setup() {
  load_modules
}

@test "returns the source variable when there are no rules" {
  run build_format window_name "" < /dev/null
  [ "$output" = '#{window_name}' ]
}

@test "wraps the source variable with one substitution" {
  run build_format window_name "" <<< "nvim${SEP}X"
  [ "$output" = '#{s~nvim~X~:#{window_name}}' ]
}

@test "nests rules with the first one innermost" {
  run build_format window_name "" <<< "a${SEP}1"$'\n'"b${SEP}2"
  [ "$output" = '#{s~b~2~:#{s~a~1~:#{window_name}}}' ]
}

@test "applies flags and custom source variables" {
  run build_format pane_current_command i <<< "nvim${SEP}X"
  [ "$output" = '#{s~nvim~X~i:#{pane_current_command}}' ]
}

@test "uses another separator when the rule contains the default one" {
  run build_format window_name "" <<< "a~b${SEP}X"
  [ "$output" = '#{s|a~b|X|:#{window_name}}' ]
}

@test "escapes pattern and glyph" {
  run build_format window_name "" <<< "a,b${SEP}#"
  [ "$output" = '#{s~a#,b~##~:#{window_name}}' ]
}

@test "skips rules with unsupported characters and warns" {
  run --separate-stderr build_format window_name "" <<< "a:b${SEP}X"
  [ "$output" = '#{window_name}' ]
  [[ "$stderr" == *"skipping 'a:b'"* ]]
}
