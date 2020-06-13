//
//  allInwidget.swift
//  allInWidget
//
//  Created by ljz on 2019/12/13.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI

struct AllInwidget: View {
    var sData: Array<LMSchedule>?
    var availabe: Bool
    var scheduleChargeFunc: ((@escaping (Bool) -> Void) -> Void)?
    var cardData: LMWidgetCard?
    var cardChargeFunc: ((@escaping (Bool) -> Void) -> Void)?
    var srData: LMWidgetSunRun?
    var elecData: LMWidgetElec?
    
    var body: some View {
        VStack {
            ScheduleWidget(sData: self.sData, availabe: self.availabe)
            Divider()
            CardWidget(cardData: self.cardData)
            Divider()
            SunRunWidget(srData: self.srData)
            Divider()
            ElectricWidget(elecData: self.elecData)
        }
    }
}
