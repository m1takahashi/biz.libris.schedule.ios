//
//  SettingCalHolidayViewController.swift
//

import UIKit

class SettingCalHolidayViewController: SettingViewController, UITableViewDelegate, UITableViewDataSource{
    
    var tableViewList: UITableView!
    
    let sectionItems:[String] = [NSLocalizedString("cal_holiday_select", comment: ""),
        NSLocalizedString("cal_holiday_custom", comment: "")]
    
    let selectItems:[String] = [NSLocalizedString("cal_holiday_default", comment: ""),
        NSLocalizedString("cal_holiday_custom", comment: "")]
    
    let customItems:[String] = [NSLocalizedString("sunday", comment:""),
        NSLocalizedString("monday", comment:""),
        NSLocalizedString("tuesday", comment: ""),
        NSLocalizedString("wednesday", comment:""),
        NSLocalizedString("thursday", comment:""),
        NSLocalizedString("friday", comment:""),
        NSLocalizedString("saturday", comment:"")]

    var holidayType:Int!
    var holidayCustom:[Bool]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = NSLocalizedString("setting_cal_holiday", comment: "")
        
        tableViewList = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), style: .Grouped)
        tableViewList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewList.dataSource = self
        tableViewList.delegate = self
        self.view.addSubview(tableViewList)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        holidayType = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyHolidayType.rawValue, defaultValue: HolidayType.Default.rawValue)
        print("holidayType : \(holidayType)")

        holidayCustom = UDWrapper.getArray(UDWrapperKey.UDWrapperKeyHolidayCustom.rawValue, defaultValue: Holiday.getDefaultCustom()) as! [Bool]
        NSLog("holidayCustom : %@", holidayCustom)
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("Holiday Type : \(holidayType)")
        NSLog("Holiday Custom : %@", holidayCustom)
        UDWrapper.setInt(UDWrapperKey.UDWrapperKeyHolidayType.rawValue, value: holidayType)
        UDWrapper.setArray(UDWrapperKey.UDWrapperKeyHolidayCustom.rawValue, value: holidayCustom)
        super.viewWillDisappear(animated)
    }
    
    // 土日を選択した場合には、カスタムをクリアにする
    private func resetCustomData() {
        for (var i = 0; i < holidayCustom.count; i++) {
            holidayCustom[i] = false
        }
    }
    
    // カスタムを選択した場合には、土日がデフォルトで選択されているようにする
    private func setCustomDataDefault() {
        for (var i = 0; i < holidayCustom.count; i++) {
            if (i == 0 || i == 6) {
                holidayCustom[i] = true
            } else {
                holidayCustom[i] = false
            }
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
        if (section == 0) {
            return selectItems.count
        } else if (section == 1) {
            return customItems.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        cell.selectionStyle = .None
        
        var title:String = ""
        if (indexPath.section == 0) {
            title = selectItems[ indexPath.row ]
            if (indexPath.row == holidayType) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }

        } else if (indexPath.section == 1) {
            title = customItems[ indexPath.row ]
            if (holidayCustom[ indexPath.row ] == true) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        cell.textLabel?.text = title
        cell.textLabel?.textColor = ColorManager.getSettingCellText()
        cell.textLabel?.font = FontManager.getSettingCellText()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                holidayType = HolidayType.Default.rawValue
            } else if (indexPath.row == 1) {
                holidayType = HolidayType.Custom.rawValue
            }
            if (holidayType == HolidayType.Default.rawValue) {
                resetCustomData()
            } else if (holidayType == HolidayType.Custom.rawValue) {
                setCustomDataDefault()
            }
        } else if (indexPath.section == 1) {
            if (holidayCustom[ indexPath.row ] == true) {
                holidayCustom[ indexPath.row ] = false
            } else {
                holidayCustom[ indexPath.row ] = true
            }
        }
        tableViewList.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
