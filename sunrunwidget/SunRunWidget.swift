//
//  SwiftUIView.swift
//  lemonios
//
//  Created by ljz on 2019/10/30.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI
import Alamofire

struct LMWidgetSunRun {
    var speed: String?
    var validTimes: Int?
    var mileage: Int?
    var isValid: Bool?
    var domain: String?
    var date: String?
    var endTime: String?
    var runTimes: Int?
    var token: String?
    var available: Bool?
}
//@available(iOS 13.0.0, *)
struct SunRunWidget: View {
    
    var srData: LMWidgetSunRun?
    var body: some View {
        
        VStack (alignment: .center){
            if srData?.available ?? false {
                VStack {
                    HStack(alignment: .center) {
                        Spacer()
                        WidgetNumberView(
                            number: self.srData?.speed ?? "",
                            title: "\(self.srData?.date ?? "") \(self.srData?.domain ?? "")",
                            unit: "m/s"
                        )
                        Spacer()
                        WidgetNumberView(number: "\(self.srData?.validTimes ?? 0)", title: "达标次数", unit: "次")
                        Spacer()
                    }
                    Text("阳光长跑将于 \(self.srData?.endTime ?? "") 截止")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }.padding()
            } else {
                Text("数据获取失败。请尝试打开杭电助手并登录。嘤~")
                    .foregroundColor(.secondary)
            }
        }.padding()
    }
}

//@available(iOS 13.0.0, *)
//struct SunRunWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        SunRunWidget(token: "25c575e9-8f61-4bfb-92cf-e5f73be7d279")
//    }
//}
