#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_NAME="EFI挂载器"
INFO_PLIST="$PROJECT_DIR/$APP_NAME/Info.plist"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO_PLIST")"
RELEASE_DIR="$PROJECT_DIR/release/v$VERSION"
DERIVED_DATA="$(mktemp -d /tmp/efi-mounter-derived.XXXXXX)"
STAGE_DIR="$(mktemp -d /tmp/efi-mounter-stage.XXXXXX)"
DMG_NAME="$APP_NAME-v$VERSION.dmg"
DMG_TEMP="$RELEASE_DIR/.$DMG_NAME"
DMG_FINAL="$RELEASE_DIR/$DMG_NAME"

cleanup() {
    rm -rf "$DERIVED_DATA" "$STAGE_DIR"
}
trap cleanup EXIT

cd "$PROJECT_DIR"
mkdir -p "$RELEASE_DIR"

xcodebuild \
    -project "$APP_NAME.xcodeproj" \
    -scheme "$APP_NAME" \
    -configuration Release \
    -derivedDataPath "$DERIVED_DATA" \
    ONLY_ACTIVE_ARCH=NO \
    ARCHS="arm64 x86_64" \
    CODE_SIGNING_ALLOWED=NO \
    build

APP_PATH="$DERIVED_DATA/Build/Products/Release/$APP_NAME.app"

codesign --force --deep --sign - "$APP_PATH"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
lipo -archs "$APP_PATH/Contents/MacOS/$APP_NAME"

ditto "$APP_PATH" "$STAGE_DIR/$APP_NAME.app"
ln -s /Applications "$STAGE_DIR/应用程序"

hdiutil create \
    -volname "$APP_NAME $VERSION" \
    -srcfolder "$STAGE_DIR" \
    -ov \
    -format UDZO \
    "$DMG_TEMP"

hdiutil verify "$DMG_TEMP"
mv -f "$DMG_TEMP" "$DMG_FINAL"

(
    cd "$RELEASE_DIR"
    if [[ -f "$APP_NAME-v$VERSION.zip" ]]; then
        shasum -a 256 "$DMG_NAME" "$APP_NAME-v$VERSION.zip" > SHA256SUMS.txt
    else
        shasum -a 256 "$DMG_NAME" > SHA256SUMS.txt
    fi
)

echo "DMG 已生成：$DMG_FINAL"
