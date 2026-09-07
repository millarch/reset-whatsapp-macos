# Contributing

Thanks for helping improve Reset WhatsApp for macOS.

## Before you start

- Search existing issues and pull requests before opening a new one.
- Discuss significant behavior or target-list changes in an issue first.
- Never include real WhatsApp conversations, media, databases, account identifiers, or other private data in issues, commits, screenshots, or test artifacts.

## Development workflow

1. Create a branch from `main`.
2. Keep each pull request focused on one change.
3. Update `README.md` or other relevant documentation whenever behavior, requirements, or user-facing text changes.
4. Run the local checks before submitting:

   ```bash
   ./Scripts/build.sh
   ./Scripts/verify.sh
   ```

5. Explain the change, how it was tested, and any privacy or data-loss considerations in the pull request.

## Scope and safety

This app intentionally performs destructive local cleanup. Changes to deletion targets require particular care: targets must remain limited to WhatsApp-specific paths inside `~/Library`, except for the exact `/Applications/WhatsApp.app` path used by Full Reset. Do not add broad paths, recursive home-directory cleanup, shell-provided input paths, or backup behavior without an explicit security review.

## Release process

Releases are produced by GitHub Actions, never from a local build, so the published zip contains no local metadata and can be traced back to the tagged source.

1. Bump `CFBundleShortVersionString` and `CFBundleVersion` in `Resources/Info.plist` and merge that change into `main`.
2. Tag the merge commit with the same version, prefixed with `v`, and push the tag:

   ```bash
   git tag v2.2.0
   git push origin v2.2.0
   ```

3. The `Release` workflow checks that the tag matches the version, builds and verifies the app, packages it with `ditto` (no resource forks or extended attributes), attaches `Reset-WhatsApp-<version>.zip`, `Reset-WhatsApp.zip`, and `SHA256SUMS.txt`, and publishes the release. Edit `.github/release-notes.md` if the install instructions change.

## Code style

Use clear English for code comments, UI text, documentation, commit messages, issue discussions, and pull requests. Prefer small, readable Swift and zsh changes that work on the supported macOS versions.
