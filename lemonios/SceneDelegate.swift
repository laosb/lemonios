//
//  SceneDelegate.swift
//  lemonios
//
//  Created by Shibo Lyu on 2019/11/22.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

//https://fleetingpixels.com/blog/2019/6/7/customising-nstoolbar-in-uikit-for-mac-marzipancatalyst

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let app = UIApplication.shared.delegate as! AppDelegate
    
    func routeUrl(urlContexts: Set<UIOpenURLContext>) {
        if let url = urlContexts.first?.url {
            app.routeUrl(url: url, window: window)
        }
    }
    
    func routeUrl(url: URL) {
        app.routeUrl(url: url, window: window)
    }
    
    func routeShortcut(_ shortcut: String) {
        let activities = ["schedule", "card"]
        let sc = String(shortcut.split(separator: ".").last ?? "")
        if activities.contains(sc) {
            app.shortcutName = sc
            
            let naviVc = window?.rootViewController as? UINavigationController
            let vc = naviVc?.topViewController as? ViewController
            vc?.shortcutFired(nativeLogin: false, route: nil)
        }
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the
        // UIWindow `window` to the provided UIWindowScene `scene`.
      
        // If using a storyboard, the `window` property will
        // automatically be initialized and attached to the scene.
      
        // This delegate doesn't imply the connecting scene or session are new
        // (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        #if targetEnvironment(macCatalyst)
        if let windowScene = scene as? UIWindowScene {
            if let titlebar = windowScene.titlebar {
                titlebar.titleVisibility = .hidden
                titlebar.autoHidesToolbarInFullScreen = true
            }
        }
        #endif
        print("url in first")
        if let shortcutItem = connectionOptions.shortcutItem {
            routeShortcut(shortcutItem.type)
        }
        routeUrl(urlContexts: connectionOptions.urlContexts)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("activity", userActivity.activityType)
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                routeUrl(url: url)
            }
        }
    }
    
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        print("shortcut in")
        routeShortcut(shortcutItem.type)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("url in")
        routeUrl(urlContexts: URLContexts)
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
