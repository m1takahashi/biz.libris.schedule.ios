//
//  ReminderView.swift
//

import UIKit
import EventKit

class ReminderView: UIView, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var tableViewList: UITableView!
    let imageCheckmarkOn:UIImage    = UIImage(named: "Icon_Reminder_Checkmark_ON")!
    let imageCheckmarkOff:UIImage   = UIImage(named: "Icon_Reminder_Checkmark_OFF")!

    let calendarTextMargin:CGFloat  = 10.0
    let calendarTextFont:UIFont     = UIFont.boldSystemFontOfSize(32.0)
    
    let reminderTextFont:UIFont     = UIFont.boldSystemFontOfSize(14.0)
    let reminderTextColor:UIColor   = UIColor.darkGrayColor()
    
    let checkmarkWidth:CGFloat = 44.0

    var width:CGFloat!
    var height:CGFloat!

    var eventStore:EKEventStore!
    var theme:ThemeData!
    var orgList:[EKReminder] = []
    var list:[EKReminder] = []
    var calendar:EKCalendar!
    
    var _displayCompleted:Bool   = true
    var isAdding:Bool           = false

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, theme: ThemeData, eventStore: EKEventStore, calendar: EKCalendar) {
        super.init(frame:frame)
        self.theme = theme
        self.eventStore = eventStore
        self.calendar = calendar
        
        width = self.frame.size.width
        height = self.frame.size.height
    
        tableViewList = UITableView(frame: CGRectMake(0, 0, width, height))
        tableViewList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewList.dataSource = self
        tableViewList.delegate = self
        tableViewList.scrollEnabled = true
        
        tableViewList.separatorInset = UIEdgeInsetsZero
        if (tableViewList.respondsToSelector("layoutMargins")) {
            tableViewList.layoutMargins = UIEdgeInsetsZero;
        }
        self.addSubview(tableViewList)
    }

    func setReminder(reminders:[EKReminder]) {
        orgList = reminders
        list = sort(reminders)
        tableViewList.reloadData()
    }
    
    // 完了項目の表示非表示
    func setDisplayCompleted(flag:Bool) {
        _displayCompleted = flag
        
        list = [] // 初期化
        for reminder in orgList {
            if flag {
                list.append(reminder) // すべて
            } else {
                if !reminder.completed {
                    list.append(reminder) // 未完了のみ
                }
            }
        }

        list = sort(list)
        tableViewList.reloadData()
    }
    
    // ソート
    func sort(raws:[EKReminder]) -> [EKReminder] {
        var incomplete:[EKReminder] = []
        var completed:[EKReminder] = []
        
        // 完済み・未完了で分ける
        for reminder in raws {
            if reminder.completed {
                completed.append(reminder)
            } else {
                incomplete.append(reminder)
            }
        }
        
        incomplete.sortInPlace {(lhs, rhs) in return lhs.priority > rhs.priority }
        completed.sortInPlace {(lhs, rhs) in return lhs.priority > rhs.priority }
        
        return incomplete + completed
    }
    
    //-- TableView --//
    // 詳細ボタンタップ
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameReminderDisplayForm(),
            object: nil,
            userInfo: ["reminder":list[indexPath.row]])
    }
    
    // チェックマークタップ
    func imageViewTapped(sender: UITapGestureRecognizer) {
        let point:CGPoint = sender.locationInView(self.tableViewList)
        let indexPath:NSIndexPath = self.tableViewList.indexPathForRowAtPoint(point)!
        
        let reminder = list[indexPath.row]
        if reminder.completed {
            reminder.completed = false
            reminder.completionDate = nil
        } else {
            reminder.completed = true
            reminder.completionDate = NSDate()  // 現在
        }
        
        var writeError: NSError?
        do {
            try eventStore.saveReminder(reminder, commit: true)
        } catch let error1 as NSError {
            writeError = error1
            if let error = writeError {
                print("Error, Reminder write failure: \(error.localizedDescription)")
            }
        }
        
        list[indexPath.row] = reminder
        setDisplayCompleted(_displayCompleted)
        tableViewList.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! UITableViewCell
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "MyCell")

        cell.backgroundColor = UIColor.clearColor()
        cell.tintColor = UIColor(hexString: theme.tabSegctr, alpha: 1.0)
        cell.selectionStyle = .None
        cell.separatorInset = UIEdgeInsetsZero;
        if (cell.respondsToSelector("layoutMargins")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        let reminder:EKReminder = list[indexPath.row]
        
        // Check Button
        var image:UIImage!
        if reminder.completed {
            image = imageCheckmarkOn
        } else {
            image = imageCheckmarkOff
        }
        image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.imageView?.image = image
        cell.imageView?.userInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        cell.imageView?.addGestureRecognizer(tap)
        
        // Title
        cell.textLabel?.text = reminder.title
        cell.textLabel?.textColor = ColorManager.getReminderCellText()
        cell.textLabel?.font = FontManager.getReminderCellText()
        
        var priority:String = NSLocalizedString("reminder_priority_none", comment: "")
        switch reminder.priority {
        case 3:
            priority = NSLocalizedString("reminder_priority_high", comment: "")
            break;
        case 2:
            priority = NSLocalizedString("reminder_priority_normal", comment: "")
            break;
        case 1:
            priority = NSLocalizedString("reminder_priority_low", comment: "")
            break;
        default:
            priority = NSLocalizedString("reminder_priority_none", comment: "")
            break;
        }
        cell.detailTextLabel?.text = priority
        cell.detailTextLabel?.textColor = ColorManager.getReminderCellTextDetail()
        cell.detailTextLabel?.font = FontManager.getReminderCellTextDetail()

        
        // Detail Button
        cell.accessoryType = UITableViewCellAccessoryType.DetailButton
        
        return cell
    }
}