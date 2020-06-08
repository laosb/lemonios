//
//  SwiftUIView.swift
//  lemonios
//
//  Created by ljz on 2019/10/30.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI
import Combine
import Alamofire

class LMWidgetCard: ObservableObject {
    @Published var remaining: String?
    @Published var today: String?
    @Published var tip: String?
    @Published var available: Bool?
    
    init (_ token: String) {
        AF.request("https://api.hduhelp.com/infoStream/v3", headers:["Authorization": "token \(token)", "User-Agent": "Alamofire Lemon_watchOS"]).validate().responseJSON(completionHandler:
            {
                response in switch response.result
                {
                    case .success(let value):
//                            print(response.result)
                        let json = value
                        let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
                        let CardData = newRawData.object(forKey: "card") as? NSDictionary
                        
                        self.available = CardData?.object(forKey: "available") as? Bool
                        let indexData = CardData?.object(forKey: "data") as? NSDictionary
                        
                        let remaining = indexData?.object(forKey: "remaining") as? Double ?? 0
                        self.remaining = String(format:"%.2lf", abs(remaining) < 0.01 ? 0.0 : remaining)
                        let today = (indexData?.object(forKey: "today") as? Double ?? 0) * -1
                        self.today = String(format:"%.2lf", abs(today) < 0.01 ? 0.0 : today)
                        
                        if remaining <= 15.0 {
                            self.tip = "⚠️ 余额较少，记得充值"
                        }
                        print(response)
                    case .failure:
//                            print(response)
                        self.available = false
                }
            }
        )
    }
}
//@available(iOS 13.0.0, *)
struct CardWidget: View {
    
    @State var tipMessage: String = ""
    
    @ObservedObject var cardData: LMWidgetCard
    var chargeFunc: ((@escaping (Bool) -> Void) -> Void)?
    
    init (_ token: String) {
        self.cardData = LMWidgetCard(token)
    }

    var body: some View {
        
        VStack (alignment: .center){
            if cardData.available ?? false {
                HStack {
                    VStack {
                        HStack(alignment: .center) {
                            //Spacer()
                            WidgetNumberView(number: self.cardData.remaining ?? "", title: "校园卡余额", unit: "元")
                            Spacer()
                            WidgetNumberView(number: self.cardData.today ?? "", title: "今日消费", unit: "元")
                            //Spacer()
                        }
                        if tipMessage != "" || self.cardData.tip != "" {
                            Text(tipMessage != "" ? tipMessage : self.cardData.tip ?? "")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
//                    HStack {
//                        Button(action: {
//                            self.chargeFunc? { success in
//                                if !success {
//                                    self.tipMessage = "⚠️充值依赖支付宝。请检查您是否安装支付宝。"
//                                }
//                            }
//                        }) {
//                            VStack {
//                                Spacer()
//                                Text("充值")
//                                    .accentColor(Color.white)
//                                Spacer()
//                            }
//                        }
//                            .frame(width: 25.0)
//                            .background(Color(red:0.20, green:0.60, blue:0.86))
//                            .cornerRadius(12.5)
//                    }.padding(10.0)
                }
            } else {
                Text("数据获取失败。请尝试打开杭电助手并登录。嘤~")
                    .foregroundColor(.secondary)
            }
        }
    }
}

//@available(iOS 13.0.0, *)
//struct SunRunWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        SunRunWidget(token: "[REDACTED]")
//    }
//}
