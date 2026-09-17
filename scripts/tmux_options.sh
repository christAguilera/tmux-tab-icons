#!/usr/bin/env bash

# The only module allowed to talk to tmux.

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local value
  value="$(tmux show-option -gqv "$option")"
  printf '%s' "${value:-$default_value}"
}

set_tmux_option() {
  tmux set-option -gq "$1" "$2"
}

display_tmux_message() {
  tmux display-message "$1"
}
