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
            version: "2.3.3", content: [
              "新增「我」-「设置」-「小组件设置」，「下节课」小组件签到行为现可在启动易班和直接打开上课啦中选择。",
              "「杭电助手时柒」贴纸包有了更可爱的图标并多了一张贴纸。时柒也来到了app的载入页。"
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
