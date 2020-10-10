//
//  NewFuncGuideController.swift
//  lemonios
//
//  Created by Shibo Lyu on 2019/11/12.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class NewFuncGuideController: UIHostingController<NewFuncView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: NewFuncView())
        self.rootView = NewFuncView {
            self.dismiss(animated: true)
        }
    }
}
