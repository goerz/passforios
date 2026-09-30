//
//  AppKeychain.swift
//  passKit
//
//  Created by Danny Moesch on 25.06.19.
//  Copyright © 2019 Bob Sun. All rights reserved.
//

import KeychainAccess

public class AppKeychain: KeyStore {
    public static let shared = AppKeychain()

    // Without an App Group, the app's default keychain group.
    private let keychain = (Globals.groupIdentifier.map { Keychain(service: Globals.bundleIdentifier, accessGroup: $0) } ?? Keychain(service: Globals.bundleIdentifier))
        .accessibility(.whenUnlockedThisDeviceOnly)
        .synchronizable(false)

    public func add(string: String?, for key: String) {
        keychain[key] = string
    }

    public func contains(key: String) -> Bool {
        (try? keychain.contains(key)) ?? false
    }

    public func get(for key: String) -> String? {
        try? keychain.getString(key)
    }

    public func removeContent(for key: String) {
        try? keychain.remove(key)
    }

    public func removeAllContent() {
        try? keychain.removeAll()
    }

    public func removeAllContent(withPrefix prefix: String) {
        keychain.allKeys()
            .filter { $0.hasPrefix(prefix) }
            .forEach { try? keychain.remove($0) }
    }

    public static func getPGPKeyPassphraseKey(keyID: String) -> String {
        Globals.pgpKeyPassphrase + "-" + keyID
    }
}
