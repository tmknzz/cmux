#!/bin/bash
# Rebuild and restart cmux app

set -e

cd "$(dirname "$0")/.."

# Kill existing app if running
pkill -9 -f "cmuxplus" 2>/dev/null || true

# Build
swift build

# Copy to app bundle
cp .build/debug/cmuxplus .build/debug/cmuxplus.app/Contents/MacOS/

# Open the app
open .build/debug/cmuxplus.app
