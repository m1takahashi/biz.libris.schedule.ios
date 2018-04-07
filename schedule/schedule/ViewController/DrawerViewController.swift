//
//  LeftSideDrawerViewController.swift
//

import UIKit

class DrawerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableViewDrawer: UITableView!
    var themeData:ThemeData!
    
    let sectionItems:[String] = [
        NSLocalizedString("menu", comment: ""),
        NSLocalizedString("setting", comment: "")]
    
    let basicItems:[String] = [
        NSLocalizedString("calender", comment:""),
        NSLocalizedString("reminder", comment:""),
        NSLocalizedString("note", comment:"")]
    
    let settingItems:[String] = [
        NSLocalizedString("setting_theme", comment:""),
        NSLocalizedString("setting_cal", comment: ""),
        NSLocalizedString("setting_other", comment:"")]

    var skipViewWillAppear:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height

        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight:CGFloat = 324.0 // Design: 固定

        tableViewDrawer = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight))
        tableViewDrawer.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewDrawer.backgroundColor = UIColor.clearColor()
        tableViewDrawer.dataSource = self
        tableViewDrawer.delegate = self
        tableViewDrawer.scrollEnabled = false
        self.view.addSubview(tableViewDrawer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 再読み込み不要
        if skipViewWillAppear {
            skipViewWillAppear = false
            return
        }
        
        let themeId:String = UDWrapper.getString(UDWrapperKey.UDWrapperKeyTheme.rawValue, defaultValue:"")!
        if (themeId.hasPrefix("Custom")) {
            themeData = ThemeDataUtil.getCustomData()
        } else {
            themeData = ThemeDataUtil.getThemeById(themeId)
        }
        self.view.backgroundColor = ThemeDataUtil.getDrawerColor(themeData)
    }
    
    // テーマを変更
    func changeTheme(param: ThemeData) {
        self.view.backgroundColor = ThemeDataUtil.getDrawerColor(param)
        skipViewWillAppear = true
    }

    //-- TableView --/
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionItems.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionItems[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // 起動時画面選択
        let startPage:Int = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyStartPage.rawValue, defaultValue: StartPageType.Month.rawValue)

        if indexPath == NSIndexPath(forRow: 0, inSection: 0) {
            switch (startPage) {
            case StartPageType.Month.rawValue:
                appDelegate.switchCenterView(CenterViewType.CenterViewTypeCalMonth, param: nil)
                break;
            case StartPageType.Week.rawValue:
                appDelegate.switchCenterView(CenterViewType.CenterViewTypeCalWeek, param: nil)
                break;
            case StartPageType.Day.rawValue:
                appDelegate.switchCenterView(CenterViewType.CenterViewTypeCalDay, param: ["date": NSDate()])
                break;
            default:
                break;
            }
        } else if indexPath == NSIndexPath(forRow: 1, inSection: 0) {
            appDelegate.switchCenterView(CenterViewType.CenterViewTypeReminder, param: nil)
            
        } else if indexPath == NSIndexPath(forRow: 2, inSection: 0) {
            appDelegate.switchCenterView(CenterViewType.CenterViewTypeNote, param: nil)
            
        } else if indexPath == NSIndexPath(forRow: 0, inSection: 1) {
            appDelegate.switchCenterView(CenterViewType.CenterViewTypeSettingTheme, param: nil)
            
        } else if indexPath == NSIndexPath(forRow: 1, inSection: 1) {
            appDelegate.switchCenterView(CenterViewType.CenterViewTypeSettingCal, param: nil)
            
        } else if indexPath == NSIndexPath(forRow: 2, inSection: 1) {
            appDelegate.switchCenterView(CenterViewType.CenterViewTypeSettingOther, param: nil)
        }
        
        appDelegate.drawerController.toggleLeftDrawerSideAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return basicItems.count
        } else if section == 1 {
            return settingItems.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = ColorManager.getDrawerCellText()
        cell.textLabel?.font = FontManager.getDrawerCellText()
        
        if indexPath.section == 0 {
            cell.textLabel?.text = basicItems[indexPath.row]
        } else if indexPath.section == 1 {
            cell.textLabel?.text = settingItems[indexPath.row]
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}