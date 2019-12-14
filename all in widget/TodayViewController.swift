//
//  TodayViewController.swift
//  allInWidget
//
//  Created by ljz on 2019/12/13.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import SwiftUI

class TodayViewController: UIViewController, NCWidgetProviding {
    var sData = Array<LMSchedule>()
    var srData = LMWidgetSunRun()
    var elecData = LMWidgetElec()
    var cardData = LMWidgetCard()
    //var allVc: UIHostingController<AllInWidget>?
    var Av: Bool = false
    var isEx: Bool = false
    var allVc: UIHostingController<AllInWidget>?
    func renderData() {
        if self.children.count > 0{
            let viewControllers:[UIViewController] = self.children
               for viewContoller in viewControllers{
                viewContoller.willMove(toParent: nil)
                   viewContoller.view.removeFromSuperview()
                viewContoller.removeFromParent()
               }
           }
        print(self.sData.count)
        allVc = UIHostingController(rootView:
            AllInWidget(elecData: self.elecData, cardData: self.cardData, srData: self.srData, sData: self.sData, availabe: self.Av, isExpanded: self.isEx, cardChargeFunc: { cb in
                self.extensionContext?.open(URL(string: "alipays://platformapi/startapp?saId=10000007&qrcode=https%3A%2F%2Fqr.alipay.com%2Fs7x07977akyiot2uv5pme45%3F_s%3Dweb-other")!) {success in cb(success)}
            },scheduleChargeFunc: { cb in
                self.extensionContext?.open(URL(string: "https://skl.hduhelp.com/#/sign/in")!
            )
            })
            

        )
        allVc!.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        allVc!.view.frame = self.view.bounds
        self.view.addSubview(allVc!.view)
        self.addChild(allVc!)
        allVc!.didMove(toParent: self)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
        let token = sharedUd?.string(forKey: "token")
        if token != nil {
            Alamofire.request("https://api.hduhelp.com/base/student/schedule/now", headers: [
                "Authorization": "token \(token ?? "")"
            ]).validate().responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    let json = response.result.value
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
                            self.sData.append(tempSData)
                        }
                    }
                    //                            print("!!!!!!!!!!!!!!!!!!!")
                    //                            print(tempData.count)
                    //                            print(sData.count)
                //self.renderData(sData: sData, isA: true)
                    self.Av = true
                case .failure:
                    //self.renderData(sData: sData, isA: false)
                    break
                }
            }
            )
            
            Alamofire.request("https://api.hduhelp.com/infoStream/v3", headers:["Authorization": "token \(token ?? "")"]).validate().responseJSON(completionHandler:
                {
                    response in switch response.result
                    {
                    case .success:
                        //                            print(response.result)
                        let json = response.result.value
                        let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
                        let SunRunData = newRawData.object(forKey: "sunrun") as? NSDictionary
                        
                        self.srData.available = SunRunData?.object(forKey: "available") as? Bool
                        var indexData = SunRunData?.object(forKey: "data") as? NSDictionary
                        self.srData.endTime = indexData?.object(forKey: "endTime") as? String
                        let latestData = indexData?.object(forKey: "latest") as? NSDictionary
                        self.srData.domain = latestData?.object(forKey: "domain") as? String
                        self.srData.isValid = latestData?.object(forKey: "isvalid") as? Bool
                        let tempSpeed = latestData?.object(forKey: "speed") as? Double
                        self.srData.speed = String(format:"%.2lf",tempSpeed ?? 0)
                        self.srData.validTimes = indexData?.object(forKey: "validTimes") as? Int
                        self.srData.mileage = latestData?.object(forKey: "mileage") as? Int
                        self.srData.date = latestData?.object(forKey: "date") as? String
                    //self.renderData(srData: srData)
                        
                        
                        let CardData = newRawData.object(forKey: "card") as? NSDictionary
                        
                        self.cardData.available = CardData?.object(forKey: "available") as? Bool
                        indexData = CardData?.object(forKey: "data") as? NSDictionary
                        
                        let remaining = indexData?.object(forKey: "remaining") as? Double ?? 0
                        self.cardData.remaining = String(format:"%.2lf", abs(remaining) < 0.01 ? 0.0 : remaining)
                        let today = (indexData?.object(forKey: "today") as? Double ?? 0) * -1
                        self.cardData.today = String(format:"%.2lf", abs(today) < 0.01 ? 0.0 : today)
                        
                        if remaining <= 15.0 {
                            self.cardData.tip = "⚠️ 余额较少，记得充值"
                        }
                        self.Av = true
                    case .failure:
                        //                            print(response)
                        //self.srData.available = false
                        //self.renderData(srData: srData)
                        break
                    }
            }
            )
            Alamofire.request("https://api.hduhelp.com/electric/fee", headers:["Authorization": "token \(token ?? "")"]).validate().responseJSON(completionHandler:
                {
                    response in switch response.result
                    {
                    case .success:
                        //                            print(response.result)
                        let json = response.result.value
                        let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
                        let fee = newRawData.object(forKey: "fee") as? String
                        let pos = newRawData.object(forKey: "roomName") as? String
                        let msg = (json as! NSDictionary).object(forKey: "msg") as! String
                        let per = String(pos!.prefix(5))
                        let suf = String(pos!.suffix(3))
                        self.elecData.perfix = per
                        self.elecData.suffix = suf
                        //                             print(pos)
                        
                        self.elecData.available = false
                        if msg == "success" {
                            self.elecData.available = true
                        }
                        self.elecData.remaining = String(fee!.prefix(5))
                        self.elecData.room = pos
                        self.elecData.room!.remove(at: (self.elecData.room?.index(before: self.elecData.room!.endIndex))!)
                        //elecData.remaining!.remove(at: (elecData.remaining?.index(before: elecData.remaining!.endIndex))!)
                        //                            cardData.available = CardData?.object(forKey: "available") as? Bool
                        //                            let indexData = CardData?.object(forKey: "data") as? NSDictionary
                        let feeDouble = (self.elecData.remaining! as NSString).doubleValue
                        //                            cardData.remaining = String(format:"%.2lf", abs(remaining) < 0.01 ? 0.0 : remaining)
                        //                            let today = (indexData?.object(forKey: "today") as? Double ?? 0) * -1
                        //                            cardData.today = String(format:"%.2lf", abs(today) < 0.01 ? 0.0 : today)
                        //
                        if feeDouble <= 15.0 {
                            self.elecData.tip = "⚠️ 余额较少，记得充值"
                        }
                        //
                        //self.renderData(elecData: elecData)
                        self.Av = true
                    case .failure:
                        //                            print(response)
                        self.elecData.available = false
                        //self.renderData(elecData: elecData)
                    }
            }
            )
            
        } else {
            //self.renderData(sData: sData, isA: false)
            self.Av = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        //                // Put your code which should be executed with a delay here
            self.renderData()
            })
    }
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 430)
            self.isEx = true
            //self.removeFromParent()
            //self.delete(Any?.self)
            //allVc?.removeFromParent()
            self.viewDidLoad()
        }else {
            self.preferredContentSize = maxSize
            self.isEx = false
            //self.removeFromParent()
            //self.delete(Any?.self)
            //self.removeFromParent()
            //allVc?.removeFromParent()
            self.viewDidLoad()
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
