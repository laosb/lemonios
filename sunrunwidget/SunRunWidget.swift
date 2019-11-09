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
        
        VStack (alignment: .leading){
//            Text("tmp")
//            .foregroundColor(.black)
//            SunRunImage()
//                .offset(y: -230)
//                .padding(.bottom, -230)
            if srData?.available ?? false {
                Text("\(self.srData?.endTime ?? "") 截止")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
  //              VStack {
//                    Spacer()
                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .center) {
                        Text("\(self.srData?.date ?? "") \(self.srData?.domain ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .bold()
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(self.srData?.speed ?? "")")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                                .bold()
                            Text("m/s")
                            .bold()
                            .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    VStack {
                        Text("达标次数")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .bold()
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(self.srData?.validTimes ?? 0)")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                                .bold()
                            Text("次")
                                .bold()
                                .foregroundColor(.secondary)
                        }
                        
                    }
                    Spacer()
                }.padding()
 //               }.padding()
            }
            else {
                Text("您尚未登录杭电助手")
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
