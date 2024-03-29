//
//  ElectricWidget.swift
//  electrictwidget
//
//  Created by ljz on 2019/12/3.
//  Licensed under MIT License (https://laosb.mit-license.org).
//

import SwiftUI
import Alamofire

struct LMWidgetElec {
    var remaining: String?
    var today: String?
    var tip: String?
    var available: Bool?
    var room: String?
    var perfix: String?
    var suffix: String?
}
//@available(iOS 13.0.0, *)
struct ElectricWidget: View {
    
    @State var tipMessage: String = ""
    
    var elecData: LMWidgetElec?
    var chargeFunc: ((@escaping (Bool) -> Void) -> Void)?
    var body: some View {
        VStack (alignment: .center){
            if elecData?.available ?? false {
                HStack {
                    VStack {
                        HStack(alignment: .center) {
                            Spacer()
                            ElectricNumberView(number: "", title: "寝室号", unit: "", pos: self.elecData?.room ?? "", perfix: (self.elecData?.perfix)! , suffix: (self.elecData?.suffix)!)
                            Spacer()
                            ElectricNumberView(number: self.elecData?.remaining ?? "", title: "余额", unit: "元", pos: "", perfix: "",suffix: "")
                            Spacer()
                        }
                        Text(tipMessage != "" ? tipMessage : self.elecData?.tip ?? "")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }.padding()
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
