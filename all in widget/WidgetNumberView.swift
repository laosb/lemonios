//
//  WidgetNumberView.swift
//  all in widget
//
//  Created by ljz on 2019/12/13.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI

struct WidgetNumberView: View {
    @State var number: String
    @State var title: String
    @State var unit: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .bold()
            HStack(alignment: .firstTextBaseline) {
                Text(number).font(.system(size: 36, weight: .light , design: .default))
                Text(unit).bold()
            }
        }
    }
}

struct WidgetNumberView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetNumberView(number: "123.1", title: "测试", unit: "元")
    }
}
