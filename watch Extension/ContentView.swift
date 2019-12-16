//
//  ContentView.swift
//  watch Extension
//
//  Created by Shibo Lyu on 2019/12/6.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var token: String
    var body: some View {
        List {
//            Text("Token: \(token)")
            if token == "" {
                Button(action: {
                    let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
                    let token = sharedUd?.string(forKey: "token")
                    if token != "" {
                        self.token = token ?? ""
                    }
                }) {
                    HStack {
                        Image(systemName: "goforward")
                        Text("重试")
                    }
                }
            }
            ScheduleWidget(token)
            CardWidget(token)
            SunRunWidget(token)
            ElectricWidget(token)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(token: "123")
    }
}