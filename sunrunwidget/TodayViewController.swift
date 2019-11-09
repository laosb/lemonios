//
//  TodayViewController.swift
//  sunrunwidget
//
//  Created by Shibo Lyu on 2019/11/8.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftUI
import Alamofire

class TodayViewController: UIViewController, NCWidgetProviding {
    
    func renderData(srData: LMWidgetSunRun) {
        let srVc = UIHostingController(rootView: SunRunWidget(srData: srData))
        srVc.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        srVc.view.frame = self.view.bounds
        self.view.addSubview(srVc.view)
        self.addChild(srVc)
        srVc.didMove(toParent: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
        let token = sharedUd?.string(forKey: "token")
//        print(token)
        var srData = LMWidgetSunRun()
//        let token = ""
        if token != nil {
            Alamofire.request("https://api.hduhelp.com/infoStream/v3", headers:["Authorization": "token \(token ?? "")"]).validate().responseJSON(completionHandler:
                {
                    response in switch response.result
                    {
                        case .success:
                            print(response.result)
                            let json = response.result.value
                            let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
                            let SunRunData = newRawData.object(forKey: "sunrun") as? NSDictionary
                            
                            srData.available = SunRunData?.object(forKey: "available") as? Bool
                            let indexData = SunRunData?.object(forKey: "data") as? NSDictionary
                            srData.endTime = indexData?.object(forKey: "endTime") as? String
                            let latestData = indexData?.object(forKey: "latest") as? NSDictionary
                            srData.domain = latestData?.object(forKey: "domain") as? String
                            srData.isValid = latestData?.object(forKey: "isvalid") as? Bool
                            let tempSpeed = latestData?.object(forKey: "speed") as? Double
                            srData.speed = String(format:"%.2lf",tempSpeed ?? 0)
                            srData.validTimes = indexData?.object(forKey: "validTimes") as? Int
                            srData.mileage = latestData?.object(forKey: "mileage") as? Int
                            srData.date = latestData?.object(forKey: "date") as? String
                            self.renderData(srData: srData)
                        case .failure:
                            print(response)
                            srData.available = false
                            self.renderData(srData: srData)
                    }
                }
            )
        } else {
            srData.available = false
            self.renderData(srData: srData)
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
