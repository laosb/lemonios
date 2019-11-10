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
    
    var cardData: LMWidgetCard?
    var body: some View {
        
        VStack (alignment: .center){
            if cardData?.available ?? false {
                VStack {
                    HStack(alignment: .center) {
                        Spacer()
                        WidgetNumberView(number: self.cardData?.remaining ?? "", title: "余额", unit: "元")
                        Spacer()
                        WidgetNumberView(number: self.cardData?.today ?? "", title: "今日消费", unit: "元")
                        Spacer()
                    }
                    Text(self.cardData?.tip ?? "")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }.padding()
            } else {
                Text("数据获取失败。请尝试打开杭电助手并登录。")
                    .foregroundColor(.secondary)
            }
        }.padding()
    }
}

//@available(iOS 13.0.0, *)
//struct SunRunWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        SunRunWidget(token: "[REDACTED]")
//    }
//}
