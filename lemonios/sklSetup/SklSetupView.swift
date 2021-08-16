//
//  SklSetupView.swift
//  杭电助手
//
//  Created by Shibo Lyu on 2020/10/9.
//  Licensed under MIT License (https://laosb.mit-license.org).
//

import SwiftUI
import WidgetKit

struct SklSetupView: View {
  var dismissFunc: (() -> Void)?

  var sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")

  @State private var isOk: Bool? = nil
  @State private var useDirect = false

  func readSettings () {
    useDirect = !(sharedUd?.string(forKey: "sklUrl") ?? "").isEmpty
  }
  func writeSettings () {
    if !useDirect {
      sharedUd?.setValue(nil, forKey: "sklUrl")
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadTimelines(ofKind: "help.hdu.lemonios.WidgetSchedule")
      }
    }
  }

  var body: some View {
    NavigationView {
      Form {
        Section(
          header: Text("「下节课」/「之后的课」"),
          footer: Text("关闭时，点击「签到」按钮将直接拉起易班。启用并设置后，「签到」按钮将直接打开上课啦。")
        ) {
          Toggle("「签到」直接启动上课啦", isOn: $useDirect)
          if useDirect {
            VStack {
              if isOk != true {
                VStack(alignment: .leading) {
                  Text("由于上课啦及易班的限制，若希望点击签到按钮时打开上课啦，需要您手动在易班完成登录。\n")
                  Text("请按以下步骤操作完成登录：")
                  Text("· 打开「易班」app，完成登录后点击「上课啦」打开")
                  Text("· 点击右上角「···」按钮，选择「复制链接」")
                  Text("· 复制成功后切换回本页面，点击「测试登录」")
                }
                Image("skl_setup_instruction")
                  .resizable()
                  .scaledToFit()
                  .cornerRadius(5)
                if isOk == false {
                  Text("未能获取到正确的登录信息。请重试。").foregroundColor(.red)
                }
              } else {
                Image(systemName: "hand.thumbsup.fill")
                  .font(.largeTitle)
                  .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                  .padding()
                Text("您已完成签到功能的设置。").font(.title).padding()
                Text("若登录状态过期导致您无法签到，您可以在「我」-「设置」中重新设置。")
                Text(
                  "请注意，上课啦及易班随时可能就其功能做出修改而导致此方法失效。若重试设置后依然无法使用上课啦，请关闭「直接启动上课啦」功能。此时「签到」按钮将直接拉起易班。"
                )
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
            }
          }
        }
      }
        .navigationBarTitle("小组件设置")
        .navigationBarItems(
          leading: Button("取消") { dismissFunc?() },
          trailing: HStack {
            if !useDirect {
              Button("完成") {
                writeSettings()
                dismissFunc?()
              }
            }
          }
        )
      .animation(.easeInOut)
    }.onAppear(perform: readSettings)
  }
}

struct SklSetupView_Previews: PreviewProvider {
  static var previews: some View {
    SklSetupView()
  }
}
