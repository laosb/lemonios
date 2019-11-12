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

struct newFuncView: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    newFuncRow(versionContent: LMNewFuncGuideVersionContent(
                        version: "1.0", content: [
                            "增加：Apple ID登录功能",
                            "增加：阳光长跑widget",
                            "增加：一卡通widget",
                        ]
                    ))
                    newFuncRow(versionContent: LMNewFuncGuideVersionContent(
                        version: "1.1", content: [
                            "修复：课表显示问题"
                        ]
                    ))
                }
                    .navigationBarTitle("杭电助手新功能")
                    .padding()
                VStack {
                    Button(action: {}) {
                        HStack {
                            Spacer()
                            Text("开始使用")
                                .foregroundColor(Color.white)
                                .padding()
                            Spacer()
                        }
                            .background(Color(red:0.20, green:0.60, blue:0.86))
                            .cornerRadius(20)
                            .padding()
                    }
                }.padding()
            }
        }
    }
}

struct newFuncView_Previews: PreviewProvider {
    static var previews: some View {
        newFuncView()
    }
}
