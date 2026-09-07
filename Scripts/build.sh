#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
BUILD="$ROOT/build"
APP="$BUILD/Reset WhatsApp.app"
CONTENTS="$APP/Contents"
ICONSET="$BUILD/ResetWhatsApp.iconset"

/usr/bin/find "$BUILD" -depth -delete 2>/dev/null || true
/bin/mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources" "$ICONSET"

/usr/bin/xcrun swiftc -O -framework AppKit "$ROOT/Sources/main.swift" -o "$CONTENTS/MacOS/reset-whatsapp"
/bin/cp "$ROOT/Resources/Info.plist" "$CONTENTS/Info.plist"

make_icon() {
    /usr/bin/sips -z "$1" "$1" "$ROOT/Resources/ResetWhatsApp.png" --out "$ICONSET/$2" >/dev/null
}

make_icon 16 icon_16x16.png
make_icon 32 icon_16x16@2x.png
make_icon 32 icon_32x32.png
make_icon 64 icon_32x32@2x.png
make_icon 128 icon_128x128.png
make_icon 256 icon_128x128@2x.png
make_icon 256 icon_256x256.png
make_icon 512 icon_256x256@2x.png
make_icon 512 icon_512x512.png
make_icon 1024 icon_512x512@2x.png

/usr/bin/xcrun swift "$ROOT/Sources/build-icon.swift" "$ICONSET" "$CONTENTS/Resources/ResetWhatsApp.icns"
/usr/bin/codesign --force --deep --sign - "$APP"

echo "Created: $APP"
