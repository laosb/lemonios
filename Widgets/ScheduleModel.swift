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
    let id = UUID()
    
    var course: String
    var classRoom: String
    var startTime: String
    var endTime: String
    var teacher: String
    var isTomorrow: Bool = false
    
    private func baseDate () -> Date {
        isTomorrow
            ? Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
            : Calendar.current.startOfDay(for: Date())
    }
    private func dateFromTimeString (_ str: String, baseDate: Date) -> Date {
        let components = str.split(separator: ":").map { Int($0) }
        return Calendar.current.date(
            bySettingHour: components[0] ?? 0,
            minute: components[1] ?? 0,
            second: 0,
            of: baseDate
        ) ?? baseDate
    }
    
    var startTimeInDate: Date {
        dateFromTimeString(startTime, baseDate: baseDate())
    }
    var endTimeInDate: Date {
        dateFromTimeString(endTime, baseDate: baseDate())
    }
    var shortClassRoom: String {
        classRoom.replacingOccurrences(of: "第(\\d+)教研楼(.+)", with: "$1教$2", options: [.regularExpression])
    }
    
    enum CodingKeys: String, CodingKey {
        case course = "COURSE"
        case classRoom = "CLASSROOM"
        case startTime = "STARTTIME"
        case endTime = "ENDTIME"
        case teacher = "TEACHER"
    }
    
    private struct ResponseData: Codable {
        var isTomorrow: Bool
        var schedule: [LMWidgetScheduleItem]
        
        enum CodingKeys: String, CodingKey {
            case isTomorrow = "IsTomorrow"
            case schedule = "Schedule"
        }
    }
    private struct Response: Codable {
        var data: ResponseData
    }
    
    private static var token: String? {
        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
        return sharedUd?.string(forKey: "token")
    }
    private static var version: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static func fetchData (completion: @escaping ([Self]?) -> Void) {
        AF.request(
            "https://api.hduhelp.com/base/student/schedule/now",
            headers: [
                "User-Agent": "Lemon_iOS_WidgetKit/\(Self.version ?? "Unknown") Lemon_iOS/\(Self.version ?? "Unknown") Alamofire Lemon_iOS",
                "Authorization": "token \(Self.token ?? "")"
            ]
        ).validate().responseDecodable(of: Response.self) { res in
            switch res.result {
            case .success(let response):
                var items = response.data.schedule
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
                NSLog(error.errorDescription!)
                completion(nil)
            }
        }
    }
}
