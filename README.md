# Reset WhatsApp for macOS

A small native macOS utility for repairing WhatsApp launch failures caused by corrupted local data. It quits WhatsApp, deletes only known local WhatsApp data, and opens a clean installation that can be linked again with a QR code.

> [!WARNING]
> Resetting is destructive. Messages, media, or drafts that have not synchronized may be lost. Confirm that anything important is available on your phone before continuing.

![Reset WhatsApp icon](Resources/ResetWhatsApp.png)

## What it does

- **Standard Reset** keeps WhatsApp installed and deletes its known containers, preferences, caches, and saved state.
- **Full Reset** also permanently deletes `/Applications/WhatsApp.app` and opens the official WhatsApp page in the Mac App Store.
- The utility never creates a local backup, so old reset data does not accumulate on your Mac.
- Before deletion, every target is checked to ensure it is inside `~/Library` or is exactly `/Applications/WhatsApp.app`.
- A second explicit confirmation is required before any deletion starts.

Chats on your phone and WhatsApp documents stored in iCloud Drive are not changed.

## Privacy

- No telemetry or personal data is collected.
- The app makes no network connections of its own. It only opens the official WhatsApp page in the Mac App Store after a full reset or if WhatsApp is not installed.
- It does not inspect chat content; it removes known local directories as complete units.

## Install and use

1. Download a release or build `Reset WhatsApp.app` yourself.
2. Move it to `/Applications`.
3. Grant it **Full Disk Access** in **System Settings › Privacy & Security › Full Disk Access**.
4. Open **Reset WhatsApp** and choose **Standard Reset** first.
5. When WhatsApp opens, relink this Mac with the QR code on your phone.

Use **Full Reset** only when a standard reset does not solve the issue.

When replacing the app with a newly built version, remove its old Full Disk Access entry and add `/Applications/Reset WhatsApp.app` again. Local builds use ad-hoc signing, so their identity changes whenever the app changes. Version 2.1 also uses the public bundle identifier `com.github.millarch.reset-whatsapp`; updating from an earlier release requires granting the permission again.

## Build from source

Requirements:

- macOS 13 or later
- Xcode and Command Line Tools

Run:

```bash
./Scripts/build.sh
./Scripts/verify.sh
```

The app is written to `build/Reset WhatsApp.app` and signed locally with an ad-hoc signature.

## Project layout

- `Sources/main.swift` — native app and cleanup logic
- `Sources/build-icon.swift` — packs PNG representations into ICNS
- `Resources/ResetWhatsApp.png` — icon source artwork
- `Resources/Info.plist` — app metadata
- `Scripts/build.sh` — reproducible build
- `Scripts/verify.sh` — bundle, executable, icon, and signature checks

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md), keep pull requests focused, and never include real WhatsApp content, account identifiers, or private data in issues, commits, or test artifacts.

## Security

See [SECURITY.md](SECURITY.md) to report a vulnerability privately.

## Disclaimer

This independent project is not affiliated with, sponsored by, endorsed by, or maintained by WhatsApp or Meta. “WhatsApp” is used only to identify the compatible application.

## License

Distributed under the [MIT License](LICENSE).
