#!/usr/bin/env bash
# Build and launch the CUMXext debug app. Wraps scripts/reload.sh, copies
# the resulting "cmux DEV CUMXext.app" to a renamed "CUMXext.app" sibling,
# rewrites CFBundleDisplayName / CFBundleName, strips xattr crumbs that
# trip codesign, and ad-hoc resigns so LaunchServices accepts the rename.
# The original "cmux DEV CUMXext.app" stays in place so reload.sh keeps
# its incremental build cache.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

TAG="CUMXext"
DISPLAY_NAME="CUMXext"
TAG_LOWER="$(echo "$TAG" | tr '[:upper:]' '[:lower:]')"
BUILD_DIR="$HOME/Library/Developer/Xcode/DerivedData/cmux-${TAG_LOWER}/Build/Products/Debug"
SRC_APP="$BUILD_DIR/cmux DEV ${TAG}.app"
DST_APP="$BUILD_DIR/${DISPLAY_NAME}.app"

"$PROJECT_DIR/scripts/reload.sh" --tag "$TAG" "$@"

if [[ ! -d "$SRC_APP" ]]; then
  echo "error: built app not found at: $SRC_APP" >&2
  exit 1
fi

# Rebuild the renamed copy from scratch each run so changes from the
# incremental build always propagate.
rm -rf "$DST_APP"
cp -R "$SRC_APP" "$DST_APP"

INFO_PLIST="$DST_APP/Contents/Info.plist"
plutil -replace CFBundleDisplayName -string "$DISPLAY_NAME" "$INFO_PLIST"
plutil -replace CFBundleName -string "$DISPLAY_NAME" "$INFO_PLIST"

# Drop xattr crumbs that tripped codesign (resource forks, quarantine flags)
# and ad-hoc resign so LaunchServices doesn't reject the bundle with -54.
xattr -cr "$DST_APP"
codesign --force --deep --sign - "$DST_APP" >/dev/null

pkill -f "cmux DEV ${TAG}.app/Contents/MacOS/" || true
pkill -f "${DISPLAY_NAME}.app/Contents/MacOS/" || true
sleep 0.3
env -u GIT_PAGER -u GH_PAGER open "$DST_APP"

cat <<EOF

App path:
  $DST_APP
Display name in Dock: $DISPLAY_NAME
EOF
