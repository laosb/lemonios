//
//  electricWidget.swift
//  allInWidget
//
//  Created by ljz on 2019/12/13.
//  Licensed under MIT License (https://laosb.mit-license.org).
//

import SwiftUI

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
                            electricNumberView(number: "", title: "寝室号", unit: "", pos: self.elecData?.room ?? "", perfix: (self.elecData?.perfix)! , suffix: (self.elecData?.suffix)!)
                            Spacer()
                            electricNumberView(number: self.elecData?.remaining ?? "", title: "余额", unit: "元", pos: "", perfix: "",suffix: "")
                            Spacer()
                        }
                        Text(tipMessage != "" ? tipMessage : self.elecData?.tip ?? "")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }.padding()
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
