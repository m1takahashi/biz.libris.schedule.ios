//
//  ReminderItemFormViewController.swift
//  TODO: リストで画面遷移があるので、reminder情報は、逐次保存しておく
//

import UIKit
import EventKit

class ReminderEditViewController: ReminderViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var tableViewList: UITableView!
    var titleField:UITextField!
    var prioritySegCtr:UISegmentedControl!
    var alarmSwitch:UISwitch!
    var alarmDatePicker:UIDatePicker!
    
    let sections:Int = 2
    let items:[Int] = [5,1]
    
    var calendar:EKCalendar!
    var reminder:EKReminder!
    
    var skipViewWillAppear:Bool = false
    
    let minLength:Int = 1
    let maxLength:Int = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        if reminder == nil {
            self.navigationItem.title = NSLocalizedString("reminder_item_add", comment: "")
        } else {
            self.navigationItem.title = NSLocalizedString("reminder_item_details", comment: "")
        }
        
        let rightButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done,
            target: self,
            action: "onSaveButton:")
        self.navigationItem.rightBarButtonItem = rightButton
        
        let leftButton = UIBarButtonItem(title: NSLocalizedString("reminder_item_close", comment: ""),
            style: .Plain,
            target: self,
            action: "onCloseButton:")
        self.navigationItem.leftBarButtonItem = leftButton
        
        tableViewList = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), style: .Grouped)
        tableViewList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewList.dataSource = self
        tableViewList.delegate = self
        self.view.addSubview(tableViewList)
        
        // Title
        let width:CGFloat   = self.view.frame.size.width
        let height:CGFloat  = 44.0
        let margin:CGFloat  = 15.0
        titleField = UITextField(frame: CGRectMake(margin, 0, width - margin * 2, height))
        titleField.placeholder = NSLocalizedString("reminder_item_title", comment: "")
        titleField.delegate = self
        
        // Priority
        let items:[String] = [NSLocalizedString("reminder_priority_none", comment: ""),
            NSLocalizedString("reminder_priority_low", comment: ""),
            NSLocalizedString("reminder_priority_normal", comment: ""),
            NSLocalizedString("reminder_priority_high", comment: "")]
        prioritySegCtr = UISegmentedControl(items: items)
        prioritySegCtr.frame = CGRectMake(0, 0, 150, 30)
        prioritySegCtr.addTarget(self,
            action: "changePriority:",
            forControlEvents: .ValueChanged);
        
        // Alarm
        alarmSwitch = UISwitch()
        
        // Alarm Date
        alarmDatePicker = UIDatePicker()
        alarmDatePicker.minuteInterval = 5;
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if skipViewWillAppear {
            skipViewWillAppear = false
            tableViewList.reloadData()
            return
        }
        
        if reminder != nil {
            calendar = reminder.calendar
            titleField.text = reminder.title
            prioritySegCtr.selectedSegmentIndex = reminder.priority

            // Alarm
            var date:NSDate = getDefaultDate()
            if reminder.hasAlarms {
                alarmSwitch.setOn(true, animated: false)
                for alarm in reminder.alarms! {
                    let tmp:NSDate = alarm.absoluteDate! // 基本的に一つ
                    // 再通知（15分後）などで別のアプリでセットされると、秒がずれる可能性がある
                    date = NSDate.create(year: tmp.year,
                        month: tmp.month,
                        day: tmp.day,
                        hour: tmp.hour,
                        minute: tmp.minute,
                        second: 0)!
                }
            } else {
                alarmSwitch.setOn(false, animated: false)
            }
            alarmDatePicker.date = date

        } else {
            // Create New
//            println("--- Create New ---")
            reminder = EKReminder(eventStore: eventStore)
            if calendar == nil {
                calendar = calendars[0] // 基本的には呼び出し元でセットする
            }
            reminder.calendar = calendar
            alarmDatePicker.date = self.getDefaultDate() // Alarm
            
            prioritySegCtr.selectedSegmentIndex = ReminderPriority.None.rawValue
            alarmSwitch.setOn(false, animated: false)
        }
    }
    
    //-- Action --//
    func onSaveButton(sender: UIBarButtonItem) {
        if !save() {
            return
        }
        NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameReminderBackForm(),
            object: nil,
            userInfo: ["reminder":reminder])
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onCloseButton(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() -> Bool {
        let title:String = titleField.text!
        let date:NSDate = alarmDatePicker.date
        NSLog("Alarm Date : %@", date)
        
        // 入力チェック
        if !TextValidation.length(title, min: minLength, max: maxLength) {
            self.view.makeToast(NSLocalizedString("msg_reminder_length", comment: ""),
                duration: (NSTimeInterval)(2.0),
                position: CSToastPositionCenter)
            return false
        }
        
        reminder.title = title
        
        // Alarm, DueDate クリア
        reminder.dueDateComponents = nil
        if (reminder.alarms != nil) {
            for alarm in reminder.alarms! {
                reminder.removeAlarm(alarm)
            }
        }
        
        // Alarm, DueDate セット
        if (alarmSwitch.on) {
            let cal = NSCalendar.currentCalendar()
            let components = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: date)
            reminder.dueDateComponents = components
            
            let alarm:EKAlarm = EKAlarm(absoluteDate: date)
            reminder.addAlarm(alarm)
        }
        NSLog("%@", reminder) // TODO:
        
        var writeError: NSError?
        do {
            try eventStore.saveReminder(reminder, commit: true)
        } catch let error1 as NSError {
            writeError = error1
            if let error = writeError {
                print("write failure: \(error.localizedDescription)")
                self.view.makeToast(NSLocalizedString("msg_reminder_restart", comment: ""),
                    duration: (NSTimeInterval)(2.0),
                    position: CSToastPositionCenter)
                return false
            }
        }
        
        return true
    }
    
    func remove() {
        var writeError: NSError?
        do {
            try eventStore.removeReminder(reminder, commit: true)
        } catch let error1 as NSError {
            writeError = error1
            if let error = writeError {
                print("write failure: \(error.localizedDescription)")
            }
        }
    }
    
    
    //-- TableView --//
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == NSIndexPath(forRow: 4, inSection: 0) {
            return 220
        } else {
            return 42
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "MyCell")
        cell.selectionStyle = .None
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.contentView.addSubview(titleField)
            } else if indexPath.row == 1 {
                cell.textLabel?.text = NSLocalizedString("reminder_item_priority", comment: "")
                cell.accessoryView = prioritySegCtr
            } else if indexPath.row == 2 {
                cell.textLabel?.text = NSLocalizedString("reminder_item_list", comment: "")
                cell.detailTextLabel?.text = calendar.title
            } else if indexPath.row == 3 {
                cell.textLabel?.text = NSLocalizedString("reminder_item_remind_me_on_a_day", comment: "")
                cell.accessoryView = alarmSwitch
            } else if indexPath.row == 4 {
                cell.addSubview(alarmDatePicker)
            }
            break;
        case 1:
            let removeLabel:UILabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.size.width, 44))
            removeLabel.text = NSLocalizedString("reminder_item_remove", comment: "")
            removeLabel.textColor = ColorManager.getReminderRemove()
            removeLabel.textAlignment = .Center
            cell.addSubview(removeLabel)
            break;
        default:
            break;
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == NSIndexPath(forRow: 0, inSection: 1) {
            let oldReminder = reminder
            remove()
            // 画面リロード
            NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameReminderBackForm(),
                object: nil,
                userInfo: ["reminder":oldReminder])
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    //-- SegCtr --//
    func changePriority(sender: UISegmentedControl) {
        reminder.priority = sender.selectedSegmentIndex
    }
    
    //-- DateUtil --//
    // 1時間後で５分刻みのデフォルト日時を取得する
    // 19:14 -> 20:15
    private func getDefaultDate() -> NSDate {
        let interval:Int = 5 // 5分刻み
        
        var date:NSDate = NSDate()
        let diff = interval - (date.minute % interval)

        // 0秒にする
        let fixedDate:NSDate = NSDate.create(year: date.year,
            month: date.month,
            day: date.day,
            hour: date.hour,
            minute: date.minute,
            second: 0)!
        
        var time:NSTimeInterval = fixedDate.timeIntervalSinceReferenceDate
        time = time + (NSTimeInterval)((60 * 60 * 1) + (60 * diff)) // 1h + 5m
        
        date = NSDate(timeIntervalSinceReferenceDate: time)
        return date;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
