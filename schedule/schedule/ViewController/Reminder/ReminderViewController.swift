//
//  ReminderViewController.swift
//  リマインダ基底クラス
//  note:
//  EventStoreのシングルトンは利用しない
//  初回起動時の認証のタイミングなどを考慮する
//

import UIKit
import EventKit
import EventKitUI

class ReminderViewController: UIViewController, UIScrollViewDelegate {
    var eventStore:EKEventStore!
    var calendars:[EKCalendar] = [] // 初期化必須
    var theme:ThemeData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventStore = EventStoreReminder.sharedInstance
        allowAuthorization()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // 認証が完了している場合には、リストは存在する
        if getAuthorization_status() {
            let rawCalendars = eventStore.calendarsForEntityType(EKEntityType.Reminder) 
            calendars = ReminderSeq.getSortedCalendars(rawCalendars)
        }
        
        // Theme
        let themeId:String = UDWrapper.getString(UDWrapperKey.UDWrapperKeyTheme.rawValue, defaultValue:"")!
        if (themeId.hasPrefix("Custom")) {
            theme = ThemeDataUtil.getCustomData()
        } else {
            theme = ThemeDataUtil.getThemeById(themeId)
        }
    }
    
    // Reminder Auth
    // 初回の認証はEULAの時点で完了している
    // NotDeterminedの状態にはなっていないはず
    func getAuthorization_status() -> Bool {
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityType.Reminder)
        switch status {
        case EKAuthorizationStatus.NotDetermined:
            print("Reminder Auth : NotDetermined")
            return false
            
        case EKAuthorizationStatus.Denied:
            print("Reminder Auth : Denied")
            return false
            
        case EKAuthorizationStatus.Authorized:
            print("Reminder Auth : Authorized")
            return true
            
        case EKAuthorizationStatus.Restricted:
            print("Reminder Auth : Restricted")
            return false
            
        }
    }
    func allowAuthorization() {
        if getAuthorization_status() {
            return
        } else {
            eventStore.requestAccessToEntityType(EKEntityType.Reminder, completion: {
                (granted , error) -> Void in
                if granted {
                    return
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let myAlert = UIAlertController(title: NSLocalizedString("privacy_alert_title", comment: ""),
                            message: NSLocalizedString("privacy_alert_message_reminder", comment: ""),
                            preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK",
                            style: UIAlertActionStyle.Default,
                            handler: nil)
                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    })
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
