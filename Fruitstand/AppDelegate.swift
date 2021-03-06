//
//  AppDelegate.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/14/22.
//

import Foundation
import SwiftUI
import SwiftCSV


class AppDelegate: NSObject, UIApplicationDelegate {
    
    var shortcutItem: UIApplicationShortcutItem? { AppDelegate.shortcutItem }

    static var shortcutItem: UIApplicationShortcutItem?

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            AppDelegate.shortcutItem = shortcutItem
        }

        let sceneConfiguration = UISceneConfiguration(
            name: "Scene Configuration",
            sessionRole: connectingSceneSession.role
        )
        sceneConfiguration.delegateClass = SceneDelegate.self

        return sceneConfiguration
    }
}

private final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(
        _: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        AppDelegate.shortcutItem = shortcutItem
        completionHandler(true)
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
        if AppDelegate.shortcutItem != nil {
            AppDelegate.shortcutItem = nil
        }
    }
}
