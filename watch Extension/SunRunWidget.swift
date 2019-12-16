//
//  SunRunWidget.swift
//  watch Extension
//
//  Created by ljz on 2019/12/6.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI
import Combine
import Alamofire

class LMWidgetSunRun: ObservableObject{
    @Published var speed: String?
    @Published var validTimes: Int?
    @Published var mileage: Int?
    @Published var isValid: Bool?
    @Published var domain: String?
    @Published var date: String?
    @Published var endTime: String?
    @Published var runTimes: Int?
    @Published var token: String?
    @Published var available: Bool?
    
    init(_ token: String) {
        Alamofire.request("https://api.hduhelp.com/infoStream/v3", headers:["Authorization": "token \(token)", "User-Agent": "Alamofire Lemon_iOS"]).validate().responseJSON(completionHandler:
                        {
                            response in switch response.result
                            {
                                case .success:
        //                            print(response.result)
                                    let json = response.result.value
                                    let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
                                    let SunRunData = newRawData.object(forKey: "sunrun") as? NSDictionary
                                    
                                    self.available = SunRunData?.object(forKey: "available") as? Bool
                                    let indexData = SunRunData?.object(forKey: "data") as? NSDictionary
                                    self.endTime = indexData?.object(forKey: "endTime") as? String
                                    let latestData = indexData?.object(forKey: "latest") as? NSDictionary
                                    self.domain = latestData?.object(forKey: "domain") as? String
                                    self.isValid = latestData?.object(forKey: "isvalid") as? Bool
                                    let tempSpeed = latestData?.object(forKey: "speed") as? Double
                                    self.speed = String(format:"%.2lf",tempSpeed ?? 0)
                                    self.validTimes = indexData?.object(forKey: "validTimes") as? Int
                                    self.mileage = latestData?.object(forKey: "mileage") as? Int
                                    self.date = latestData?.object(forKey: "date") as? String
                                    self.date = String((self.date?.suffix(5))!)
                                case .failure:
        //                            print(response)
                                    self.available = false
                            }
                        }
                    )
    }
    
}

struct SunRunWidget: View {
    
    @ObservedObject var srData: LMWidgetSunRun
    var chargeFunc: ((@escaping (Bool) -> Void) -> Void)?
    
    init (_ token: String) {
        self.srData = LMWidgetSunRun(token)
    }
    
    var body: some View {
        VStack (alignment: .center) {
            if srData.available ?? false {
                VStack {
                    HStack(alignment: .center) {
                        //Spacer()
                        WidgetNumberView(
                            number: self.srData.speed ?? "",
                            title: "\(self.srData.date ?? "") \(self.srData.domain ?? "")",
                            unit: "m/s"
                        )
                        Spacer()
                        WidgetNumberView(number: "\(self.srData.validTimes ?? 0)", title: "达标次数", unit: "次")
                        //Spacer()
                    }
                    Text("阳光长跑将于 \(self.srData.endTime ?? "") 截止")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }//.padding()
            } else {
                Text("数据获取失败。请尝试打开杭电助手并登录。嘤~")
                    .foregroundColor(.secondary)
            }
        }//.padding()
    }
}

//struct SunRunWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        SunRunWidget()
//    }
//}
