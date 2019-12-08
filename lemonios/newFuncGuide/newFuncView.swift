//
//  SwiftUIView.swift
//  lemonios
//
//  Created by ljz on 2019/11/12.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI

struct upDateCount {
    var oldver: String
    var nowver: String
    var newver: String
}

struct NewFuncView: View {
    var dismissFunc: (() -> Void)?
    var body: some View {
        VStack {
            NavigationView {
                List {
                    NewFuncRow(versionContent: LMNewFuncGuideVersionContent(
                        version: "1.2", content: [
                            "新增空教室、电费模块及首页信息流板块。",
                            "[NOMAC]新增智能电费小组件。",
                            "全新登录页面，登录更快捷。",
                            "新增寝室电费不足提醒和长跑次数更新的推送，可以前往我 - 设置 - 通知管理开启。",
                        ]
                    ))
                    NewFuncRow(versionContent: LMNewFuncGuideVersionContent(
                        version: "1.1", content: [
                            "[MACONLY]杭电助手现已提供macOS App。",
                            "支持系统通知推送，可以在「我」-「设置」-「通知设置」中具体调整。",
                            "[NOMAC]一卡通组件新增「充值」功能，点击即可直达支付宝校园一卡通充值。",
                            "「发现」新增搜索功能。",
                            "全新的通知管理设置，更多自定义设置。",
                        ]
                    ))
                    #if !targetEnvironment(macCatalyst)
                    NewFuncRow(versionContent: LMNewFuncGuideVersionContent(
                        version: "1.0", content: [
                            "新的通知中心小组件：阳光长跑、一卡通。前往通知中心的左侧，点击底部「编辑」将他们添加进来即可使用。",
                        ]
                    ))
                    #endif
                }
                    .navigationBarTitle("杭电助手·新功能")
            }
                .navigationViewStyle(StackNavigationViewStyle())
            VStack {
                Text("完整更新日志请前往App Store「最近更新」查看。").font(.footnote)
                Button(action: {
                    let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
                    sharedUd?.set(Bundle.main.infoDictionary?["CFBundleVersion"] as! String, forKey: "lastVersionGuided")
                    sharedUd?.synchronize()
//                    print(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)
                    self.dismissFunc?()
                }) {
                    HStack {
                        Spacer()
                        Text("开始使用")
                            .foregroundColor(Color.white)
                            .padding()
                        Spacer()
                    }
                        .background(Color(red:0.20, green:0.60, blue:0.86))
                        .cornerRadius(15)
                        .padding()
                }
            }.padding()
        }
    }
}

struct NewFuncView_Previews: PreviewProvider {
    static var previews: some View {
        NewFuncView()
    }
}
