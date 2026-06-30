#!/usr/bin/env python3
"""Toggle Sublime Text + Obsidian together.

i3's per-window `scratchpad show` is an independent toggle, so chaining one for
Sublime and one for Obsidian desyncs the instant their states diverge (one
shown, one hidden) and just swaps which is visible. This walks the tree: if
EITHER target is currently visible it hides BOTH, otherwise it shows BOTH.
Acting by con_id keeps it exact. A desynced state self-heals: the stray visible
window is hidden first, and the next press shows both.
"""
import json
import subprocess

TARGETS = ("sublime_text", "obsidian")


def i3(*args):
    return subprocess.run(
        ["i3-msg", *args], stdout=subprocess.PIPE, check=False
    ).stdout


def walk(node, ws):
    cur = node.get("name") if node.get("type") == "workspace" else ws
    cls = ((node.get("window_properties") or {}).get("class") or "").lower()
    hits = [(node["id"], cur)] if cls in TARGETS else []
    for child in node.get("nodes", []) + node.get("floating_nodes", []):
        hits += walk(child, cur)
    return hits


wins = walk(json.loads(i3("-t", "get_tree")), None)
shown = [cid for cid, ws in wins if ws != "__i3_scratch"]

if shown:
    cmd = "; ".join(f"[con_id={cid}] move scratchpad" for cid in shown)
else:
    cmd = "; ".join(f"[con_id={cid}] scratchpad show" for cid, _ in wins)

if cmd:
    i3(cmd)
