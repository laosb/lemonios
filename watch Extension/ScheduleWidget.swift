//
//  ScheduleWidget.swift
//  watch Extension
//
//  Created by ljz on 2019/12/6.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI
import Alamofire
import Combine

struct LMScheduleData {
    var course: String?
    var classRoom: String?
    var isTomorrow: Bool?
    var startTime: String?
    var endTime: String?
    var teacher: String?
}


class LMSchedule: ObservableObject {
    @Published var LMData = Array<LMScheduleData>()
    @Published var available: Bool?
    init(_ token: String) {
        AF.request("https://api.hduhelp.com/base/student/schedule/now", headers: [
            "Authorization": "token \(token)",
            "User-Agent": "Alamofire Lemon_watchOS",
        ]).validate().responseJSON(completionHandler: { response in
            switch response.result {
                    case .success(let value):
                        let json = value
                        let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
                        let tempData = (newRawData.object(forKey: "Schedule") as! Array<NSDictionary>)
                        
                        for i in 0..<tempData.count {
                            let course = tempData[i].object(forKey: "COURSE") as! String
                            let classRoom = tempData[i].object(forKey: "CLASSROOM") as! String
                            let isTomorrow = newRawData.object(forKey: "IsTomorrow") as! Bool
                            let startTime = tempData[i].object(forKey: "STARTTIME") as! String
                            let endTime = tempData[i].object(forKey: "ENDTIME") as! String
                            let teacher = tempData[i].object(forKey: "TEACHER") as! String
                            
                            var tempSData = LMScheduleData()
                            tempSData.classRoom = classRoom
                            tempSData.course = course
                            tempSData.teacher = teacher
                            tempSData.isTomorrow = isTomorrow
                            tempSData.endTime = endTime
                            tempSData.startTime = startTime
                            
                            if tempSData.course != nil {
                                self.LMData.append(tempSData)
                            }
                        }
                        self.available = true
                    case .failure:
                        self.available = false
                }
            }
        )
    }
    
}


struct ScheduleWidget: View {
    
    @ObservedObject var scheduleData: LMSchedule
    
    
    init (_ token: String) {
        self.scheduleData = LMSchedule(token)
    }
    
    var body: some View {
        //GeometryReader {geometry in
            VStack {
                if self.scheduleData.available == nil || !self.scheduleData.available! {
                    VStack {
                        Text("获取课表失败，请尝试打开杭电助手并登录。嘤~")
                            .foregroundColor(.secondary)
                    }
                }
                else if self.scheduleData.LMData.count != 0 {
                        VStack {
                            scheduleDataView(realData: self.scheduleData.LMData[0])
                            if self.scheduleData.LMData.count >= 2 {
                                scheduleDataView(realData: self.scheduleData.LMData[1])
                                    .padding(.top)
                            }
                        }
                }
                else {
                    VStack(alignment: .center) {
                        Text("今明两天都没有课。享受生活！")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                
            }
       // }
    }
}

//struct ScheduleWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        ScheduleWidget()
//    }
//}
