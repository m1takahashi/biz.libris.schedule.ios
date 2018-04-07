//
//  SettingCalStartPageViewController.swift
//

import UIKit

class SettingCalStartPageViewController: SettingViewController, UITableViewDataSource, UITableViewDelegate {
    var tableViewList:UITableView!
    
    let sectionItems:[String] = [NSLocalizedString("start_page_section_mode", comment: ""),
        NSLocalizedString("start_page_section_mode_calendar", comment: "")]
    
    let modeItems:[String] = [NSLocalizedString("start_page_section_mode_calendar", comment: ""),
        NSLocalizedString("start_page_section_mode_reminder", comment: ""),
        NSLocalizedString("start_page_section_mode_note", comment: "")]
    
    let list:[NSString] = [NSLocalizedString("start_page_month", comment: ""),
        NSLocalizedString("start_page_week", comment: ""),
        NSLocalizedString("start_page_day", comment: "")]
    
    var startPageMode:Int!
    var startPage:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = NSLocalizedString("setting_cal_start_page", comment: "")
        
        tableViewList = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), style: .Grouped)
        tableViewList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewList.dataSource = self
        tableViewList.delegate = self
        tableViewList.allowsMultipleSelection = false
        self.view.addSubview(tableViewList)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startPage = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyStartPage.rawValue, defaultValue: StartPageType.Month.rawValue)
        startPageMode = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyStartPageMode.rawValue, defaultValue: StartPageMode.Calendar.rawValue)
    }
    
    override func viewWillDisappear(animated: Bool) {
        UDWrapper.setInt(UDWrapperKey.UDWrapperKeyStartPage.rawValue, value: startPage)
        UDWrapper.setInt(UDWrapperKey.UDWrapperKeyStartPageMode.rawValue, value: startPageMode)
        super.viewWillDisappear(animated)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionItems.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionItems[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return modeItems.count
        } else if (section == 1) {
            return list.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            startPageMode = indexPath.row
        } else if indexPath.section == 1 {
            startPage = indexPath.row
        }
        tableViewList.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        cell.textLabel?.textColor = ColorManager.getSettingCellText()
        cell.textLabel?.font = FontManager.getSettingCellText()
        
        if indexPath.section == 0 {
            cell.textLabel?.text = modeItems[indexPath.row]
            if (indexPath.row == startPageMode) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
        } else if indexPath.section == 1 {
            if (indexPath.row == startPage) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            let week:String = list[indexPath.row] as String
            cell.textLabel?.text = week
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
