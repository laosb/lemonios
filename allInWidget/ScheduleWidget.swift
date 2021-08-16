//
//  scheduleWidget.swift
//  allInWidget
//
//  Created by ljz on 2019/12/13.
//  Licensed under MIT License (https://laosb.mit-license.org).
//

import SwiftUI

struct LMSchedule {
    var course: String?
    var classRoom: String?
    var isTomorrow: Bool?
    var startTime: String?
    var endTime: String?
    var teacher: String?
}

struct ScheduleWidget: View {
    
    @State var tipMessage: String = ""
    var sData: Array<LMSchedule>?
    var availabe: Bool
    var chargeFunc: ((@escaping (Bool) -> Void) -> Void)?
    
    var body: some View {
        
        GeometryReader {geometry in
            HStack {
                if self.availabe == false {
                    VStack {
                        Text("获取课表失败，请尝试打开杭电助手并登录。嘤~")
                            .foregroundColor(.secondary)
                    }
                }
                else if self.sData!.count != 0 {
                        List {
                            scheduleDataView(realData: self.sData![0])
                            if self.sData!.count >= 2 {
                                scheduleDataView(realData: self.sData![1])
                            }
                        }.environment(\.defaultMinListRowHeight, geometry.size.height/2)
                        VStack {
                            Button(action: {
                                self.chargeFunc? { success in
                                    if !success {
                                        self.tipMessage = ""
                                    }
                                }
                            }) {
                                VStack {
                                    Spacer()
                                    Text("签到")
                                        .accentColor(Color.white)
                                    Spacer()
                                }
                            }
                                .frame(width: 25.0)
                                .background(Color(red:0.20, green:0.60, blue:0.86))
                                .cornerRadius(12.5)
                        }.padding(10.0)
                }
                else {
                    Text("今明两天都没有课。享受生活！")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
            }
        }
    }
}
