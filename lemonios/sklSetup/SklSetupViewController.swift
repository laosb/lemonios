//
//  SklSetupViewController.swift
//  杭电助手
//
//  Created by Shibo Lyu on 2020/10/9.
//  Copyright © 2020 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class SklSetupViewController: UIHostingController<SklSetupView> {
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder, rootView: SklSetupView())
    self.rootView = SklSetupView {
      self.dismiss(animated: true)
    }
  }
}
