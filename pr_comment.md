Windows build: path-quoting failure when building native assets

Summary:
When running `flutter test` on Windows we saw an error like:

  'C:\Users\Mehul' is not recognized as an internal or external command

This happens when a package build hook invokes a command where a path containing spaces isn't properly quoted. A non-fatal warning about `flutter_local_notifications:linux` referencing `flutter_local_notifications_linux` was also observed.

Workarounds:
- Move the repository to a path without spaces (e.g. `C:\code\Security`) or create a symlink:

  mklink /D C:\code\Security "C:\Users\Mehul Pawar\Documents\Security"

- Install Flutter to a path without spaces (e.g. `C:\flutter`) and update your PATH.
- Run tests under WSL (Ubuntu) where quoting behaves differently.
- CI: run tests on Linux/macOS runners (current GH Actions already do this).
- For the linux plugin warning: consider upgrading `flutter_local_notifications` or filing an issue with its maintainers to avoid referencing a default implementation that may not exist.

What I changed in this PR:
- Added telemetry persistence to `lib/services/telemetry_service.dart` (local JSON).
- Added `TelemetryEvent.fromJson()` and restored timestamps when reading persisted data.
- Wired diagnostics export/clear to the UI and added tests: `test/telemetry_event_test.dart` and `test/telemetry_service_persistence_test.dart`.

If you'd like, I can open an issue against the offending package, prepare a small PR to work around the quoting in our repo's build config, or update the PR description with these notes.
