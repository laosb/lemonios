//
//  ElectricWidget.swift
//  watch Extension
//
//  Created by ljz on 2019/12/9.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI
import Combine
import Alamofire

class LMElectric: ObservableObject{
    @Published var remaining: String?
    @Published var today: String?
    @Published var tip: String?
    @Published var available: Bool?
    @Published var room: String?
    @Published var perfix: String?
    @Published var suffix: String?
    
    init(_ token: String) {
        AF.request("https://api.hduhelp.com/electric/fee", headers:["Authorization": "token \(token)", "User-Agent": "Alamofire Lemon_iOS"]).validate().responseJSON(completionHandler:
                         {
                             response in switch response.result
                             {
                                 case .success(let value):
         //                            print(response.result)
                                     let json = value
                                     let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
                                     let fee = newRawData.object(forKey: "fee") as? String
                                     let pos = newRawData.object(forKey: "roomName") as? String
                                     let msg = (json as! NSDictionary).object(forKey: "msg") as! String
                                     let per = String(pos!.prefix(5))
                                     let suf = String(pos!.suffix(3))
                                     self.perfix = per
                                     self.suffix = suf
        //                             print(pos)
                                     
                                     self.available = false
                                     if msg == "success" {
                                         self.available = true
                                     }
                                     self.remaining = fee
                                     self.room = pos
                                     self.room!.remove(at: (self.room?.index(before: self.room!.endIndex))!)
                                     self.remaining!.remove(at: (self.remaining?.index(before: self.remaining!.endIndex))!)
                                     let feeDouble = (self.remaining! as NSString).doubleValue
                                     if feeDouble <= 15.0 {
                                         self.tip = "⚠️ 余额较少，记得充值"
                                     }
                                 case .failure:
         //                            print(response)
                                     self.available = false
                             }
                         }
                     )
    }
    
}

struct ElectricWidget: View {
    
    @ObservedObject var elecData: LMElectric
    @State var tipMessage: String = ""
    var chargeFunc: ((@escaping (Bool) -> Void) -> Void)?
    
    init (_ token: String) {
        self.elecData = LMElectric(token)
    }
    
    var body: some View {
        VStack (alignment: .center){
            if elecData.available ?? false {
                VStack {
                    HStack(alignment: .center) {
                        ElectricNumberView(number: "", title: "寝室号", unit: "", pos: self.elecData.room ?? "", perfix: (self.elecData.perfix)! , suffix: (self.elecData.suffix)!)
                        ElectricNumberView(number: self.elecData.remaining ?? "", title: "电费余额", unit: "元", pos: "", perfix: "",suffix: "")
                    }
                    if elecData.tip != nil {
                        Text(tipMessage != "" ? tipMessage : self.elecData.tip ?? "")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                }
            }
            else {
                Text("数据获取失败。请尝试打开杭电助手并登录。嘤~")
                    .foregroundColor(.secondary)
            }
        }
    }
}

//struct SunRunWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        SunRunWidget()
//    }
//}
