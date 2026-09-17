# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A TPM plugin (pure Bash) that replaces regex matches in tmux window names with glyphs. User-facing docs, options and the mappings file syntax are in `README.md`.

## Commands

```sh
bats tests/                                   # all tests (tests/tab_icons.bats needs tmux; skipped otherwise)
bats tests/format_builder.bats                # one file
bats tests/ -f "nests rules"                  # tests whose name matches a regex
shellcheck -x tab_icons.tmux scripts/*.sh tests/*.bats tests/test_helper.bash
```

Manual check against an isolated server (never touch the user's real server/socket):

```sh
tmux -L tab-icons-dev -f /dev/null new -d -n 'nvim foo'
tmux -L tab-icons-dev set -g @tab_icons_file "$PWD/examples/icons.conf"
tmux -L tab-icons-dev run-shell "$PWD/tab_icons.tmux"
tmux -L tab-icons-dev display -p '#{E:@tab_icons_window_name}'
tmux -L tab-icons-dev kill-server
```

## Architecture

The plugin runs once at load time and produces a static tmux format; tmux does all the work at render time. Do not switch to `#()` shell calls or `rename-window` hooks: the former spawns processes on every status refresh, the latter breaks `automatic-rename`.

Pipeline, orchestrated by `tab_icons.tmux` (no logic of its own):

1. `scripts/tmux_options.sh` reads `@tab_icons_*` options. It is the **only** module that calls `tmux`; every other module is a pure stdin/args → stdout function so it can be unit-tested without tmux.
2. `scripts/mappings_parser.sh` turns the mappings file into records `<regex>\x1f<glyph>` (separator is `TAB_ICONS_FIELD_SEPARATOR`).
3. `scripts/format_builder.sh` folds the records into `#{s<sep><regex><sep><glyph><sep><flags>:<previous>}`, starting from `#{<source variable>}`; the first rule is the innermost.
4. `scripts/format_escape.sh` escapes arguments and picks `<sep>` per rule.
5. The result is stored in `@tab_icons_window_name`. Problems are written to stderr via `warn` (`scripts/logging.sh`), collected by the entry point and shown in a single `display-message`.

All option names, defaults and format constraints live in `scripts/constants.sh` (guarded against double sourcing, since values are `readonly`).

## tmux format escaping rules (verified on tmux 3.6b)

Modifier arguments are format-expanded by tmux, so:

- `#` → `##` (must be escaped first; also prevents `#(...)` command execution), `,` → `#,`, `}` → `#}`. `{` needs no escape.
- The argument separator cannot be escaped, so a separator not present in the rule is chosen from `TAB_ICONS_SEPARATOR_CANDIDATES`. Valid separators are punctuation other than `-`, `;`, `:`, `#`, `{`, `}` and `,`.
- `:` cannot appear in arguments at all (`#:` does not work), so those rules are rejected.
- `\|` does not match a literal `|`; use `[|]`.

When changing escaping, re-verify with `tmux -L <socket> display -p '<format>'` and cover it in `tests/tab_icons.bats`.

## Conventions

- Keep scripts compatible with the Bash that TPM invokes via `#!/usr/bin/env bash`; avoid adding dependencies beyond tmux.
- Test fixtures containing glyphs are written with escapes (`$''`, see `tests/test_helper.bash`), since private-use characters are easily lost when editing.
