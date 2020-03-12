//
//  scheduleDataView.swift
//  schedulewidget
//
//  Created by ljz on 2019/11/20.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI

struct ScheduleDataView: View {
    
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

//struct scheduleDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        scheduleDataView(realData: )
//    }
//}