#!/usr/bin/env bash

# Reads parsed records from stdin and prints a tmux format that applies every rule, in
# order, to the given format variable. The first rule ends up as the innermost substitution.
build_format() {
  local source_variable="$1"
  local flags="$2"
  local format="#{${source_variable}}"
  local pattern glyph separator
  while IFS="$TAB_ICONS_FIELD_SEPARATOR" read -r pattern glyph; do
    if has_unsupported_chars "${pattern}${glyph}"; then
      warn "skipping '${pattern}': '${TAB_ICONS_UNSUPPORTED_CHARS}' is not supported in tmux formats"
      continue
    fi
    if ! separator="$(pick_separator "$pattern" "$glyph")"; then
      warn "skipping '${pattern}': it contains every separator in '${TAB_ICONS_SEPARATOR_CANDIDATES}'"
      continue
    fi
    format="#{s${separator}$(escape_format_argument "$pattern")${separator}$(escape_format_argument "$glyph")${separator}${flags}:${format}}"
  done
  printf '%s\n' "$format"
}
