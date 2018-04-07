//
//  SettingCalViewController.swift
//  カレンダー設定
//

import UIKit

class SettingCalViewController: SettingViewController, UITableViewDataSource, UITableViewDelegate {
    var tableViewCal:UITableView!
    
    let items:[NSString] = [NSLocalizedString("setting_cal_display_list", comment: ""),
        NSLocalizedString("setting_cal_holiday", comment: ""),
        NSLocalizedString("setting_cal_start_week", comment: ""),
        NSLocalizedString("setting_cal_start_page", comment: ""),
        NSLocalizedString("setting_cal_scroll", comment: ""),
        NSLocalizedString("setting_cal_scroll_week", comment: ""),
        NSLocalizedString("setting_cal_six_labels", comment: "")]
    
    let rokuyouSwitchTag:Int = 1
    var rokuyou:Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("setting_cal", comment: "")
        super.initLeftBarButton()
        
        tableViewCal = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        tableViewCal.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewCal.dataSource = self
        tableViewCal.delegate = self
        self.view.addSubview(tableViewCal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        rokuyou = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyRokuyou.rawValue, defaultValue: true)
        tableViewCal.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        UDWrapper.setBool(UDWrapperKey.UDWrapperKeyRokuyou.rawValue, value: rokuyou)
        super.viewWillDisappear(animated)
    }
    
    //-- TableView --//
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0) {
            self.navigationController?.pushViewController(SettingCalListViewController(), animated: true)
        } else if (indexPath.row == 1) {
            self.navigationController?.pushViewController(SettingCalHolidayViewController(), animated: true)
        } else if (indexPath.row == 2) {
            self.navigationController?.pushViewController(SettingCalStartWeekViewController(), animated: true)
        } else if (indexPath.row == 3) {
            self.navigationController?.pushViewController(SettingCalStartPageViewController(), animated: true)
        } else if (indexPath.row == 4) {
            self.navigationController?.pushViewController(SettingCalScrollViewController(), animated: true)
        } else if (indexPath.row == 5) {
            self.navigationController?.pushViewController(SettingCalScrollWeekViewController(), animated: true)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "MyCell")
        
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = ColorManager.getSettingCellText()
        cell.textLabel?.font = FontManager.getSettingCellText()
        let str:String = items[indexPath.row] as String
        cell.textLabel?.text = str

        if (indexPath.row == items.count - 1) {
            // 六曜（最後）
            let tmpSwitch: UISwitch = UISwitch()
            tmpSwitch.on = rokuyou
            tmpSwitch.tag = rokuyouSwitchTag
            tmpSwitch.addTarget(self, action: "onClickMySwicth:", forControlEvents: UIControlEvents.ValueChanged)
            cell.selectionStyle = UITableViewCellSelectionStyle.None;
            cell.accessoryView = tmpSwitch
            
        } else if (indexPath.row == 2) {
            // 週の開始
            let startWeekday = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyStartWeekday.rawValue,
                defaultValue: StartWeek.Sunday.rawValue)
            var weekLabels:[String] = CalendarUtil.getWeekLabelFull()
            let weekText:String = weekLabels[startWeekday - 1]

            cell.detailTextLabel?.text = NSLocalizedString(weekText, comment: "")
            cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
            cell.detailTextLabel?.font = UIFont.boldSystemFontOfSize(14.0)
            cell.accessoryType = .DisclosureIndicator
        
        } else if (indexPath.row == 3) {
            // Start Page Mode
            let startPageMode:Int = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyStartPageMode.rawValue,
                defaultValue: StartPageMode.Calendar.rawValue)

            var str:String = ""
            if startPageMode == StartPageMode.Reminder.rawValue{
                str = NSLocalizedString("start_page_section_mode_reminder", comment: "")
            } else {
                // Start Page Calendar
                let startPage:Int = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyStartPage.rawValue,
                    defaultValue: StartPageType.Month.rawValue)
                
                if startPage == StartPageType.Week.rawValue {
                    str = NSLocalizedString("start_page_week", comment: "")
                } else if startPage == StartPageType.Day.rawValue {
                    str = NSLocalizedString("start_page_day", comment: "")
                } else if startPage == StartPageType.Month.rawValue {
                    str = NSLocalizedString("start_page_month", comment: "")
                }
            }
            
            cell.detailTextLabel?.text = str
            cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
            cell.detailTextLabel?.font = UIFont.boldSystemFontOfSize(14.0)
            cell.accessoryType = .DisclosureIndicator

        } else if (indexPath.row == 4) {
            // 月スクロール
            let scrollDirection:Int = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyScrollDirection.rawValue,
                defaultValue: ScrollDirection.Vertical.rawValue)
            var str:String = ""
            if scrollDirection == ScrollDirection.Horizontal.rawValue {
                str = NSLocalizedString("scroll_direction_horizontal", comment: "")
            } else if scrollDirection == ScrollDirection.Vertical.rawValue {
                str = NSLocalizedString("scroll_direction_vertical", comment: "")
            }
            cell.detailTextLabel?.text = str
            cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
            cell.detailTextLabel?.font = UIFont.boldSystemFontOfSize(14.0)
            cell.accessoryType = .DisclosureIndicator
            
        } else if (indexPath.row == 5) {
            // 週スクロール
            let scrollDirectionWeek:Int = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyScrollDirectionWeek.rawValue,
                defaultValue: ScrollDirection.Horizontal.rawValue)
            var str:String = ""
            if scrollDirectionWeek == ScrollDirection.Horizontal.rawValue {
                str = NSLocalizedString("scroll_direction_horizontal", comment: "")
            } else if scrollDirectionWeek == ScrollDirection.Vertical.rawValue {
                str = NSLocalizedString("scroll_direction_vertical", comment: "")
            }
            cell.detailTextLabel?.text = str
            cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
            cell.detailTextLabel?.font = UIFont.boldSystemFontOfSize(14.0)
            cell.accessoryType = .DisclosureIndicator

        } else {
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        return cell
    }
   
    //-- UISwitch --//
    func onClickMySwicth(sender: UISwitch){
        if sender.tag == rokuyouSwitchTag {
            rokuyou = sender.on
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
