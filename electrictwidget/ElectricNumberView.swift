//
//  ElectricNumberView.swift
//  electrictwidget
//
//  Created by ljz on 2019/12/3.
//  Licensed under MIT License (https://laosb.mit-license.org).
//

import SwiftUI

struct ElectricNumberView: View {
    @State var number: String
    @State var title: String
    @State var unit: String
    @State var pos: String
    @State var perfix: String
    @State var suffix: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .bold()
            if number != ""
            {
                HStack(alignment: .firstTextBaseline) {
                    Text(number).font(.system(size: 36, weight: .light , design: .default))
                    Text(unit).bold()
                }
            }
            else if pos != "" {
                VStack(alignment: .leading) {
                    Text(perfix).font(.system(size: 18, weight: .light , design: .default)).bold()
                    Text(suffix).font(.system(size: 18, weight: .light , design: .default)).bold()
                }
            }
            
        }
    }
}

struct ElectricNumberView_Previews: PreviewProvider {
    static var previews: some View {
        ElectricNumberView(number: "123.1", title: "测试", unit: "元", pos: "xxx", perfix: "",suffix: "")
    }
}
