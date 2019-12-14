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
                        version: "1.3", content: [
                            "[NOMAC]提供了Apple Watch app。在配对了Apple Watch的iPhone上前往Watch应用安装杭电助手。",
                            "完全适配了暗色模式",
                            "[NOMAC]支持应用图标替换。前往我 - 设置 - 外观与体验设置。",
                            "新增若干图书馆相关应用",
                        ]
                    ))
                    NewFuncRow(versionContent: LMNewFuncGuideVersionContent(
                        version: "1.2", content: [
                            "新增空教室、电费模块及首页信息流板块。",
                            "[NOMAC]新增智能电费小组件。",
                            "全新登录页面，登录更快捷。",
                            "新增寝室电费不足提醒和长跑次数更新的推送，可以前往我 - 设置 - 通知管理开启。",
                        ]
                    ))
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
