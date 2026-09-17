#!/usr/bin/env bash

is_ignorable_line() {
  local line="$1"
  [ -z "$line" ] || [ "${line#"$TAB_ICONS_COMMENT_PREFIX"}" != "$line" ]
}

# Reads `<regex> <glyph>` rules from stdin and prints one record per valid rule:
# <regex><TAB_ICONS_FIELD_SEPARATOR><glyph>. The glyph is the last whitespace-separated
# token, so the regex may contain spaces. Malformed lines are reported and skipped.
parse_mappings() {
  local line trimmed regex glyph
  local line_number=0
  while IFS= read -r line || [ -n "$line" ]; do
    line_number=$((line_number + 1))
    trimmed="$(trim "$line")"
    if is_ignorable_line "$trimmed"; then
      continue
    fi
    glyph="${trimmed##*[[:space:]]}"
    regex="$(trim "${trimmed%"$glyph"}")"
    if [ -z "$regex" ]; then
      warn "line ${line_number}: expected '<regex> <glyph>', got '${trimmed}'"
      continue
    fi
    printf '%s%s%s\n' "$regex" "$TAB_ICONS_FIELD_SEPARATOR" "$glyph"
  done
}
