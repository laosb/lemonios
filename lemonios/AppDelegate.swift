//
//  AppDelegate.swift
//  lemonios
//
//  Created by Wexpo Lyu on 2019/5/25.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Alamofire
import DeviceKit

struct LMDeviceInfo: Encodable {
    let DeviceToken: String
    let DeviceDesc: String
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    var shortcutName: String?
    var token: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: (Bool) -> Void) {
        
        completionHandler(handleShortcut(shortcutItem))
    }
    
    //https://fleetingpixels.com/blog/2019/6/7/customising-nstoolbar-in-uikit-for-mac-marzipancatalyst
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            // Called when a new scene session is being created.
            // Use this method to select a configuration to create
            // the new scene with.
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
            // Called when the user discards a scene session.
            // If any sessions were discarded while the application
            // was not running, this will be called shortly after
            // application:didFinishLaunchingWithOptions.
      
            // Use this method to release any resources that were
            // specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if #available(iOS 12.0, *) {
            let activities = ["schedule", "card"]
            let activity = String(userActivity.activityType.split(separator: ".").last ?? "")
            if activities.contains(activity) {
                self.shortcutName = activity
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ShortcutFired")))
                userActivity.becomeCurrent()
            }
        }
        return true
    }
    
    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
        let userToken = sharedUd?.string(forKey: "token")
        
        // https://github.com/devicekit/DeviceKit/issues/214
        #if targetEnvironment(macCatalyst)
        let deviceDesc = "Mac"
        #else
        let deviceDesc = Device.current.description
        #endif
        let deviceInfo: Parameters = [
            "DeviceToken": token,
            "DeviceDesc": deviceDesc,
            "DeviceType": "apple"
        ]
        
        #if DEBUG
        let tokenReportUrl = "https://api.hduhelp.com/devices/token?debug=1"
        #else
        let tokenReportUrl = "https://api.hduhelp.com/devices/token"
        #endif
        
        Alamofire.request(
            tokenReportUrl,
            method: .post,
            parameters: deviceInfo,
            encoding: JSONEncoding.default,
            headers:["Authorization": "token \(userToken ?? "")", "User-Agent": "Alamofire Lemon_iOS"]
        ).validate().responseJSON { response in
//            print(response)
        }
//      print("Device Token: \(token)")
    }

    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error) {
//      print("Failed to register: \(error)")
    }
    
    private func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        self.shortcutName = String(shortcutItem.type.split(separator: ".").last ?? "")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ShortcutFired")))
        NSUserActivity(activityType: shortcutItem.type).becomeCurrent()
        return true
    }
    
    func getShortcutItem() -> String? {
        let sc = self.shortcutName
        self.shortcutName = nil
        return sc
    }
    
    func getIncomingToken() -> String? {
        let token = self.token
        self.token = nil
        return token
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "lemonios")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Mac Catalyst Menu Support
    
    #if targetEnvironment(macCatalyst)
    
    var menuController: MenuController!
    
    /** Add the various menus to the menu bar.
        The system only asks UIApplication and UIApplicationDelegate for the main menus.
        Main menus appear regardless of who is in the responder chain.
    
        Note: These menus and menu commands are localized to Chinese (Simplified) in this sample.
        To change the app to run in to Chinese, refer to Xcode Help on Testing localizations:
            https://help.apple.com/xcode/mac/current/#/dev499a9529e
    */
    override func buildMenu(with builder: UIMenuBuilder) {
        
        /** First check if the builder object is using the main system menu, which is the main menu bar.
            If you want to check if the builder is for a contextual menu, check for: UIMenuSystem.context
         */
        if builder.system == .main {
            menuController = MenuController(with: builder)
        }
    }
    
    #endif

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

