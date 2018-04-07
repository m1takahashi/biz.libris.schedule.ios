//
//  SettingCalScrollViewController.swift
//

import UIKit

class SettingCalScrollViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableViewList:UITableView!
    var scrollDirection:Int = ScrollDirection.Vertical.rawValue
    let list:[NSString] = [NSLocalizedString("scroll_direction_vertical", comment: ""),
        NSLocalizedString("scroll_direction_horizontal", comment: "")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = NSLocalizedString("setting_cal_scroll", comment: "")
        
        tableViewList = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        tableViewList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewList.dataSource = self
        tableViewList.delegate = self
        tableViewList.allowsMultipleSelection = false
        self.view.addSubview(tableViewList)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        scrollDirection = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyScrollDirection.rawValue, defaultValue: ScrollDirection.Vertical.rawValue)
    }
    
    override func viewWillDisappear(animated: Bool) {
        UDWrapper.setInt(UDWrapperKey.UDWrapperKeyScrollDirection.rawValue, value: scrollDirection)
        super.viewWillDisappear(animated)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        scrollDirection = indexPath.row
        tableViewList.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        cell.backgroundColor = UIColor.clearColor()
        if (indexPath.row == scrollDirection) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel?.text = list[indexPath.row] as String
        cell.textLabel?.textColor = ColorManager.getSettingCellText()
        cell.textLabel?.font = FontManager.getSettingCellText()
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
