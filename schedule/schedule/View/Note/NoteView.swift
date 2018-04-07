//
//  NoteView.swift
//

import UIKit

class NoteView: UIView, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var tableViewList: UITableView!
    var width:CGFloat!
    var height:CGFloat!
    var theme:ThemeData!
    var list:[PageStore] = [PageStore]()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, theme: ThemeData, pages:[PageStore]) {
        print("---- NoteView#init() ----")
        super.init(frame:frame)
        self.theme = theme
        
        width = self.frame.size.width
        height = self.frame.size.height
        
        tableViewList = UITableView(frame: CGRectMake(0, 0, width, height))
        tableViewList.registerClass(NoteTableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewList.dataSource = self
        tableViewList.delegate = self
        tableViewList.scrollEnabled = true
        
        tableViewList.separatorInset = UIEdgeInsetsZero
        if (tableViewList.respondsToSelector("layoutMargins")) {
            tableViewList.layoutMargins = UIEdgeInsetsZero;
        }
        self.addSubview(tableViewList)

        list = pages
        
        // データがない場合には罫線を表示しない（見栄え）
        if list.count <= 0 {
            tableViewList.separatorColor = UIColor.clearColor()
        }
    }
    
    // MARK: - TableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 108
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! NoteTableViewCell
        
        cell.setTheme(theme)
        
        let page:PageStore = list[indexPath.row]
        
        cell.pageData = page
        cell.titleLabel.text = page.title
        cell.bodyLabel.text = page.body
        
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d HH:mm"
        
        // 作成日時
        let submitDate:NSDate = page.submit_date as NSDate
        let submitDateStr:String = dateFormatter.stringFromDate(submitDate)
        
        // 更新日時
        let updateDate:NSDate = page.update_date as NSDate
        let updateDateStr:String = dateFormatter.stringFromDate(updateDate)
        
        cell.submitDateLabel.text = String(format: NSLocalizedString("note_page_submitdate_format", comment: ""), submitDateStr)
        cell.updateDateLabel.text = String(format: NSLocalizedString("note_page_updatedate_format", comment: ""), updateDateStr)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameNoteDisplayForm(),
            object: nil,
            userInfo: ["page":list[indexPath.row]])
    }
}
