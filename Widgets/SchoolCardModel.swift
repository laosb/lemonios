//
//  SchoolCard.swift
//  杭电助手
//
//  Created by Shibo Lyu on 2020/12/7.
//  Licensed under MIT License (https://laosb.mit-license.org).
//

import Foundation
import Alamofire

struct SMWidgetSchoolCardData: Codable {
  struct Record: Codable {
    var createTime: Date?
    var deviceName: String
    var deviceNum: String
    var feeName: String
    var remaining: Float?
    var totalFee: Float?
  }
  
  var remaining: Float?
  var flow: [Record]
  
  private struct Response: Codable {
    var data: SMWidgetSchoolCardData
  }
  
  static let common = SMWidgetCommon()
  
  static func fetchData (completion: @escaping (Self?) -> Void) {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    
    AF.request(
      "https://api.hduhelp.com/salmon_base/card/info",
      headers: common.getHeaders()
    ).validate().responseDecodable(of: Response.self, decoder: decoder) { res in
      switch res.result {
      case let .success(resp):
        completion(resp.data)
      case .failure(let error):
        NSLog("error")
        NSLog(error.underlyingError.debugDescription)
        completion(nil)
      }
    }
  }
}
