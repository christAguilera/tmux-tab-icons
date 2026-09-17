# tmux-tab-icons

Replaces parts of tmux window names with glyphs (e.g. Nerd Font icons) using regex rules from a file.

The plugin builds a native tmux format (`#{s|regex|glyph|:#{window_name}}`, nested once per rule) and stores it in `@tab_icons_window_name`. tmux evaluates it on every render: no shell processes per refresh, windows are never renamed and `automatic-rename` keeps working.

## Installation

With [TPM](https://github.com/tmux-plugins/tpm):

```tmux
set -g @plugin 'jchrisnavarro/tmux-tab-icons'
```

Manually:

```tmux
run-shell ~/path/to/tmux-tab-icons/tab_icons.tmux
```

Then reference the generated format wherever the window name is shown:

```tmux
set -g window-status-format " #I #{E:@tab_icons_window_name} "
set -g window-status-current-format " #I #{E:@tab_icons_window_name} "

# catppuccin
set -g @catppuccin_window_text " #{E:@tab_icons_window_name}"
set -g @catppuccin_window_current_text " #{E:@tab_icons_window_name}"
```

## Mappings file

One rule per line: `<regex> <glyph>`. See [`examples/icons.conf`](examples/icons.conf).

```
# Comments and blank lines are ignored
n?vim 
^(zsh|bash|fish)$ 
docker compose 
```

- The **last** whitespace-separated token is the glyph; everything before it is the regex, so the regex may contain spaces.
- Regexes are POSIX extended (what tmux uses). Every match is replaced, not only the first.
- Rules apply top to bottom, each on the output of the previous one.
- `:` cannot be used in regexes or glyphs (tmux formats cannot represent it); those rules are skipped with a warning.
- Changes take effect when the plugin runs again (e.g. reloading `tmux.conf`).

## Options

| Option | Default | Description |
|---|---|---|
| `@tab_icons_file` | `~/.config/tmux/icons.conf` | Mappings file |
| `@tab_icons_source` | `window_name` | Format variable to transform (e.g. `pane_current_command`) |
| `@tab_icons_flags` | _(empty)_ | Flags for tmux's `s` modifier (`i` = case-insensitive) |
| `@tab_icons_window_name` | _(generated)_ | Output format; use it with `#{E:@tab_icons_window_name}` |

## Development

```sh
brew install bats-core shellcheck
bats tests/
shellcheck -x tab_icons.tmux scripts/*.sh tests/*.bats tests/test_helper.bash
```
