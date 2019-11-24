//
//  MenuController.swift
//  lemonios
//
//  Created by Shibo Lyu on 2019/11/23.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import UIKit

class MenuController {
    init(with builder: UIMenuBuilder) {
        builder.remove(menu: .format)
        builder.remove(menu: .file)
        builder.remove(menu: .help)
    }
}
