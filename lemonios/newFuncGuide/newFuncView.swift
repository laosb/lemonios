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
            version: "2.3.1", content: [
              "修复了iOS 14「下节课」小组件中签到提示应用不存在的问题。",
              "因上课啦及易班的限制，首次使用小组件的签到功能前，请先点击小组件上的「设置签到」按提示完成设置后方可使用。"
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
