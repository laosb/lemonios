//
//  HostingController.swift
//  watch Extension
//
//  Created by Shibo Lyu on 2019/12/6.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

// https://medium.com/better-programming/watchconnectivity-swift-1f8cffb7c7a9

import WatchKit
import WatchConnectivity
import Foundation
import SwiftUI

class HostingController: WKHostingController<ContentView>, WCSessionDelegate {
    
    let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
    
    var wcSession : WCSession!
    var token: String?
    
    override func willActivate() {
        super.willActivate()
        
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
        
        let token = sharedUd?.string(forKey: "token")
        
        if token != nil {
//            print("token get")
            self.token = token
            self.setNeedsBodyUpdate()
            self.updateBodyIfNeeded()
        }
    }
    
    override var body: ContentView {
        return ContentView(token: self.token ?? "")
    }
    
    // MARK: WCSession Methods
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        let text = message["token"] as! String
        
        self.token = text
//        print(self.token)
        
        self.sharedUd?.set(token, forKey: "token")
        self.sharedUd?.synchronize()
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //code
    }
}
