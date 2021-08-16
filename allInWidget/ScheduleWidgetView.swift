//
//  scheduleWidgetView.swift
//  allInWidget
//
//  Created by ljz on 2019/12/13.
//  Licensed under MIT License (https://laosb.mit-license.org).
//

import SwiftUI

struct scheduleDataView: View {
    
    @State var realData: LMSchedule
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("\(realData.course!)")
                .font(.headline)
            Text("\(realData.isTomorrow! == true ? "明天" : "")\(realData.startTime!) - \(realData.endTime!)  ·  \(realData.teacher!)  ·  \(realData.classRoom!)")
                .font(.footnote)
                .lineLimit(1)
        }
    }
}
