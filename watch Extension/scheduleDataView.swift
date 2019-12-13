//
//  scheduleDataView.swift
//  watch Extension
//
//  Created by ljz on 2019/12/6.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI

struct scheduleDataView: View {
    
    @State var realData: LMScheduleData
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("\(realData.course!)")
                .font(.headline)
            Text("\(realData.isTomorrow! == true ? "明天" : "")\(realData.startTime!) - \(realData.endTime!) · \(realData.classRoom!)")
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
