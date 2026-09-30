# Pass for iOS (personal fork)

This is a fork of [mssun/passforios](https://github.com/mssun/passforios), an iOS client for the `pass` password store (PGP-encrypted files in a git repository). The fork adds a Makefile-driven build with personal settings kept out of the repository. Read this file, then `make help`.

## Personal information

This repository is public. Nothing personal may be committed or pushed: not in code, not in comments, not in documentation, not in commit messages, and not "as an example". This rule has no exceptions.

- Personal values live only in git-ignored files: `local.mk` (team ID, bundle ID, device UDIDs), `Config/Local.xcconfig` (generated from `local.mk`), `CLAUDE.local.md`, and `.private-strings` (any further strings to refuse, one per line). Never stage these files, and never copy a value from them into a tracked file. Examples and defaults use placeholders: `com.example.passforios`, `XXXXXXXXXX` for a team, `00000000-0000000000000000` for a UDID.
- Also personal: passwords, passphrases, PGP and SSH keys, API keys and tokens, git remote URLs of anyone's password store, usernames and email addresses, absolute paths under a home directory, host and device names, and screenshots or logs from a real device or a real password store. Test data must be synthetic.
- The git hooks in `.githooks` (installed by any `make` target, or `make hooks`) enforce this. `pre-commit` and `commit-msg` refuse staged changes and messages that contain a value from `local.mk` or `.private-strings`, the home directory, the git email, the host name, a device UDID, a credential-shaped string (private key blocks, URLs with passwords, common API token formats), or a key, certificate, or profile file. `pre-push` checks every commit that no remote has yet. The checks read the private values at run time and never print them. `make check-private` audits every tracked file.
- Never bypass the hooks: no `--no-verify`, no `git commit -n`, no change to `core.hooksPath`. A Claude Code hook (`.claude/hooks/git-guard.sh`) blocks these commands. If a check reports a false positive, stop and tell the user; only the user may decide to bypass it, by hand.
- Before each commit, also read the staged diff yourself (`git diff --cached`) for anything personal that the patterns cannot know about, such as a name, a service the user has an account with, or the layout of their password store.

## Building

- `make test` runs the unit tests on the "Pass iPhone" simulator, `make sim` installs and launches on the "Pass iPhone" and "Pass iPad" simulators, `make build` builds the Release app for devices, `make device D=<name>` installs on a device named in `local.mk`, and `make mac` runs the iPad app on this Mac (Apple silicon's "Designed for iPad", from a `Wrapper/` bundle in `build.noindex/mac`, as macOS requires for iOS apps; it needs `TEAM` and this Mac registered with the team). The first build compiles GopenPGP with Go (`scripts/gopenpgp_build.sh`, into the git-ignored `go/`).
- Build products go to `build.noindex/`. Xcode 27 lives at `/Applications/Xcode.app`; the Makefile sets `DEVELOPER_DIR`, since `xcode-select` may point at the Command Line Tools.
- The `pass` target's Debug builds run SwiftFormat and SwiftLint (`lint --fix`) over the repository as build phases, so a build can rewrite source files. `build.noindex` and `go` are excluded in `.swiftformat` and `.swiftlint.yml`.
- The project's own code (not the packages) builds without compiler or SwiftLint warnings. Keep it that way: fix a new warning instead of leaving it, and prefer current APIs (the deployment target is iOS 26, so no `#available` checks for older systems).
- `xcodebuild -quiet` prints "error: the following command failed with exit code 0 but produced no further output" for commands that only warned; these are not failures. The exit status and the `.xcresult` in `build.noindex/Logs/Test` are what count.

## Configuration

- Personal settings go in `local.mk` (see `local.mk.example`). `make` writes them to `Config/Local.xcconfig`, which `Config/Project.xcconfig` includes. `Config/Project.xcconfig` is the base configuration of the project, so it holds every identifier and signing setting (bundle IDs, team, entitlements, display name). Build settings in the project file override it, so no target may set `PRODUCT_BUNDLE_IDENTIFIER`, `DEVELOPMENT_TEAM`, `CODE_SIGN_*`, or `PROVISIONING_PROFILE*` there; edit `Config/Project.xcconfig` instead.
- All identifiers derive from `PASS_APP_ID` (`BUNDLE_ID`, plus the suffix `beta` in the Beta configuration): the extensions (`.find-login-action-extension`, `.auto-fill-credential-extension`, `.shortcuts`), the framework (`.passKit`), and the App Group (`group.<app id>`). `APP_NAME` sets the display name of the app and its extensions.
- Capabilities that need a paid Apple Developer Program membership (the App Group shared with the extensions, AutoFill, Siri, NFC for the YubiKey) are behind `PAID_ACCOUNT` in `local.mk` (`PASS_PAID_ACCOUNT`). Their entitlements are only in the targets' `*.entitlements` files, which `CODE_SIGN_ENTITLEMENTS` selects only when the flag is on. Code checks at run time, never with `#if`: the app and each extension carry `PassAppIdentifier` and `PassAppGroup` in their Info.plist, and `Globals` reads them. Without an App Group (`Globals.groupIdentifier == nil`), the app keeps its repository, keys database, and defaults in its own container, and the keychain uses the app's default group. `make test` tests the configuration in `local.mk`, `make test-free` the one without a paid account. Xcode's provisioning step reads only the xcconfig files, not command-line overrides such as `PASS_PAID_ACCOUNT=NO`, so a Makefile target that changes the flag sets a target-specific `PAID_ACCOUNT = 0`, which writes it into `Config/Local.xcconfig`; the next other target writes it back.
- The deployment target is iOS 26. The app uses the scene lifecycle (`SceneDelegate` owns the window, the passcode lock, the privacy blur, and the Home Screen quick action), which apps built with the iOS 27 SDK must adopt.

## Upstream

- `origin` is upstream (mssun/passforios); the fork is the `goerz` remote. The fork's `master` carries the build setup on top of upstream's `master`; merge upstream into it to update.
- Upstream's fastlane lanes and its Deploying workflow sign with upstream's team and profiles, which this setup replaced with automatic signing, and its Testing workflow's runner cannot build for iOS 26. Both workflows run only in upstream's repository; the fork is tested with `make test`.
- A change meant for upstream goes on a branch from `origin/master`, without the fork's setup (Makefile, `Config/`, the identifier changes).
