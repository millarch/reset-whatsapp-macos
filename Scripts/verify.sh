#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
APP="$ROOT/build/Reset WhatsApp.app"

[[ -d "$APP" ]]
/usr/bin/plutil -lint "$APP/Contents/Info.plist"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Contents/Info.plist")" == "com.github.millarch.reset-whatsapp" ]]
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")" == "2.1.0" ]]
/usr/bin/file "$APP/Contents/MacOS/reset-whatsapp" | /usr/bin/grep -q 'Mach-O 64-bit executable arm64'
/usr/bin/file "$APP/Contents/Resources/ResetWhatsApp.icns" | /usr/bin/grep -q 'Mac OS X icon'
/usr/bin/codesign --verify --deep --strict --verbose=2 "$APP"
"$APP/Contents/MacOS/reset-whatsapp" --diagnose | /usr/bin/grep -q 'Library/Containers/net.whatsapp.WhatsApp/Data'

echo "Verification passed."
