//
//  Model.swift
//  杭电助手
//
//  Created by Shibo Lyu on 2020/6/28.
//  Copyright © 2020 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire

struct LMWidgetScheduleItem: Codable, Identifiable {
  var course: String
  var classroom: String
  var startTime: Date
  var endTime: Date
  var startTimeStr: String
  var endTimeStr: String
  var teacher: String
  var isTomorrow: Bool?

  var id: UUID { UUID() }

  var shortClassRoom: String {
    classroom.replacingOccurrences(of: "第(\\d+)教研楼(.+)", with: "$1教$2", options: [.regularExpression])
  }

  private struct ResponseData: Codable {
    var isTomorrow: Bool
    var scheduleSlots: [LMWidgetScheduleItem]
  }
  private struct Response: Codable {
    var data: ResponseData
  }
  
  static let common = SMWidgetCommon()

  static func fetchData (completion: @escaping ([Self]?) -> Void) {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970

    AF.request(
      "https://api.hduhelp.com/base/v2/student/schedule/now",
      headers: common.getHeaders()
    ).validate().responseDecodable(of: Response.self, decoder: decoder) { res in
      switch res.result {
      case .success(let response):
        var items = response.data.scheduleSlots
        if response.data.isTomorrow {
          items = items.map { item in
            var newItem = item
            newItem.isTomorrow = true
            return newItem
          }
        }
        completion(items)
      case .failure(let error):
        NSLog("error")
        NSLog(error.underlyingError.debugDescription)
        completion(nil)
      }
    }
  }
}
