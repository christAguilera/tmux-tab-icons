#!/usr/bin/env bash

# Escapes a value so tmux reads it literally as an argument of a format modifier.
# `#` must be escaped first so the escapes added afterwards are not doubled.
escape_format_argument() {
  local value="$1"
  local hash="#" comma="," closing_brace="}"
  value="${value//"$hash"/"$hash$hash"}"
  value="${value//"$comma"/"$hash$comma"}"
  value="${value//"$closing_brace"/"$hash$closing_brace"}"
  printf '%s' "$value"
}

has_unsupported_chars() {
  case "$1" in
    *["$TAB_ICONS_UNSUPPORTED_CHARS"]*) return 0 ;;
  esac
  return 1
}

# Prints the first separator candidate not contained in any of the given values.
pick_separator() {
  local candidates="$TAB_ICONS_SEPARATOR_CANDIDATES"
  local candidate value index
  for ((index = 0; index < ${#candidates}; index++)); do
    candidate="${candidates:index:1}"
    for value in "$@"; do
      case "$value" in
        *"$candidate"*) continue 2 ;;
      esac
    done
    printf '%s' "$candidate"
    return 0
  done
  return 1
}
