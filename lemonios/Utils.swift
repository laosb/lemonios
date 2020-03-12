//
//  Utils.swift
//  杭电助手
//
//  Created by Shibo Lyu on 2020/3/12.
//  Copyright © 2020 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import Foundation
import UIKit

struct LMUtils {
    
    // https://stackoverflow.com/a/27203691
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor(named: "status_bar_color")!
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
