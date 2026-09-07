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

## Code style

Use clear English for code comments, UI text, documentation, commit messages, issue discussions, and pull requests. Prefer small, readable Swift and zsh changes that work on the supported macOS versions.
