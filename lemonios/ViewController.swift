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
import WatchConnectivity
import Alamofire
import DeviceKit

let primaryColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)

class ViewController: UIViewController, WKUIDelegate, INUIAddVoiceShortcutViewControllerDelegate, WCSessionDelegate {
    
    var wcSession : WCSession! = nil
    var token: String? = nil
    
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
    @IBOutlet weak var loadingCover: UIView!
    
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
        let currentVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        Alamofire.request(configUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                let json = response.result.value
                //print("!!!!!!")
                //print(json)
                var title: String?
                var desc: String?
                var link: String?
                var group: String?
                var isForce: Bool?
                if json != nil && currentVersion < "38"{
                    let NS = json as! NSDictionary
                    //print(NS)
                    title = (NS.object(forKey: "testflightDialogTitle") as? String ?? nil)
                    desc = (NS.object(forKey: "testflightDialogDesc") as? String ?? nil)
                    link = (NS.object(forKey: "testflightLink") as? String ?? nil)
                    isForce = (NS.object(forKey: "forceTestflight") as? Bool ?? nil)
                    group = (NS.object(forKey: "testflightGroupLink") as? String ?? nil)
                }
//                title = "内测邀请"
//                desc = "我们诚挚邀请您参与杭电助手内测"
//                group = "https://qm.qq.com/cgi-bin/qm/qr?k=js9HOOUhRumi_NZCmpYdy4UVeuy9t39h&authKey=bv%2BglKZnvToSgmWvUAkc0ZtM%2FS%2FQfTg0NofbWL76quK9BC0RDRhMTUpSR8hp70%2Fv"
//                isForce = false
//                link = "https://qm.qq.com/cgi-bin/qm/qr?k=js9HOOUhRumi_NZCmpYdy4UVeuy9t39h&authKey=bv%2BglKZnvToSgmWvUAkc0ZtM%2FS%2FQfTg0NofbWL76quK9BC0RDRhMTUpSR8hp70%2Fv"
//                print("@@@@")
//                print(title!)
//                print(desc!)
//                print(link!)
//                print(group)
//                print("@@@@")
                if title != nil && desc != nil && link != nil && group != nil {
                    print("????")
                    let alert = UIAlertController(title: "\(title!)", message: "\(desc!)", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                    if isForce == false {
                        alert.addAction(cancelAction)
                        alert.addAction(UIAlertAction(title: "加入内测群", style: .default, handler: { _ in
                            UIApplication.shared.open(URL(string: "\(group!)")!)
                        }))
                        alert.addAction(UIAlertAction(title: "参与内测", style: .default, handler: { _ in
                            UIApplication.shared.open(URL(string: "\(link!)")!)
                        }))
                    }
                    else if isForce == true {
                        alert.addAction(UIAlertAction(title: "加入内测群", style: .default, handler: { _ in
                            UIApplication.shared.open(URL(string: "\(group!)")!)
                        }))
                        alert.addAction(UIAlertAction(title: "参与内测", style: .default, handler: { _ in
                            UIApplication.shared.open(URL(string: "\(link!)")!)
                        }))
                    }
                    self.present(alert, animated: true, completion: nil)
                }
                if json != nil {
                    self.shortcutFired(nativeLogin: false)
                }
                
            case .failure:
                let alert = UIAlertController(title: "连接服务器失败", message: "请检查您是否允许杭电助手联网，以及您设备的网络连接。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "重试", style: .default, handler: { _ in self.tryLoad(configUrl) }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
//    func alertLoad(_ configUrl: String) {
//        Alamofire.request(configUrl).validate().responseJSON { response in
//            switch response.result {
//            case .success:
//                if let json = response.result.value {
//                    UserDefaults.standard.set((json as! NSDictionary).object(forKey: "testFiligt"), forKey: "baseUrl")
//                }
//                let alert = UIAlertController(title: "内测邀请", message: "亲爱的杭电助手用户，我们诚挚邀请您参与我们的内测活动", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "加入内测群", style: .default, handler: { _ in
//                    UIApplication.shared.open(URL(string: "https://qm.qq.com/cgi-bin/qm/qr?k=js9HOOUhRumi_NZCmpYdy4UVeuy9t39h&authKey=bv%2BglKZnvToSgmWvUAkc0ZtM%2FS%2FQfTg0NofbWL76quK9BC0RDRhMTUpSR8hp70%2Fv")!)
//                }))
//                alert.addAction(UIAlertAction(title: "参与内测", style: .default, handler: { _ in
//                    UIApplication.shared.open(URL(string: "https://qm.qq.com/cgi-bin/qm/qr?k=js9HOOUhRumi_NZCmpYdy4UVeuy9t39h&authKey=bv%2BglKZnvToSgmWvUAkc0ZtM%2FS%2FQfTg0NofbWL76quK9BC0RDRhMTUpSR8hp70%2Fv")!)
//                }))
//                self.present(alert, animated: true, completion: nil)
//            case .failure:
//                break
//                let alert = UIAlertController(title: "连接服务器失败", message: "请检查您是否允许杭电助手联网，以及您设备的网络连接。", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "重试", style: .default, handler: { _ in self.alertLoad(configUrl) }))
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//    }
    
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
        self.token = token
        
        if (savedVersion == nil || (currentVersion ?? 0) > (savedVersion ?? 0)) && token != nil{
            self.performSegue(withIdentifier: "gotoNewFuncGuide", sender: self)
        }
        
        if token != nil {
            wcSession = WCSession.default
            wcSession.delegate = self
            wcSession.activate()
        }
        
        Alamofire.request("https://api.hduhelp.com/token/validate", encoding: JSONEncoding.default, headers:["Authorization": "token \(token ?? "")", "User-Agent": "Alamofire Lemon_iOS"]).validate().responseJSON {
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            if webView.estimatedProgress == 1.0 {
                loadingCover.isHidden = true
            } else {
                loadingCover.isHidden = false
            }
        }
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
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
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
        //print(urlStr)
        let req = URLRequest(url: url!)
        webView!.load(req)
        
        // Try to get the token
        getTokenTimer?.invalidate()
        getTokenTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
//            print("try to get token")
            self.webView!.evaluateJavaScript("""
                (() => {
                    window._setupDebug(19260817)
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
                //print("get logout")
                self.performSegue(withIdentifier: "gotoLogin", sender: self)
            }
            if (url!.pathComponents.contains("toggleDev")) {
                let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
                sharedUd?.set(sharedUd?.bool(forKey: "dev"), forKey: "dev")
                sharedUd?.synchronize()
            }
            if (url!.pathComponents.contains("setIcon")) {
                let iconName = url!.lastPathComponent
//                print("icon name", iconName)
                if iconName == "default" {
                    UIApplication.shared.setAlternateIconName(nil)
                } else {
                    UIApplication.shared.setAlternateIconName(iconName)
                }
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
    
    // MARK: WCSession Methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //print("yes go")
        
        let message = [ "token": self.token ?? "" ]
        wcSession.sendMessage(message, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
        // Code
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
        // Code
        
    }
    
//    open func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
}
