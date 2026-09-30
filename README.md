<img src="icon/icon_round.png" width="76"/>

# Pass
[![GitHub release](https://img.shields.io/github/release/mssun/passforios.svg)](https://github.com/mssun/passforios/releases)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/passforios/passforios)
[![Build Status](https://github.com/mssun/passforios/workflows/Deploying/badge.svg)](https://github.com/mssun/passforios/actions)
[![Donate](https://img.shields.io/badge/paypal-donate-blue.svg)](https://www.paypal.me/mssun)

Pass is an iOS client compatible with [ZX2C4's Pass command line application](http://www.passwordstore.org/).
It is a password manager using GPG for encryption and Git for version control.

Pass for iOS is available in App Store with the name "Pass - Password Store", and both iPhone and iPad are supported.

<p>
<a href="https://itunes.apple.com/us/app/pass-password-store/id1205820573?mt=8"><img alt="Download on the App Store" src="img/app_store_badge.svg" width="150"/></a>
</p>

You can also help us test beta versions through [TestFlight](https://testflight.apple.com/join/whK4zUFG).

## Features

- Compatible with the Password Store command line tool.
- View, copy, add, and edit password entries.
- Encrypt and decrypt password entries by PGP keys.
- Synchronize with your password Git repository.
- User-friendly interface: search, long press to copy, copy and open link, etc.
- Support one-time password tokens (two-factor authentication codes).
- AutoFill in Safari/Chrome and [supported apps](https://github.com/agilebits/onepassword-app-extension).
- Support YubiKey.

## Screenshots

<p>
<img src="img/screenshot1.png" width="200"/>
<img src="img/screenshot2.png" width="200"/>
<img src="img/screenshot3.png" width="200"/>
<img src="img/screenshot4.png" width="200"/>
</p>

## Usages

- Setup your password-store ([official `Pass` introduction](https://www.passwordstore.org/))
- Get Pass for iOS from the App Store or [build by yourself](https://github.com/mssun/passforios/wiki/Building-Pass-for-iOS)
- Setup Pass for iOS ([quick-start guide](https://github.com/mssun/passforios/wiki#quick-start-guide-for-pass-for-ios))

For more, please read the [wiki page](https://github.com/mssun/passforios/wiki).

## Building Pass for iOS

This fork builds with `make` and Xcode 27 (iOS 26 or later).

1. Install Go: `brew install go`.
1. Copy `local.mk.example` to `local.mk` and fill in your team ID, a bundle identifier of your own, and your devices. Set `PAID_ACCOUNT = 1` if you have a paid Apple Developer Program membership; without it, the app works on its own, but AutoFill, the share extension, Siri Shortcuts, and YubiKey over NFC are left out.
1. Run `make test` for the unit tests and `make sim` to run the app in the simulator. `make device D=<name>` installs it on a device, and on an Apple silicon Mac, `make mac` runs it there as an iPad app. `make help` lists everything else.

Your build has its own bundle identifier, so it installs next to the App Store app instead of replacing it, and it cannot see the App Store app's data. To use it, import your keys and clone your password store again. `make` also installs git hooks that refuse commits containing personal information (see `CLAUDE.md`).

## License

MIT
