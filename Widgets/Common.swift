//
//  Common.swift
//  杭电助手
//
//  Created by Shibo Lyu on 2020/12/7.
//  Licensed under MIT License (https://laosb.mit-license.org).
//

import Foundation
import Alamofire
import SwiftUI

struct SMWidgetCommon {
  static let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")

  var token: String? { Self.sharedUd?.string(forKey: "token") }
  var version: String? {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  }
  
  func getHeaders () -> HTTPHeaders {
    [
      "User-Agent": "Lemon_iOS_WidgetKit/\(version ?? "Unknown") Lemon_iOS/\(version ?? "Unknown") Alamofire Lemon_iOS",
      "Authorization": "token \(token ?? "")"
    ]
  }

  func errorView () -> some View {
    Group {
      Spacer()
      Text("发生错误").opacity(0.8)
      Spacer()
    }
  }
}
