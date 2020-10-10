//
//  SklSetupView.swift
//  杭电助手
//
//  Created by Shibo Lyu on 2020/10/9.
//  Copyright © 2020 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI
import WidgetKit

struct SklSetupView: View {
  var dismissFunc: (() -> Void)?

  @State private var isOk: Bool? = nil

  var body: some View {
    NavigationView {
      VStack {
        if isOk != true {
          VStack(alignment: .leading) {
            Text("由于上课啦及易班的限制，签到按钮的正常功能现需要您手动在易班完成登录后方可正常使用。\n")
            Text("请按以下步骤操作完成登录：")
            Text("· 打开「易班」app，完成登录后点击「上课啦」轻应用打开")
            Text("· 点击右上角「···」按钮，选择「复制链接」")
            Text("· 复制成功后切换回本页面，点击「测试登录」")
          }
          Image("skl_setup_instruction")
            .resizable()
            .scaledToFit()
            .cornerRadius(5)
            .navigationBarTitle("设置签到功能")
            .navigationBarItems(leading: Button("取消") { dismissFunc?() })
          if isOk == false {
            Text("未能获取到正确的登录信息。请重试。").foregroundColor(.red)
          }
        } else {
          Image(systemName: "hand.thumbsup.fill")
            .font(.largeTitle)
            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            .padding()
          Text("您已完成签到功能的设置。").font(.title).padding()
          Text("若登录状态过期，您可以在2x4大小的「之后的课」小组件中点击齿轮图标来重新进行本设置。")
        }
        Button(action: {
          if isOk ?? false {
            dismissFunc?()
          } else {
            if UIPasteboard.general.hasURLs {
              let url = UIPasteboard.general.string
              let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
              sharedUd?.set(url, forKey: "sklUrl")
              sharedUd?.synchronize()
              isOk = true
              if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadTimelines(ofKind: "help.hdu.lemonios.WidgetSchedule")
              }
            } else {
              isOk = false
            }
          }
        }) {
          HStack {
            Spacer()
            Text(isOk ?? false ? "完成" : "测试登录")
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

struct SklSetupView_Previews: PreviewProvider {
  static var previews: some View {
    SklSetupView()
  }
}
