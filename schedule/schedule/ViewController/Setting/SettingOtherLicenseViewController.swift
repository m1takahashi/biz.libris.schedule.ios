//
//  SettingOtherLicenseViewController.swift
//  オープンソースライセンス
//

import UIKit

class SettingOtherLicenseViewController: SettingViewController, UITableViewDataSource, UITableViewDelegate {
    let titles:[String] = ["Color-Picker-for-iOS",
        "DrawerController",
        "MJPopupViewController",
        "Toast",
        "WSCoachMarksView"]
    let urls:[String] = ["http://cocoapods.org/pods/Color-Picker-for-iOS",
    "http://cocoapods.org/pods/DrawerController",
    "http://cocoapods.org/pods/MJPopupViewController",
    "http://cocoapods.org/pods/Toast",
    "https://cocoapods.org/pods/WSCoachMarksView"]

    override func viewDidLoad() {
        super.viewDidLoad()
        let tableViewDrawer: UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        tableViewDrawer.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewDrawer.dataSource = self
        tableViewDrawer.delegate = self
        self.view.addSubview(tableViewDrawer)
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app:UIApplication = UIApplication.sharedApplication()
        let url:NSURL = NSURL(string: urls[indexPath.row])!
        app.openURL(url)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        cell.textLabel?.textColor = ColorManager.getSettingCellText()
        cell.textLabel?.font = FontManager.getSettingCellText()
        cell.textLabel?.text = titles[indexPath.row]
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
