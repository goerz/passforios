//
//  Globals.swift
//  passKit
//
//  Created by Mingshen Sun on 21/1/2017.
//  Copyright © 2017 Bob Sun. All rights reserved.
//

import Foundation
import UIKit

public final class Globals {
    // The app and each extension carry the app's bundle identifier and App Group in their
    // Info.plist (from PASS_APP_ID and PASS_APP_GROUP in Config/Project.xcconfig), so all of
    // them use the same keychain service, defaults, and container.
    public static let bundleIdentifier = infoString("PassAppIdentifier") ?? Bundle.main.bundleIdentifier ?? "me.mssun.passforios"

    // The App Group shared with the extensions, or nil in a build without a paid developer
    // account (PAID_ACCOUNT in local.mk), which keeps its data in the app's own container.
    public static let groupIdentifier = infoString("PassAppGroup")
    public static let passKitBundleIdentifier = bundleIdentifier + ".passKit"

    public static let sharedContainerURL: URL = {
        if let groupIdentifier {
            return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!
        }
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("SharedContainer")
        for directory in ["Documents", "Library"] {
            try? FileManager.default.createDirectory(at: url.appendingPathComponent(directory), withIntermediateDirectories: true)
        }
        return url
    }()

    public static let documentPath = sharedContainerURL.appendingPathComponent("Documents").path
    public static let libraryPath = sharedContainerURL.appendingPathComponent("Library").path
    public static let pgpPublicKeyPath = documentPath + "/gpg_key.pub"
    public static let pgpPrivateKeyPath = documentPath + "/gpg_key"
    public static let gitSSHPrivateKeyPath = documentPath + "/ssh_key"
    public static let repositoryURL = sharedContainerURL.appendingPathComponent("Library/password-store/")

    public static let dbPath = documentPath + "/pass.sqlite"
    public static let dbURL = URL(fileURLWithPath: dbPath)

    public static let iTunesFileSharingPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    public static let iTunesFileSharingPGPPublic = iTunesFileSharingPath + "/gpg_key.pub"
    public static let iTunesFileSharingPGPPrivate = iTunesFileSharingPath + "/gpg_key"
    public static let iTunesFileSharingSSHPrivate = iTunesFileSharingPath + "/ssh_key"

    public static let gitPassword = "gitPassword"
    public static let gitSSHPrivateKeyPassphrase = "gitSSHPrivateKeyPassphrase"
    public static let pgpKeyPassphrase = "pgpKeyPassphrase"

    public static let gitSignatureDefaultName = "Pass for iOS"
    public static let gitSignatureDefaultEmail = "user@passforios"

    public static let passwordDots = "••••••••••••"
    public static let oneTimePasswordDots = "••••••"
    public static let passwordFont = UIFont(name: "Courier-Bold", size: UIFont.labelFontSize - 1)

    public static let otpNotification = bundleIdentifier + ".notification.otp"
    public static let otpNotificationCategory = bundleIdentifier + ".notification.otp.category"
    public static let otpNotificationCopyAction = bundleIdentifier + ".notification.otp.action.copy"

    // UI related
    public static let tableCellButtonSize = CGFloat(20.0)
    public static let passwordGeneratorLeftLayoutMargin = CGFloat(32)

    private init() {}

    private static func infoString(_ key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty else {
            return nil
        }
        return value
    }
}

public extension Bundle {
    var releaseVersionNumber: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
}
