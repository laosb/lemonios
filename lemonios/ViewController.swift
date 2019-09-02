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
import Alamofire

let primaryColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)

class ViewController: UIViewController, WKUIDelegate, INUIAddVoiceShortcutViewControllerDelegate {
    @available(iOS 12.0, *)
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 12.0, *)
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBOutlet weak var webView: WKWebView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configUrlTmpl = "https://config.hduhelp.com/%@.json"
        let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        let configUrl = String(format: configUrlTmpl, bundleId ?? "help.hdu.lemon.ios")
        
        Alamofire.request(configUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let json = response.result.value {
                    UserDefaults.standard.set((json as! NSDictionary).object(forKey: "baseUrl"), forKey: "baseUrl")
                }
            case .failure:
                let alert = UIAlertController(title: "😯喔", message: "杭电助手似乎无法连接到服务器，请检查您的网络连接。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "好", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.shortcutFired), name: Notification.Name(rawValue: "ShortcutFired"), object: nil)
        
        self.shortcutFired()
        
    }
    
    @objc private func shortcutFired () {
        let urlTemplate = "%@/?__shell_lemonios=%@&utm_source=lemonios/#"
        let fallbackBaseUrl = "https://ios.app.hduhelp.com"
        let baseUrl = UserDefaults.standard.string(forKey: "baseUrl") ?? fallbackBaseUrl
//        let baseUrl = "https://appdev.hduhelp.com" // Debug
//        let baseUrl = "https://client-config.hduhelp.lao.sb/lemon-bridge-test.html" // Debug

        let nativeVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        var urlStr = String(format: urlTemplate, baseUrl, nativeVersion ?? "unknown")
        
        if let shortcut = appDelegate.getShortcutItem() {
            if shortcut == "schedule" { urlStr += "/app/schedule" }
            if shortcut == "card" { urlStr += "/app/card" }
            if shortcut == "hdumap" {
                return self.performSegue(withIdentifier: "gotoHduMap", sender: self)
            }
        }
        
        // print(urlStr)
        let url = URL(string: urlStr)
        let req = URLRequest(url: url!)
        webView!.navigationDelegate = self
        webView!.uiDelegate = self
        webView!.load(req)
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
            safariView.preferredBarTintColor = primaryColor
            safariView.preferredControlTintColor = UIColor.white
            present(safariView, animated: true)
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    open func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
