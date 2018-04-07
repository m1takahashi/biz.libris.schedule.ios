//
//  SettingOtherViewController.swift
//

import UIKit
//simport GoogleMobileAds

class SettingOtherViewController: SettingViewController, UITableViewDataSource, UITableViewDelegate {
    
    let items:[NSString] = [NSLocalizedString("setting_other_review", comment: ""),
        NSLocalizedString("setting_other_recommend", comment: ""),
        NSLocalizedString("setting_license", comment: ""),
        NSLocalizedString("setting_other_version", comment: "")]
    
    var versionString:NSString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = NSLocalizedString("setting_other", comment: "")
        super.initLeftBarButton()
        
        let tableViewDrawer: UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        tableViewDrawer.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewDrawer.dataSource = self
        tableViewDrawer.delegate = self
        self.view.addSubview(tableViewDrawer)
        
        // Version
        let infoDictionary = NSBundle.mainBundle().infoDictionary! as Dictionary
        let version = infoDictionary["CFBundleShortVersionString"]! as! String
        let build:String = infoDictionary["CFBundleVersion"]! as! String;
        versionString = NSLocalizedString("setting_other_version", comment: "") + "    " + version + " (" + build + ")"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app:UIApplication = UIApplication.sharedApplication()
        var url:NSURL!
        if (indexPath.row == 0) {
            // Review
            url = NSURL(string: Const.getAppUrl())
            app.openURL(url)
        } else if (indexPath.row == 1) {
            // Invite Friend
            var mail:String = Const.getInviteMail()
            mail = mail.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
            url = NSURL(string: mail)
            app.openURL(url)
        } else if (indexPath.row == 2) {
            // Open Source License
            self.navigationController?.pushViewController(SettingOtherLicenseViewController(), animated: true)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = ColorManager.getSettingCellText()
        cell.textLabel?.font = FontManager.getSettingCellText()
        if (indexPath.row == 3) {
            cell.textLabel?.text = versionString as String
        } else {
            cell.textLabel?.text = "\(items[indexPath.row])"
            cell.accessoryType = .DisclosureIndicator
        }
        return cell
    }
}
