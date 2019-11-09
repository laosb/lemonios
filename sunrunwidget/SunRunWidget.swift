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
        
        VStack (alignment: .center) {
//            Text("tmp")
//            .foregroundColor(.black)
//            SunRunImage()
//                .offset(y: -230)
//                .padding(.bottom, -230)
            if srData?.available ?? false {
                VStack {
                    HStack {
                        VStack(alignment: .leading){
//                            Image("sunrun")
                            Text("阳光长跑")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                
                            Text("截止于 \(self.srData?.endTime ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(self.srData?.date ?? "") \(self.srData?.domain ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(self.srData?.speed ?? "") m/s")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack {
                            Text("达标次数")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(self.srData?.validTimes ?? 0)")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        }
                    }
                }.padding()
            }
            else {
                Text("您尚未登录杭电助手")
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
