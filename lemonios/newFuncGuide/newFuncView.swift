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
                        version: "2.2.1", content: [
                            "修复了课表小组件中的「签到」功能。",
                            "新增杭电助手拟人形象「时柒」贴纸包，可以在iMessage中使用。该贴纸包亦将或已在其它IM平台发布。",
                            "修复了watchOS无法获取数据的问题"
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
