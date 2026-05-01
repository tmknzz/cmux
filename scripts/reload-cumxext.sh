#!/usr/bin/env bash
# Build and launch the CUMXext debug app (cmux DEV CUMXext) with a custom
# Dock display name "CUMXext". Wraps scripts/reload.sh and rewrites
# CFBundleDisplayName + ad-hoc resigns the bundle so LaunchServices accepts
# the manual plist change.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

TAG="CUMXext"
DISPLAY_NAME="CUMXext"
TAG_LOWER="$(echo "$TAG" | tr '[:upper:]' '[:lower:]')"
APP_PATH="$HOME/Library/Developer/Xcode/DerivedData/cmux-${TAG_LOWER}/Build/Products/Debug/cmux DEV ${TAG}.app"

# Build via the shared reload pipeline, but don't let it launch the app yet —
# we still need to patch the plist and re-sign before LaunchServices opens it.
"$PROJECT_DIR/scripts/reload.sh" --tag "$TAG" "$@"

if [[ ! -d "$APP_PATH" ]]; then
  echo "error: built app not found at: $APP_PATH" >&2
  exit 1
fi

INFO_PLIST="$APP_PATH/Contents/Info.plist"
plutil -replace CFBundleDisplayName -string "$DISPLAY_NAME" "$INFO_PLIST"

# Drop xattr crumbs that tripped codesign (resource forks, quarantine flags)
# and ad-hoc resign so LaunchServices doesn't reject the bundle with -54.
xattr -cr "$APP_PATH"
codesign --force --deep --sign - "$APP_PATH" >/dev/null

pkill -f "cmux DEV ${TAG}.app/Contents/MacOS/" || true
sleep 0.3
env -u GIT_PAGER -u GH_PAGER open "$APP_PATH"

cat <<EOF

App path:
  $APP_PATH
Display name in Dock: $DISPLAY_NAME
EOF
