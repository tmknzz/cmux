# Panes and Surfaces

Split layout, surface creation, focus, move, and reorder.

## Inspect

```bash
cmuxplus list-panes
cmuxplus list-pane-surfaces --pane pane:1
```

## Create Splits/Surfaces

```bash
cmuxplus new-split right --panel pane:1
cmuxplus new-surface --type terminal --pane pane:1
cmuxplus new-surface --type browser --pane pane:1 --url https://example.com
```

## Focus and Close

```bash
cmuxplus focus-pane --pane pane:2
cmuxplus focus-panel --panel surface:7
cmuxplus close-surface --surface surface:7
```

## Move/Reorder Surfaces

```bash
cmuxplus move-surface --surface surface:7 --pane pane:2 --focus true
cmuxplus move-surface --surface surface:7 --workspace workspace:2 --window window:1 --after surface:4
cmuxplus reorder-surface --surface surface:7 --before surface:3
```

Surface identity is stable across move/reorder operations.
