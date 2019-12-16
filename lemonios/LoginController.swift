//
//  LoginController.swift
//  杭电助手
//
//  Created by ljz on 2019/11/26.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
///Users/ljz/Desktop/HDU_IOS/lemonios/lemonios/AppDelegate.swift

import Foundation
import SwiftUI
import UIKit

class LoginController: UIHostingController<LoginView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: LoginView())
    //    let vc = self.presentingViewController?.children[0] as! ViewController
        self.rootView = LoginView(
            triggerWebViewFunc: {
                (self.presentingViewController?.children[0] as! ViewController).shortcutFired(nativeLogin: true)
            },
            triggerNewFuncGuideFunc: {
                let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
                let lastShowedVersion = Int(sharedUd?.string(forKey: "lastVersionGuided") ?? "0")
                let currentVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)
                if currentVersion ?? 0 > lastShowedVersion ?? 0 {
                    (self.presentingViewController?.children[0] as! ViewController).performSegue(withIdentifier: "gotoNewFuncGuide", sender: self)
                }
            },
            dismissFunc: {
                self.dismiss(animated: true)
            }
        )
    }
}

