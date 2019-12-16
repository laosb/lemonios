//
//  ScheduleWidgetView.swift
//  all in widget
//
//  Created by ljz on 2019/12/13.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI

struct ScheduleDataView: View {
    
    @State var realData: LMSchedule
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("\(realData.course!)")
                .font(.headline)
                .lineLimit(1)
            Text("\(realData.isTomorrow! == true ? "明天" : "")\(realData.startTime!) - \(realData.endTime!)  ·  \(realData.teacher!)  ·  \(realData.classRoom!)")
                .font(.footnote)
                .lineLimit(1)
        }
    }
}