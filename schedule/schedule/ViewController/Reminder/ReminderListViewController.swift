//
//  ReminderListViewController.swift
//  http://tech.admax.ninja/2014/10/21/how-to-edit-ui-tableview/
//  http://oleb.net/blog/2012/05/creating-and-deleting-calendars-in-ios/
//

import UIKit
import EventKit

class ReminderListViewController: ReminderViewController, UITableViewDelegate, UITableViewDataSource {
    var tableViewList: UITableView!
    let tabBarHeight:CGFloat = 44.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = NSLocalizedString("reminder_calenders", comment: "")
        let leftButton = UIBarButtonItem(title: NSLocalizedString("reminder_calendar_close", comment: ""),
            style: .Plain,
            target: self,
            action: "onCloseButton:")
        self.navigationItem.leftBarButtonItem = leftButton
        
        let rightButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit,
            target: self,
            action: "onEditButton:")
        self.navigationItem.rightBarButtonItem = rightButton

        tableViewList = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - tabBarHeight))
        tableViewList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewList.backgroundColor = UIColor.clearColor()
        tableViewList.dataSource = self
        tableViewList.delegate = self
        tableViewList.scrollEnabled = true
        self.view.addSubview(tableViewList)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initTabBar()
        tableViewList.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func onCloseButton(sender: UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onEditButton(sender: UIBarButtonItem) {
        if tableViewList.editing {
            tableViewList.setEditing(false, animated: true)
            ReminderSeq.saveSortData(calendars)
        } else {
            if calendars.count <= 1 {
                self.view.makeToast(NSLocalizedString("msg_reminder_list_more_one", comment: ""),
                    duration: (NSTimeInterval)(2.0),
                    position: CSToastPositionCenter)
                return
            }
            tableViewList.setEditing(true, animated: true)
        }
    }
    
    //-- TabBar --//
    func initTabBar() {
        let tabBarView:UIView = UIView(frame: CGRectMake(0, self.view.frame.size.height - tabBarHeight, self.view.frame.size.width, tabBarHeight))
        let image:UIImage = UIImage(named: "Border_Tab")!
        tabBarView.backgroundColor = UIColor(patternImage: image)
        self.view.addSubview(tabBarView)
        
        let buttonAdd:UIButton = UIButton(frame: CGRectMake(0, 0, tabBarView.bounds.size.width, tabBarView.bounds.size.height))
        buttonAdd.setTitle(NSLocalizedString("reminder_calendar_add", comment: ""), forState: .Normal)
        buttonAdd.setTitleColor(UIColor(hexString: theme.tabSegctr, alpha: 1.0), forState: .Normal)
        buttonAdd.addTarget(self,
            action: "onAddButton:",
            forControlEvents:.TouchUpInside)
        tabBarView.addSubview(buttonAdd)
    }
    
    //-- Action --//
    func onAddButton(sender: UIButton) {
        self.navigationController?.pushViewController(ReminderListEditViewController(), animated: true)
    }
    
    //-- TableView --//
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let view = ReminderListEditViewController()
        view.calendar = calendars[indexPath.row]
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        cell.backgroundColor = UIColor.clearColor()
        let calendar:EKCalendar = calendars[indexPath.row]
        cell.textLabel?.textColor = ColorManager.getDrawerCellText()
        cell.textLabel?.font = FontManager.getDrawerCellText()
        cell.textLabel?.text = calendar.title
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    //-- Delete --//
    // カレンダーが一つしかない場合には、削除ボタンを表示しない
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if calendars.count <= 1 && indexPath == NSIndexPath(forRow: 0, inSection: 0) {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if calendars.count <= 1 {
            self.view.makeToast(NSLocalizedString("msg_reminder_list_more_one", comment: ""),
                duration: (NSTimeInterval)(2.0),
                position: CSToastPositionCenter)
            return
        }
        
        switch editingStyle {
        case .Delete:
            let calendar:EKCalendar = calendars[indexPath.row]
            var writeError: NSError?
            do {
                try eventStore.removeCalendar(calendar, commit: true)
            } catch let error1 as NSError {
                writeError = error1
                if let error = writeError {
                    print("Error, Reminder remove failure: \(error.localizedDescription)")
                }
            }
            calendars.removeAtIndex(indexPath.row)
            tableViewList.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        default:
            return
        }
    }
    
    // Move
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        print("Source : \(sourceIndexPath.row), Dist : \(destinationIndexPath.row)")
        
        var swap1:EKCalendar!
        var swap2:EKCalendar!
        
        if sourceIndexPath.row > destinationIndexPath.row {
            // 上へ
            for (var i = 0; i <= calendars.count; i++) {
                if (i < destinationIndexPath.row) {
                    // なにもしない
                } else if (i == destinationIndexPath.row) {
                    swap1 = calendars[i]
                    calendars[i] = calendars[sourceIndexPath.row]
                } else if (i == sourceIndexPath.row) {
                    calendars[i] = swap1
                    break;
                } else if (i == calendars.count) {
                    calendars[i - 1] = swap1
                } else {
                    swap2 = calendars[i]
                    calendars[i] = swap1
                    swap1 = swap2
                }
            }
            
        } else if sourceIndexPath.row < destinationIndexPath.row {
            // 下へ移動
            for (var i = calendars.count; i >= 0; i--) {
                if (i > destinationIndexPath.row) {
                    // なしもしない
                } else if (i == destinationIndexPath.row) {
                    swap1 = calendars[i]
                    calendars[i] = calendars[sourceIndexPath.row]
                } else if (i == sourceIndexPath.row) {
                    calendars[i] = swap1
                    break;
                } else if (i <= 0) {
                    calendars[0] = swap1
                } else {
                    swap2 = calendars[i]
                    calendars[i] = swap1
                    swap1 = swap2
                }
            }
        }
        tableViewList.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
