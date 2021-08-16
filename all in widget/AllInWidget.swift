//
//  AllInWidget.swift
//  all in widget
//
//  Created by ljz on 2019/12/13.
//  Licensed under MIT License (https://laosb.mit-license.org).
//

import SwiftUI
import Alamofire

struct AllInWidget: View {
    
    var elecData: LMWidgetElec?
    var srData: LMWidgetSunRun?
    var sData: Array<LMSchedule>?
    var availabe: Bool?
    var isExpanded: Bool?
    var cardChargeFunc: ((@escaping (Bool) -> Void) -> Void)?
    var scheduleChargeFunc: ((@escaping (Bool) -> Void) -> Void)?
    
    
    var body: some View {
        VStack {
            if self.isExpanded == true {
                Divider()
                ScheduleWidget(sData: self.sData, availabe: self.availabe ?? false, chargeFunc: self.scheduleChargeFunc).frame(height: 110)
                Divider()
                SunRunWidget(srData: self.srData).frame(height: 90)
                Divider()
                ElectricWidget(elecData: self.elecData).frame(height: 90)
            }else if sData!.count > 0 || self.availabe == false{
                ScheduleWidget(sData: self.sData, availabe: self.availabe ?? false, chargeFunc: self.scheduleChargeFunc).frame(height: 100)
                Spacer()
            }
            else {
              ScheduleWidget(sData: self.sData, availabe: self.availabe ?? false, chargeFunc: self.scheduleChargeFunc).frame(height: 110)            }
        }
    }
}
