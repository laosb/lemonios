//
//  electricNumberView.swift
//  allInWidget
//
//  Created by ljz on 2019/12/13.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI

struct electricNumberView: View {
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
