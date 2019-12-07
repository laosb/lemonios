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
import DeviceKit

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
//        print("Notification settings: \(settings)")
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
        #if targetEnvironment(macCatalyst)
        self.webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.webView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        self.view.layoutIfNeeded()
        #endif
        if Device.current.isPad {
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
    }
    
    func tryLoad(_ configUrl: String) {
        Alamofire.request(configUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let json = response.result.value {
                    UserDefaults.standard.set((json as! NSDictionary).object(forKey: "baseUrl"), forKey: "baseUrl")
                    self.shortcutFired(nativeLogin: false)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.shortcutFired), name: Notification.Name(rawValue: "ShortcutFired"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.shortcutFired), name: Notification.Name(rawValue: "IncomingToken"), object: nil)
        
        let configUrlTmpl = "https://config.hduhelp.com/%@.json"
        let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        let configUrl = String(format: configUrlTmpl, bundleId ?? "help.hdu.lemon.ios")
        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
//        var isDelay = false
        
        let currentVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)
        let savedVersion = sharedUd?.integer(forKey: "lastVersionGuided")
//        print(currentVersion, savedVersion)
        let token = sharedUd?.string(forKey: "token")
        
        if (savedVersion == nil || (currentVersion ?? 0) > (savedVersion ?? 0)) && token != nil{
            self.performSegue(withIdentifier: "gotoNewFuncGuide", sender: self)
        }
        
        Alamofire.request("https://api.hduhelp.com/token/validate", encoding: JSONEncoding.default, headers:["Authorization": "token \(token ?? "")"]).validate().responseJSON {
            response in switch response.result {
                case .success:
                    //self.tryLoad(configUrl)
                    let json = response.result.value
                    let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
                    let isValid = (newRawData.object(forKey: "isValid")) as! Bool
                    if isValid == false {
                        return self.performSegue(withIdentifier: "gotoLogin", sender: self)
                    }
                case .failure:
                    return self.performSegue(withIdentifier: "gotoLogin", sender: self)
//                    isDelay = true
                    //self.tryLoad(configUrl)
//                    print("!!!!!!!!!!!!!!!!!!")
            }
        }
        tryLoad(configUrl)
//        if isDelay == true {
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
//                // Put your code which should be executed with a delay here
//                let url = "https://ios.app.hduhelp.com/#/login?auth="+"\(token)"
//
//                //ios.app.hduhelp.com/#/login?auth={token}
//            })
//        }else {
//            let url = "https://ios.app.hduhelp.com/#/login?auth="+"\(token)"
//            self.tryLoad(url)
//        }
//
    }
    
    @objc func shortcutFired (nativeLogin: Bool) {
        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
        
        #if targetEnvironment(macCatalyst)
        let shellCode = "lemonmac"
        #else
        let shellCode = "lemonios"
        #endif
        let urlTemplate = "%@/?__shell_\(shellCode)=%@%@&utm_source=\(shellCode)/#"
        let fallbackBaseUrl = "https://ios.app.hduhelp.com"
        var baseUrl = ""
        var isDev = ""
        if sharedUd?.bool(forKey: "dev") ?? false {
            baseUrl = "https://appdev.hduhelp.com"
            isDev = "_running_lemon_devel"
        } else {
            baseUrl = UserDefaults.standard.string(forKey: "baseUrl") ?? fallbackBaseUrl
        }
//        let baseUrl = "https://ios.app.hduhelp.com" // Debug
//        let baseUrl = "https://client-config.hduhelp.lao.sb/lemon-bridge-test.html" // Debug

        let nativeVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        webView!.navigationDelegate = self
        webView!.uiDelegate = self
        var urlStr = String(format: urlTemplate, baseUrl, nativeVersion ?? "unknown", isDev)
        
        if let token = appDelegate.getIncomingToken() {
            urlStr += "/login?auth=\(token)"
            sharedUd?.set(token, forKey: "token")
            sharedUd?.synchronize()
            if token != "" {
                enableNotification()
            }
        } else if nativeLogin == true {
            let token = sharedUd?.string(forKey: "token")
            urlStr += "/login?auth=\(token ?? "")"
            enableNotification()
        } else if let shortcut = appDelegate.getShortcutItem() {
            if shortcut == "schedule" { urlStr += "/app/schedule" }
            if shortcut == "card" { urlStr += "/app/card" }
//            if shortcut == "hdumap" {
//                return self.performSegue(withIdentifier: "gotoHduMap", sender: self)
//            }
        }
        
//        print(urlStr)
        
        if nativeLogin == true {
            webView.load(URLRequest(url: URL(string: "about:blank")!))
        }
        let url = URL(string: urlStr)
        print(urlStr)
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
//        case OpenHdumap = "hdumap"
    }
    
    func setupIntentForSiri(_ action: LemonAction) {
        #if !targetEnvironment(macCatalyst)
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
    //            case .OpenHdumap:
    //                actionIdentifier = "help.hdu.lemon.ios.hdumap"
    //                activity = NSUserActivity(activityType: actionIdentifier)
    //                activity.title = "打开杭电地图"
    //                activity.userInfo = ["speech" : "杭电地图"]
            }
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            activity.persistentIdentifier = NSUserActivityPersistentIdentifier(actionIdentifier)
            let shortcut = INShortcut(userActivity: activity)
            let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        #endif
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
            if (url!.pathComponents.contains("logout")) {
                let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
                sharedUd?.set(nil, forKey: "token")
                sharedUd?.synchronize()
                print("get logout")
                self.performSegue(withIdentifier: "gotoLogin", sender: self)
            }
            if (url!.pathComponents.contains("toggleDev")) {
                let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
                sharedUd?.set(sharedUd?.bool(forKey: "dev"), forKey: "dev")
                sharedUd?.synchronize()
            }
//            if (url!.pathComponents.contains("hduMap")) {
//                self.performSegue(withIdentifier: "gotoHduMap", sender: self)
//            }
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
