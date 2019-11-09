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
        VStack() {
            if srData?.available ?? false {
                VStack {
                    HStack {
//                        SunRunImage()
//                            .offset(y: -230)
//                            .padding(.bottom, -230)
                        VStack(alignment: .leading){
//                            Image("sunrun")
                            Text("阳光长跑")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Text("截止于 \(self.srData?.endTime ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        .background(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.0))
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(self.srData?.date ?? "") \(self.srData?.domain ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Text("\(self.srData?.speed ?? "") m/s")
                                .font(.largeTitle)
                                .foregroundColor(.black)
                        }
                        .background(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.0))
                        Spacer()
                        VStack {
                            Text("达标次数")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Text("\(self.srData?.validTimes ?? 0)")
                                .font(.largeTitle)
                                .foregroundColor(.black)
                        }
                        .background(Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.0))
                    }
                }.padding()
            } else {
                VStack {
                    Text("您登陆已过期，或者还未登陆杭电助手")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .background(Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.0))
                }
                .background(Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.0))
            }
        }
    }
}

//@available(iOS 13.0.0, *)
//struct SunRunWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        SunRunWidget(token: "25c575e9-8f61-4bfb-92cf-e5f73be7d279")
//    }
//}
