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

## Active desktop

This machine currently runs **i3 on X11**. The active desktop configuration is:

- i3: `dot_config/i3/config.tmpl`
- Picom compositor: `dot_config/picom/picom.conf`
- Polybar: `dot_config/polybar/`

`dot_config/hypr/` is retained but does not affect an i3 session. Do not infer the active window manager or compositor from the presence of config files. Check `XDG_CURRENT_DESKTOP`, `XDG_SESSION_DESKTOP`, and `DESKTOP_SESSION` first.

In i3, Picom owns compositor-level opacity, blur, and shadows. Check Picom rules before changing an application's own window settings.

## Workflow

1. Verify which desktop session and service own the behavior.
2. Edit the source file in this repo (for example, `dot_config/i3/config.tmpl` or `dot_config/picom/picom.conf`).
3. Preview the exact destination: `chezmoi diff ~/.config/picom/picom.conf`.
4. Apply only that destination: `chezmoi apply ~/.config/picom/picom.conf` (use `--force` if chezmoi complains the destination changed since last write).
5. Reload the affected service (see below).
6. Have the user verify visual changes before committing.

Pass paths to `chezmoi apply` — applying without args walks the whole tree, which is rarely what you want.

## Reload commands

| Service | Reload |
| --- | --- |
| i3 | `i3-msg reload` |
| Picom | `killall -q picom; picom --config ~/.config/picom/picom.conf -b` |
| Polybar | `~/.config/polybar/launch.sh` |
| Hyprland (only in a Hyprland session) | `hyprctl reload` |
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
