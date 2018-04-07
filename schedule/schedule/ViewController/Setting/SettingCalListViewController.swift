//
//  SettingCalListViewController.swift
//  note:
//  表示しないカレンダーのリストを保存する
//

import UIKit
import EventKit

class SettingCalListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let sectionItems:[String] = [NSLocalizedString("cal_allow_modify", comment: ""),
        NSLocalizedString("cal_read_only", comment: "")]
    
    var eventStore:EKEventStore!
    
    var myList:NSMutableArray = []
    var otherList:NSMutableArray = []
    
    var registered: Dictionary<String, String> = Dictionary() // 表示しないカレンダーリスト
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SettingCalListViewController")
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = NSLocalizedString("setting_cal_display_list", comment: "")

        eventStore = EKEventStore()
        allowAuthorization() // Auth
        
        let calenders = eventStore.calendarsForEntityType(EKEntityType.Event) 
        for calender in calenders {
            if (calender.allowsContentModifications) {
                myList.addObject(calender)
            } else {
                otherList.addObject(calender)
            }
        }
        
        let tableViewCalList: UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), style: .Grouped)
        tableViewCalList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewCalList.allowsSelection = false
        tableViewCalList.dataSource = self
        tableViewCalList.delegate = self
        self.view.addSubview(tableViewCalList)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registered = UDWrapper.getDictionary(UDWrapperKey.UDWrapperKeyDisableCalendars.rawValue,
            defaultValue: Dictionary<String,String> ()) as! Dictionary<String, String>
    }
    
    override func viewWillDisappear(animated: Bool) {
        UDWrapper.setDictionary(UDWrapperKey.UDWrapperKeyDisableCalendars.rawValue, value: registered)
        NSLog("Registerd : %@", registered)
        super.viewWillDisappear(animated)
    }
    
    /*
    認証ステータスを取得.
    */
    func getAuthorization_status() -> Bool {
        
        // ステータスを取得.
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        // ステータスを表示 許可されている場合のみtrueを返す.
        switch status {
        case EKAuthorizationStatus.NotDetermined:
            print("NotDetermined")
            return false
            
        case EKAuthorizationStatus.Denied:
            print("Denied")
            return false
            
        case EKAuthorizationStatus.Authorized:
            print("Authorized")
            return true
            
        case EKAuthorizationStatus.Restricted:
            print("Restricted")
            return false            
        }
    }
    
    /*
    認証許可.
    */
    func allowAuthorization() {
        
        // 許可されていなかった場合、認証許可を求める.
        if getAuthorization_status() {
            return
        } else {
            
            // ユーザーに許可を求める.
            eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
                (granted , error) -> Void in
                
                // 許可を得られなかった場合アラート発動.
                if granted {
                    return
                }
                else {
                    
                    // メインスレッド 画面制御. 非同期.
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // アラート生成.
                        let myAlert = UIAlertController(title: NSLocalizedString("privacy_alert_title", comment: ""),
                            message: NSLocalizedString("privacy_alert_message", comment: ""),
                            preferredStyle: UIAlertControllerStyle.Alert)
                        
                        // アラートアクション.
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        
                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    })
                }
            })
        }
    }
    
    //-- TableView --//
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionItems.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionItems[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return myList.count
        } else if section == 1 {
            return otherList.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        
        var cal:EKCalendar!
        if indexPath.section == 0 {
            cal = myList.objectAtIndex(indexPath.row) as! EKCalendar
        } else if indexPath.section == 1 {
            cal = otherList.objectAtIndex(indexPath.row) as! EKCalendar
        }
        
        let identifier:String = cal.calendarIdentifier
        let title:String = "■" + cal.title
        
        let tmpSwitch:EXUISwitch = EXUISwitch()
        tmpSwitch.calendar = cal
        tmpSwitch.addTarget(self, action: "onClickMySwicth:", forControlEvents: UIControlEvents.ValueChanged)
        if (registered[ identifier ] == nil) {
            tmpSwitch.on = true
        } else {
            tmpSwitch.on = false
        }
        cell.textLabel?.text = title
        cell.textLabel?.textColor = UIColor(CGColor: cal.CGColor)
        cell.textLabel?.font = FontManager.getSettingCellText()
        cell.accessoryView = tmpSwitch
        
        return cell
    }
    
    //-- UISwitch --//
    func onClickMySwicth(sender: EXUISwitch){
        let cal:EKCalendar = sender.calendar
        let targetId:String = cal.calendarIdentifier
        let targetTitle:String = cal.title
        if sender.on == false {
            registered[ targetId ] = targetTitle
        } else {
            registered.removeValueForKey(targetId)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
