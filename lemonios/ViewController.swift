//
//  ViewController.swift
//  lemonios
//
//  Created by Wexpo Lyu on 2019/5/25.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
import Alamofire

let primaryColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)

class ViewController: UIViewController, WKUIDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let configUrlTmpl = "https://client-config.hduhelp.lao.sb/%@.json"
        let urlTemplate = "%@/?__shell_lemonios=%@&utm_source=lemonios/#"
        let fallbackBaseUrl = "https://ios--hduhelp-fe.netlify.com"
        let baseUrl = UserDefaults.standard.string(forKey: "baseUrl") ?? fallbackBaseUrl
        let nativeVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
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
        
        let urlStr = String(format: urlTemplate, baseUrl, nativeVersion ?? "unknown")
        // print(urlStr)
        let url = URL(string: urlStr)
        let req = URLRequest(url: url!)
        webView!.navigationDelegate = self
        webView!.uiDelegate = self
        webView!.load(req)
    }

}

extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            let url = navigationAction.request.url
            let safariView = SFSafariViewController(url: url!)
            safariView.preferredBarTintColor = primaryColor
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
