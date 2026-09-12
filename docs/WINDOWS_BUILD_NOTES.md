Windows build notes — path quoting and plugin warnings
===============================================

Summary
-------
When running `flutter test` on Windows the repository hit a quoting-related failure during native asset build hooks, producing an error like:

  'C:\Users\Mehul' is not recognized as an internal or external command

This indicates that a command was invoked where a path containing spaces was not correctly quoted. In our run we also observed a non-fatal warning about `flutter_local_notifications:linux` referencing `flutter_local_notifications_linux` as a default implementation.

Observed output
---------------

 - "'C:\\Users\\Mehul' is not recognized as an internal or external command"
 - "Package flutter_local_notifications:linux references flutter_local_notifications_linux:linux as the default plugin..."

Why this matters
-----------------
 - The quoting failure can break native asset build hooks on Windows and cause test or build failures when paths include spaces (common in user profiles).
 - The linux-plugin warning is non-fatal for tests, but indicates a package references a platform default implementation that may not exist on all platforms/CI runners.

Workarounds
-----------

1) Run from a path without spaces (recommended quick fix)

 - Move or clone the repository to a directory without spaces, e.g. `C:\code\Security`.
 - Or create a symlink from a no-space path to the repo location:

   ```powershell
   mklink /D C:\code\Security "C:\Users\Mehul Pawar\Documents\Security"
   cd C:\code\Security
   flutter pub get
   flutter test
   ```

2) Install Flutter to a path without spaces

 - Installing Flutter under `C:\flutter` avoids quoting problems originating from the SDK path itself.

3) Use WSL (Windows Subsystem for Linux)

 - Run tests under WSL where quoting behavior differs and many Flutter toolchains are tested on Linux.

4) CI: rely on Linux/macOS runners

 - GitHub Actions and other CI providers typically run on Linux/macOS where this issue doesn't appear; ensure CI runs full test matrix.

5) Plugin warning handling

 - Consider upgrading `flutter_local_notifications` to a newer version where the package's `linux` platform mapping is correct.
 - If the warning persists and blocks scripts, report an issue to the package maintainers.

Suggested next steps (safe to review in PR)
-----------------------------------------

 - Add this note to `docs/` and open a small PR so maintainers see it.
 - Optionally add a CI job that runs `flutter test` on Windows runners (if desired) to detect regressions early.
 - If a stable fix is found (package update or patch), follow up with a PR to bump the dependency or add a targeted workaround.

Contact
-------
If you want me to open an issue against the offending package, prepare a PR that modifies CI or bump dependencies, say which option and I'll prepare the changes.
