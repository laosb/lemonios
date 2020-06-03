//
//  BindController.swift
//  杭电助手
//
//  Created by ljz on 2020/6/2.
//  Copyright © 2020 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class BindController: UIHostingController<BindView> {
    var url: URL?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: BindView())
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(500), execute: {
        //                // Put your code which should be executed with a delay here
            print(self.url)
            
            self.rootView = BindView(
                url: self.url,
                dismissFunc: {
                    self.dismiss(animated: true)
                }
            )
        })
        
    }
    override func viewDidLoad() {
        print("didload")
        self.rootView = BindView.init(url: self.url, dismissFunc: {self.dismiss(animated: true)})
    }
}
