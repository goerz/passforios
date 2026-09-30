//
//  SceneDelegate.swift
//  pass
//
//  Owns the app's window. Apps built with the iOS 27 SDK must use the scene lifecycle, so the
//  window-related work that used to live in the AppDelegate happens here: the passcode lock,
//  the privacy blur in the app switcher, and the Home Screen quick action.
//

import passKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    enum ViewTag: Int {
        case blur = 100, appicon
    }

    var window: UIWindow?

    lazy var passcodeLockPresenter = PasscodeLockPresenter(mainWindow: self.window)

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        passcodeLockPresenter.present(windowLevel: windowScene.windows.last?.windowLevel.rawValue)
        if connectionOptions.shortcutItem?.type == Globals.bundleIdentifier + ".search" {
            perform(#selector(postSearchNotification), with: nil, afterDelay: 0.4)
        }
    }

    @objc
    func postSearchNotification() {
        NotificationCenter.default.post(name: .passwordSearch, object: nil)
    }

    func windowScene(_: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard shortcutItem.type == Globals.bundleIdentifier + ".search",
              let tabBarController = window?.rootViewController as? UITabBarController else {
            completionHandler(false)
            return
        }
        tabBarController.selectedIndex = 0
        (tabBarController.selectedViewController as? UINavigationController)?.popToRootViewController(animated: false)
        perform(#selector(postSearchNotification), with: nil, afterDelay: 0.4)
        completionHandler(true)
    }

    func sceneWillResignActive(_: UIScene) {
        guard let window else {
            return
        }

        // Display a blur effect view
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurEffectView.frame = window.frame
        blurEffectView.tag = ViewTag.blur.rawValue
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(blurEffectView)

        // Display the Pass icon in the middle of the screen
        let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? NSDictionary
        let primaryIconsDictionary = iconsDictionary?["CFBundlePrimaryIcon"] as? NSDictionary
        if let iconName = (primaryIconsDictionary?["CFBundleIconFiles"] as? NSArray)?.lastObject as? String,
           let appIcon = UIImage(named: iconName) {
            let appIconView = UIImageView(image: appIcon)
            appIconView.layer.cornerRadius = appIcon.size.height / 5
            appIconView.layer.masksToBounds = true
            appIconView.center = window.center
            appIconView.tag = ViewTag.appicon.rawValue
            window.addSubview(appIconView)
        }

        PersistenceController.shared.save()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        let windowLevel = (scene as? UIWindowScene)?.windows.last?.windowLevel.rawValue
        passcodeLockPresenter.present(windowLevel: windowLevel)
    }

    func sceneDidBecomeActive(_: UIScene) {
        window?.viewWithTag(ViewTag.appicon.rawValue)?.removeFromSuperview()
        window?.viewWithTag(ViewTag.blur.rawValue)?.removeFromSuperview()
    }
}
