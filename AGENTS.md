# AGENTS.md

This is a **chezmoi** dotfiles repo. The files here are *source state*, not the live config. Editing a file in this repo does **not** change the running system — you must apply.

## Path mapping

Source path → live path (chezmoi rules):

| source | applies to |
| --- | --- |
| `dot_config/foo/bar` | `~/.config/foo/bar` |
| `dot_zshrc`, `dot_vimrc`, `dot_gitconfig` | `~/.zshrc`, `~/.vimrc`, `~/.gitconfig` |
| `private_dot_ssh/encrypted_*.asc` | `~/.ssh/*` (GPG-decrypted on apply) |
| `scripts/executable_*` | `~/scripts/*` (executable bit set) |

`.chezmoiexternal.toml` pulls oh-my-zsh + plugins on apply — don't commit them.

## Workflow

1. Edit source file in this repo (e.g. `dot_config/hypr/hyprland.conf`).
2. Preview: `chezmoi diff ~/.config/hypr/hyprland.conf`
3. Apply: `chezmoi apply ~/.config/hypr/hyprland.conf` (use `--force` if chezmoi complains the destination changed since last write).
4. Reload the affected service (see below).
5. Have the user verify visually before committing.

Pass paths to `chezmoi apply` — applying without args walks the whole tree, which is rarely what you want.

## Reload commands

| Service | Reload |
| --- | --- |
| Hyprland | `hyprctl reload` |
| Waybar | `killall -SIGUSR2 waybar` (or `pkill waybar && waybar &`) |
| swaync | `swaync-client --reload-config && swaync-client --reload-css` |
| zsh | new shell |
| vim | `:source $MYVIMRC` |
| Alacritty | edits are picked up live; new opacity/window settings need a fresh terminal |

## Do not

- **Don't commit visual/aesthetic changes without explicit user approval.** Apply, let the user see it, wait. Ricing iterates.
- **Don't blanket-apply** (`chezmoi apply` with no path) — too easy to push half-baked source files to live.
- **Don't `chezmoi re-add`** without thinking — it overwrites source with destination, blowing away in-progress edits.
- **Don't `git push --force` or rebase published commits** (this is a personal repo but still).
