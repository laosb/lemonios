//
//  ViewController.swift
//  lemonios
//
//  Created by Wexpo Lyu on 2019/5/25.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import UIKit
import WebKit
import IntentsUI
import SafariServices
import UserNotifications
import Alamofire

let primaryColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)

class ViewController: UIViewController, WKUIDelegate, INUIAddVoiceShortcutViewControllerDelegate {
    func enableNotification () {
        UNUserNotificationCenter.current()
          .requestAuthorization(options: [.alert, .sound, .badge]) {
            [weak self] granted, error in
              
//            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBOutlet weak var webView: WKWebView!
    
    weak var getTokenTimer: Timer?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func tryLoad(_ configUrl: String) {
        Alamofire.request(configUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let json = response.result.value {
                    UserDefaults.standard.set((json as! NSDictionary).object(forKey: "baseUrl"), forKey: "baseUrl")
                    self.shortcutFired()
                }
            case .failure:
                let alert = UIAlertController(title: "连接服务器失败", message: "请检查您是否允许杭电助手联网，以及您设备的网络连接。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "重试", style: .default, handler: { _ in self.tryLoad(configUrl) }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configUrlTmpl = "https://config.hduhelp.com/%@.json"
        let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        let configUrl = String(format: configUrlTmpl, bundleId ?? "help.hdu.lemon.ios")
        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
        
        let currentVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)
        let savedVersion = sharedUd?.integer(forKey: "lastVersionGuided")
//        print(currentVersion, savedVersion)
        if savedVersion == nil || (currentVersion ?? 0) > (savedVersion ?? 0) {
            self.performSegue(withIdentifier: "gotoNewFuncGuide", sender: self)
        }
        
        tryLoad(configUrl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.shortcutFired), name: Notification.Name(rawValue: "ShortcutFired"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.shortcutFired), name: Notification.Name(rawValue: "IncomingToken"), object: nil)
    }
    
    @objc private func shortcutFired () {
        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")

        let urlTemplate = "%@/?__shell_lemonios=%@&utm_source=lemonios/#"
        let fallbackBaseUrl = "https://ios.app.hduhelp.com"
        let baseUrl = UserDefaults.standard.string(forKey: "baseUrl") ?? fallbackBaseUrl
//        let baseUrl = "https://appdev.hduhelp.com" // Debug
//        let baseUrl = "https://client-config.hduhelp.lao.sb/lemon-bridge-test.html" // Debug

        let nativeVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        webView!.navigationDelegate = self
        webView!.uiDelegate = self
        var urlStr = String(format: urlTemplate, baseUrl, nativeVersion ?? "unknown")
        
        if let token = appDelegate.getIncomingToken() {
            urlStr += "/login?auth=\(token)"
            sharedUd?.set(token, forKey: "token")
            sharedUd?.synchronize()
            if token != "" {
                enableNotification()
            }
        } else if let shortcut = appDelegate.getShortcutItem() {
            if shortcut == "schedule" { urlStr += "/app/schedule" }
            if shortcut == "card" { urlStr += "/app/card" }
            if shortcut == "hdumap" {
                return self.performSegue(withIdentifier: "gotoHduMap", sender: self)
            }
        }
        
//        print(urlStr)
        let url = URL(string: urlStr)
        let req = URLRequest(url: url!)
        webView!.load(req)
        
        // Try to get the token
        getTokenTimer?.invalidate()
        getTokenTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
//            print("try to get token")
            self.webView!.evaluateJavaScript("""
                (() => {
                    window._setupDebug(19260817)
                    const siwaBtn = document.getElementById('appleid-signin')
                    if (siwaBtn) {
                        siwaBtn.onclick = () => {
                            console.log('Try SIWA')
                            const btnLink = document.createElement('a')
                            btnLink.href = "https://api.hduhelp.com/login/direct/apple?clientID=app&redirect=hduhelplemon%3A%2F%2Fapp.hduhelp.com"
                            document.body.appendChild(btnLink)
                            btnLink.click()
                        }
                    }
                    return window._hduhelpDebug.store.state.token || null
                })()
            """, completionHandler: { returnValue, error in
                if returnValue != nil && error == nil {
                    let token = returnValue as? String
                    if token != nil && token != "" {
                        sharedUd?.set(token, forKey: "token")
                        sharedUd?.synchronize()
                        self.enableNotification()
                        timer.invalidate()
                    }
//                    print("user token:", token)
                }
            })
        })
    }
    
    enum LemonAction: String {
        case OpenSchedule = "schedule"
        case OpenCard = "card"
        case OpenHdumap = "hdumap"
    }
    
    func setupIntentForSiri(_ action: LemonAction) {
        var activity: NSUserActivity
        var actionIdentifier: String
        switch (action) {
            case .OpenSchedule:
                actionIdentifier = "help.hdu.lemon.ios.schedule"
                activity = NSUserActivity(activityType: actionIdentifier)
                activity.title = "打开课表"
                activity.userInfo = ["speech" : "课表"]
            case .OpenCard:
                actionIdentifier = "help.hdu.lemon.ios.card"
                activity = NSUserActivity(activityType: actionIdentifier)
                activity.title = "查看一卡通情况"
                activity.userInfo = ["speech" : "一卡通"]
            case .OpenHdumap:
                actionIdentifier = "help.hdu.lemon.ios.hdumap"
                activity = NSUserActivity(activityType: actionIdentifier)
                activity.title = "打开杭电地图"
                activity.userInfo = ["speech" : "杭电地图"]
        }
        activity.isEligibleForSearch = true
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
            activity.persistentIdentifier = NSUserActivityPersistentIdentifier(actionIdentifier)
            let shortcut = INShortcut(userActivity: activity)
            let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        getTokenTimer?.invalidate()
    }

}

extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.request.url?.host == "lemon-bridge.help.hdu.party" {
            let url = navigationAction.request.url
            if (url!.pathComponents.contains("addSiriShortcut")) {
                self.setupIntentForSiri(LemonAction(rawValue: url!.lastPathComponent)!)
            }
            if (url!.pathComponents.contains("hduMap")) {
                self.performSegue(withIdentifier: "gotoHduMap", sender: self)
            }
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            let url = navigationAction.request.url
            let safariView = SFSafariViewController(url: url!)
            safariView.preferredControlTintColor = primaryColor
            present(safariView, animated: true)
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
//    open func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
}
