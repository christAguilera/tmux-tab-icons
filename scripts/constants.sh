#!/usr/bin/env bash
# shellcheck disable=SC2034  # Constants are consumed by the scripts that source this file.

[ -n "${TAB_ICONS_CONSTANTS_LOADED:-}" ] && return
readonly TAB_ICONS_CONSTANTS_LOADED=1

# User-facing tmux options.
readonly TAB_ICONS_OPTION_FILE="@tab_icons_file"
readonly TAB_ICONS_OPTION_SOURCE="@tab_icons_source"
readonly TAB_ICONS_OPTION_FLAGS="@tab_icons_flags"
readonly TAB_ICONS_OPTION_OUTPUT="@tab_icons_window_name"

# shellcheck disable=SC2088  # The tilde is expanded at runtime, after the user may override it.
readonly TAB_ICONS_DEFAULT_FILE="~/.config/tmux/icons.conf"
readonly TAB_ICONS_DEFAULT_SOURCE="window_name"
readonly TAB_ICONS_DEFAULT_FLAGS=""

# Mappings file syntax.
readonly TAB_ICONS_COMMENT_PREFIX="#"

# Internal record separator between a parsed pattern and its glyph (ASCII unit separator).
readonly TAB_ICONS_FIELD_SEPARATOR=$'\x1f'

# tmux format constraints for the `s` modifier. Separators must be punctuation other than
# `-`, `;`, `:`, `#`, `{`, `}` and `,`; the first one absent from a rule is used.
readonly TAB_ICONS_SEPARATOR_CANDIDATES="~|/!@%^&=+"
# Characters tmux cannot read inside a modifier argument, even escaped.
readonly TAB_ICONS_UNSUPPORTED_CHARS=":"

readonly TAB_ICONS_MESSAGE_PREFIX="tmux-tab-icons:"
readonly TAB_ICONS_MESSAGE_JOINER=" | "
