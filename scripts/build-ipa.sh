#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

BUILD_DIR="$ROOT/build"
DIST_DIR="$ROOT/dist"
APP_NAME="GothamPocket"
VERSION="1.0"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen is required. Install it with: brew install xcodegen" >&2
  exit 1
fi

echo "==> Generating Xcode project"
xcodegen generate

echo "==> Building unsigned device app"
xcodebuild \
  -project "$APP_NAME.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath "$BUILD_DIR" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build

APP_PATH="$(find "$BUILD_DIR/Build/Products/Release-iphoneos" -name '*.app' -type d -print -quit)"
if [[ -z "${APP_PATH:-}" ]]; then
  echo "No .app was produced. Check the xcodebuild output above." >&2
  exit 1
fi

echo "==> Packaging $(basename "$APP_PATH")"
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR/Payload"
cp -R "$APP_PATH" "$DIST_DIR/Payload/"
(
  cd "$DIST_DIR"
  /usr/bin/zip -qry "${APP_NAME}-${VERSION}-unsigned.ipa" Payload
  shasum -a 256 "${APP_NAME}-${VERSION}-unsigned.ipa" > "${APP_NAME}-${VERSION}-unsigned.ipa.sha256"
)

echo
echo "Done: $DIST_DIR/${APP_NAME}-${VERSION}-unsigned.ipa"
echo "This IPA is unsigned. Use Xcode, Sideloadly, or AltStore to sign it with your Apple ID."
