//
//  SettingCalStartWeekViewController.swift
//  週の開始設定
//

import UIKit

class SettingCalStartWeekViewController: SettingViewController, UITableViewDataSource, UITableViewDelegate {
    var tableViewList: UITableView!
    
    var labels:[String]!
    var values:[Int]!
    
    var startWeekday:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = NSLocalizedString("setting_cal_start_week", comment: "")

        labels = [NSLocalizedString("sunday", comment: ""),
            NSLocalizedString("monday", comment: ""),
            NSLocalizedString("tuesday", comment: ""),
            NSLocalizedString("wednesday", comment: ""),
            NSLocalizedString("thursday", comment: ""),
            NSLocalizedString("friday", comment: ""),
            NSLocalizedString("saturday", comment: "")]
        
        values = [StartWeek.Sunday.rawValue,
            StartWeek.Monday.rawValue,
            StartWeek.Tuesday.rawValue,
            StartWeek.Wednesday.rawValue,
            StartWeek.Thursday.rawValue,
            StartWeek.Friday.rawValue,
            StartWeek.Saturday.rawValue]
        
        tableViewList = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        tableViewList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewList.dataSource = self
        tableViewList.delegate = self
        tableViewList.allowsMultipleSelection = false
        self.view.addSubview(tableViewList)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startWeekday = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyStartWeekday.rawValue, defaultValue: StartWeek.Sunday.rawValue)
    }
    
    override func viewWillDisappear(animated: Bool) {
        UDWrapper.setInt(UDWrapperKey.UDWrapperKeyStartWeekday.rawValue, value: startWeekday)
        super.viewWillDisappear(animated)
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        startWeekday = values[indexPath.row]
        tableViewList.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        cell.backgroundColor = UIColor.clearColor()
        if (indexPath.row == (startWeekday - 1)) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        let week:String = labels[indexPath.row]
        cell.textLabel?.text = week
        cell.textLabel?.textColor = ColorManager.getSettingCellText()
        cell.textLabel?.font = FontManager.getSettingCellText()
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}