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
    var speed: Double?
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
        VStack {
            if srData?.available ?? false {
                VStack {
                    HStack {
//                        Image(system: "")
                        VStack(alignment: .leading){
                            Text("阳光长跑")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                            Text("截止于 \(self.srData?.endTime ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        Spacer()
                        VStack {
                            Text("\(self.srData?.validTimes ?? 0)")
                                .font(.headline)
                                .foregroundColor(.orange)
                            Text("达标次数")
                                .font(.footnote)
                                .foregroundColor(.orange)
                        }
                    }
                    HStack {
                        Text("\(self.srData?.speed ?? 0) m/s")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Text("\(self.srData?.date ?? "") \(self.srData?.domain ?? "")")
                            .font(.headline)
                            .foregroundColor(.black)
                    }.padding()
                }
            } else {
                VStack {
                    Text("您登陆已过期，或者还未登陆杭电助手")
                        .font(.subheadline)
                }
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
