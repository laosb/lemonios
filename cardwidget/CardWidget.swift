//
//  SwiftUIView.swift
//  lemonios
//
//  Created by ljz on 2019/10/30.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI
import Alamofire

struct LMWidgetCard {
    var remaining: String?
    var today: String?
    var tip: String?
    var available: Bool?
}
//@available(iOS 13.0.0, *)
struct CardWidget: View {
    
    @State var tipMessage: String = ""
    
    var cardData: LMWidgetCard?
    var chargeFunc: ((@escaping (Bool) -> Void) -> Void)?
    var body: some View {
        
        VStack (alignment: .center){
            if cardData?.available ?? false {
                HStack {
                    VStack {
                        HStack(alignment: .center) {
                            Spacer()
                            WidgetNumberView(number: self.cardData?.remaining ?? "", title: "余额", unit: "元")
                            Spacer()
                            WidgetNumberView(number: self.cardData?.today ?? "", title: "今日消费", unit: "元")
                            Spacer()
                        }
                        Text(tipMessage != "" ? tipMessage : self.cardData?.tip ?? "")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }.padding()
                    HStack {
                        Button(action: {
                            self.chargeFunc? { success in
                                if !success {
                                    self.tipMessage = "⚠️充值依赖支付宝。请检查您是否安装支付宝。"
                                }
                            }
                        }) {
                            VStack {
                                Spacer()
                                Text("充值")
                                    .accentColor(Color.white)
                                Spacer()
                            }
                        }
                            .frame(width: 25.0)
                            .background(Color(red:0.20, green:0.60, blue:0.86))
                            .cornerRadius(12.5)
                    }.padding(10.0)
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
