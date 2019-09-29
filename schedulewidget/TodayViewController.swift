//
//  TodayViewController.swift
//  schedulewidget
//
//  Created by Wexpo Lyu on 2019/9/28.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var table: UITableView!
    
    var scheduleData: Array<NSDictionary>?
    var isTomorow: Bool = false
    
    @IBAction func signInBtnTapped(_ sender: Any) {
        self.extensionContext?.open(URL(string: "https://skl.hduhelp.com/#/sign/in")!, completionHandler: nil)
    }
    
    func loadQuickScheduleData(token: String) {
        Alamofire.request("https://api.hduhelp.com/base/student/schedule/now", headers: [
            "Authorization": "token \(token)"
        ]).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .success:
                let json = response.result.value
//                print(json)
                let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
//                print(newRawData)
                self.scheduleData = (newRawData.object(forKey: "Schedule") as! Array<NSDictionary>)
//                print(self.scheduleData?.count)
                self.isTomorow = newRawData.object(forKey: "IsTomorrow") as! Bool
                self.statusLabel.text = self.scheduleData?.count ?? 0 > 0
                    ? ""
                    : "今天明天都没有课程。享受生活！"
                self.table.reloadData()
            case .failure:
                self.statusLabel.text = "获取课表失败"
                self.scheduleData = []
                self.table.reloadData()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
        let token = sharedUd?.string(forKey: "token")
        if token != nil {
            loadQuickScheduleData(token: token!)
        } else {
            statusLabel.text = "您尚未登录杭电助手，或者您的会话已过期。请打开杭电助手尝试登录。"
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

extension TodayViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(scheduleData?.count ?? 0)
        return scheduleData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = self.scheduleData?[indexPath.row]
//        print(cellData)
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath)
        cell.textLabel?.text = cellData?.object(forKey: "COURSE") as? String
        
        let dayHint = self.isTomorow ? "明天" : ""
        let timePeriod = "\(dayHint)\(cellData?.object(forKey: "STARTTIME") ?? "") - \(cellData?.object(forKey: "ENDTIME") ?? "")"
        let teacher = "\(cellData?.object(forKey: "TEACHER") ?? "")"
        let place = "\(cellData?.object(forKey: "CLASSROOM") ?? "")"
        cell.detailTextLabel?.text = "\(timePeriod)  ·  \(teacher)  ·  \(place)"
                
        return cell
    }
    
//    func tableView (_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let sklAction = UIContextualAction(style: .normal, title: "签到", handler: { _,_,_ in
//            self.extensionContext?.open(URL(string: "https://skl.hduhelp.com/#/sign/in")!, completionHandler: nil)
//        })
//        return UISwipeActionsConfiguration(actions: [sklAction])
//    }
}

