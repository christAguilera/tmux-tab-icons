#!/usr/bin/env bash

# Prints the regex that matches a rule's regex wrapped in colons (e.g. `:(n?vim):`).
placeholder_pattern() {
  printf '%s%s%s' "$TAB_ICONS_PLACEHOLDER_PREFIX" "$1" "$TAB_ICONS_PLACEHOLDER_SUFFIX"
}

# Reads parsed records from stdin and prints a tmux format that replaces every placeholder,
# in order, in the given format variable. The first rule ends up as the innermost substitution.
build_format() {
  local source_variable="$1"
  local flags="$2"
  local format="#{${source_variable}}"
  local regex glyph pattern separator
  while IFS="$TAB_ICONS_FIELD_SEPARATOR" read -r regex glyph; do
    pattern="$(escape_format_argument "$(placeholder_pattern "$regex")")"
    glyph="$(escape_format_argument "$glyph")"
    if ! separator="$(pick_separator "$pattern" "$glyph")"; then
      warn "skipping '${regex}': it contains every separator in '${TAB_ICONS_SEPARATOR_CANDIDATES}'"
      continue
    fi
    format="#{s${separator}${pattern}${separator}${glyph}${separator}${flags}:${format}}"
  done
  printf '%s\n' "$format"
}
