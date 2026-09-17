#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$CURRENT_DIR/scripts"

# shellcheck source=scripts/constants.sh
source "$SCRIPTS_DIR/constants.sh"
# shellcheck source=scripts/logging.sh
source "$SCRIPTS_DIR/logging.sh"
# shellcheck source=scripts/strings.sh
source "$SCRIPTS_DIR/strings.sh"
# shellcheck source=scripts/tmux_options.sh
source "$SCRIPTS_DIR/tmux_options.sh"
# shellcheck source=scripts/mappings_parser.sh
source "$SCRIPTS_DIR/mappings_parser.sh"
# shellcheck source=scripts/format_escape.sh
source "$SCRIPTS_DIR/format_escape.sh"
# shellcheck source=scripts/format_builder.sh
source "$SCRIPTS_DIR/format_builder.sh"

expand_home_path() {
  printf '%s' "${1/#\~/$HOME}"
}

# Shows all collected warnings in a single tmux message.
report_warnings() {
  local warnings_file="$1"
  local message="" warning
  while IFS= read -r warning; do
    message="${message:+${message}${TAB_ICONS_MESSAGE_JOINER}}${warning}"
  done < "$warnings_file"
  if [ -n "$message" ]; then
    display_tmux_message "$message"
  fi
}

main() {
  local mappings_file source_variable flags format warnings_file
  mappings_file="$(expand_home_path "$(get_tmux_option "$TAB_ICONS_OPTION_FILE" "$TAB_ICONS_DEFAULT_FILE")")"
  source_variable="$(get_tmux_option "$TAB_ICONS_OPTION_SOURCE" "$TAB_ICONS_DEFAULT_SOURCE")"
  flags="$(get_tmux_option "$TAB_ICONS_OPTION_FLAGS" "$TAB_ICONS_DEFAULT_FLAGS")"

  warnings_file="$(mktemp)"
  trap 'rm -f "$warnings_file"' EXIT

  if [ -r "$mappings_file" ]; then
    format="$(parse_mappings < "$mappings_file" 2>"$warnings_file" | build_format "$source_variable" "$flags" 2>>"$warnings_file")"
  else
    warn "mappings file not found: ${mappings_file}" 2>"$warnings_file"
    format="$(build_format "$source_variable" "$flags" < /dev/null)"
  fi

  set_tmux_option "$TAB_ICONS_OPTION_OUTPUT" "$format"
  report_warnings "$warnings_file"
}

main
