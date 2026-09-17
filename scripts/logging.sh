#!/usr/bin/env bash

# Reports a non-fatal problem on stderr; the entry point relays it to tmux.
warn() {
  printf '%s %s\n' "$TAB_ICONS_MESSAGE_PREFIX" "$*" >&2
}
