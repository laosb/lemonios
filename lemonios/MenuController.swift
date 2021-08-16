//
//  MenuController.swift
//  lemonios
//
//  Created by Shibo Lyu on 2019/11/23.
//  Licensed under MIT License (https://laosb.mit-license.org).
//

import UIKit

class MenuController {
    init(with builder: UIMenuBuilder) {
        builder.remove(menu: .format)
        builder.remove(menu: .file)
        builder.remove(menu: .help)
    }
}
