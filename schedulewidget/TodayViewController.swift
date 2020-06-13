//
//  ScheduleWidget.swift
//  ScheduleWidget
//
//  Created by ljz on 2019/11/20.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//
import UIKit
import NotificationCenter
import SwiftUI
import Alamofire

class TodayViewController: UIViewController, NCWidgetProviding {
    
    func renderData(sData: Array<LMSchedule> , isA: Bool) {
        let sVc = UIHostingController(rootView: ScheduleWidget(sData: sData , availabe: isA){ cb in
            self.extensionContext?.open(URL(string: "https://skl.hduhelp.com/?type=2&v=5")!) { success in cb(success) }
        })
        sVc.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        sVc.view.frame = self.view.bounds
        self.view.addSubview(sVc.view)
        self.addChild(sVc)
        sVc.didMove(toParent: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
        let token = sharedUd?.string(forKey: "token")
        var sData = Array<LMSchedule>()
        
        if token != nil {
            AF.request("https://api.hduhelp.com/base/student/schedule/now", headers: [
                "Authorization": "token \(token ?? "")", "User-Agent": "Alamofire Lemon_iOS"
            ]).validate().responseJSON(completionHandler: { response in
                switch response.result {
                        case .success(let value):
                            let json = value
                            let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
                            let tempData = (newRawData.object(forKey: "Schedule") as! Array<NSDictionary>)
                            
                            for i in 0..<tempData.count {
                                let course = tempData[i].object(forKey: "COURSE") as! String
                                let classRoom = tempData[i].object(forKey: "CLASSROOM") as! String
                                let isTomorrow = newRawData.object(forKey: "IsTomorrow") as! Bool
                                let startTime = tempData[i].object(forKey: "STARTTIME") as! String
                                let endTime = tempData[i].object(forKey: "ENDTIME") as! String
                                let teacher = tempData[i].object(forKey: "TEACHER") as! String
                                
                                var tempSData = LMSchedule()
                                tempSData.classRoom = classRoom
                                tempSData.course = course
                                tempSData.teacher = teacher
                                tempSData.isTomorrow = isTomorrow
                                tempSData.endTime = endTime
                                tempSData.startTime = startTime
                                
                                if tempSData.course != nil {
                                    sData.append(tempSData)
                                }
                            }
//                            print("!!!!!!!!!!!!!!!!!!!")
//                            print(tempData.count)
//                            print(sData.count)
                            self.renderData(sData: sData, isA: true)
                        case .failure:
                            self.renderData(sData: sData, isA: false)
                    }
                }
            )
        } else {
            self.renderData(sData: sData, isA: false)
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
