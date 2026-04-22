# Windows and Workspaces

Window/workspace lifecycle and ordering operations.

## Inspect

```bash
cmuxplus list-windows
cmuxplus current-window
cmuxplus list-workspaces
cmuxplus current-workspace
```

## Create/Focus/Close

```bash
cmuxplus new-window
cmuxplus focus-window --window window:2
cmuxplus close-window --window window:2

cmuxplus new-workspace
cmuxplus select-workspace --workspace workspace:4
cmuxplus close-workspace --workspace workspace:4
```

## Reorder and Move

```bash
cmuxplus reorder-workspace --workspace workspace:4 --before workspace:2
cmuxplus move-workspace-to-window --workspace workspace:4 --window window:1
```
