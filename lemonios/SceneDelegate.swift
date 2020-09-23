//
//  SceneDelegate.swift
//  lemonios
//
//  Created by Shibo Lyu on 2019/11/22.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

//https://fleetingpixels.com/blog/2019/6/7/customising-nstoolbar-in-uikit-for-mac-marzipancatalyst

import UIKit
import os.log

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  var fired = false

  let app = UIApplication.shared.delegate as! AppDelegate

  func routeUrl(urlContexts: Set<UIOpenURLContext>) {
    if let url = urlContexts.first?.url {
      routeUrl(url: url)
    } else {
      fire(nativeLogin: false, route: nil)
    }
  }

  func fire(nativeLogin: Bool, route: String?) {
    if fired { return }
    fired = true
    let _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
      self.fired = false
    }
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateInitialViewController() as? UINavigationController
    window?.rootViewController = vc
    window?.makeKeyAndVisible()
    let innerVc = vc?.viewControllers[0] as? ViewController
    innerVc?.loadViewIfNeeded()
    innerVc?.shortcutFired(nativeLogin: nativeLogin, route: route)
  }

  func routeUrl(url: URL) {
    // MARK: URL Routing
    guard
      let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true)
    else {
      fire(nativeLogin: false, route: nil)
      return
    }
    let scheme = components.scheme
    let host = components.host
    let path = components.path
    let params = components.queryItems
    let hash = components.fragment

    if scheme != "hduhelplemon" && (host?.hasSuffix("hduhelp.com") ?? true) {
      UIApplication.shared.open(url)
    }

    if path == "/login", let auth = params?.first(where: { $0.name == "auth" }) {
      app.token = auth.value
      fire(nativeLogin: false, route: nil)
    } else {
      fire(nativeLogin: false, route: hash)
    }
  }

  func routeShortcut(_ shortcut: String) {
    let activities = ["schedule", "card"]
    let sc = String(shortcut.split(separator: ".").last ?? "")
    if activities.contains(sc) {
      fire(nativeLogin: false, route: "/app/\(sc)")
    }
  }


  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    // Use this method to optionally configure and attach the
    // UIWindow `window` to the provided UIWindowScene `scene`.

    // If using a storyboard, the `window` property will
    // automatically be initialized and attached to the scene.

    // This delegate doesn't imply the connecting scene or session are new
    // (see `application:configurationForConnectingSceneSession` instead).
    guard let _ = (scene as? UIWindowScene) else { return }

    #if targetEnvironment(macCatalyst)
    if let windowScene = scene as? UIWindowScene {
      windowScene.sizeRestrictions?.minimumSize = CGSize(width: 700, height: 400)
      if let titlebar = windowScene.titlebar {
        titlebar.toolbar?.isVisible = false
        titlebar.titleVisibility = .hidden
      }
    }
    #endif
    os_log("sh item %@", connectionOptions.shortcutItem?.type ?? "")
    if let shortcutItem = connectionOptions.shortcutItem {
      routeShortcut(shortcutItem.type)
    }
    routeUrl(urlContexts: connectionOptions.urlContexts)
  }

  func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
      if let url = userActivity.webpageURL {
        routeUrl(url: url)
      }
    } else {
      fire(nativeLogin: false, route: nil)
    }
  }

  func windowScene(
    _ windowScene: UIWindowScene,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    routeShortcut(shortcutItem.type)
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    routeUrl(urlContexts: URLContexts)
  }

  func sceneDidDisconnect(_ scene: UIScene) {}
  func sceneDidBecomeActive(_ scene: UIScene) {}
  func sceneWillResignActive(_ scene: UIScene) {}
  func sceneWillEnterForeground(_ scene: UIScene) {}
  func sceneDidEnterBackground(_ scene: UIScene) {}
}
