//
//  scheduleDataView.swift
//  schedulewidget
//
//  Created by ljz on 2019/11/20.
//  Licensed under MIT License (https://laosb.mit-license.org).
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
