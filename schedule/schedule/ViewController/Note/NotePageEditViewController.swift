//
//  NotePageEditViewController.swift
//  http://furodrive.com/2015/02/how_to_set_placeholder_on_uitextview/
//

import UIKit

class NotePageEditViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    var editListViewController:NotePageEditListViewController = NotePageEditListViewController()
    
    var titleField:UITextField!
    var bodyView:UITextView!
    var submitDateStr:String!
    var updateDateStr:String!
    
    var heights:[[CGFloat]] = [[44, 220, 44, 44], [44]]
    let heightsForAdd:[[CGFloat]] = [[44, 220, 44]]
    
    let nsManager:NoteStoreManager = NoteStoreManager()
    var psManager:PageStoreManager = PageStoreManager()
    
    var param:PageStore?
    var paramNoteId:NSNumber!
    
    var note:NoteStore!
    var originalNoteId:NSNumber! // 削除時のために変更されていないNoteIDを保持しておく
    
    var skipViewWillAppear:Bool = false
    
    let titleMinLength:Int = 1
    let titleMaxLength:Int = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.tableView.frame, style: .Grouped)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        self.navigationItem.title = NSLocalizedString("note_page", comment: "")
        
        let leftButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel,
            target:self,
            action: "onCancelButton:")
        self.navigationItem.leftBarButtonItem = leftButton
        
        let rightButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done,
            target:self,
            action: "onSaveButton:")
        self.navigationItem.rightBarButtonItem = rightButton
        
        // Title
        let margin:CGFloat  = 15
        let x:CGFloat       = margin
        let y:CGFloat       = 0
        let width:CGFloat   = self.view.frame.size.width - (margin * 2)
        var height:CGFloat  = 44
        
        titleField = UITextField(frame: CGRectMake(x, y, width, height))
        titleField.placeholder = NSLocalizedString("note_page_placeholder_title", comment: "")
        titleField.returnKeyType = .Done;
        
        // Body
        height = heights[0][1]
        bodyView = UITextView(frame: CGRectMake(margin, 0, width, height))
        bodyView.font = UIFont.systemFontOfSize(CGFloat(16))
        bodyView.textColor = UIColor.darkGrayColor()
        bodyView.textAlignment = .Left
        bodyView.editable = true
        bodyView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("--- NotePageEditViewController#viewWillAppear() ---")

        if skipViewWillAppear {
            note = editListViewController.param
            skipViewWillAppear = false
            self.tableView.reloadData()
            return
        }
        
        if (param == nil) {
            heights = heightsForAdd
            // TextView Placeholder
            bodyView.text = NSLocalizedString("note_page_placeholder_body", comment: "")
            bodyView.textColor = UIColor.lightGrayColor()
            // Note Data
            note = nsManager.getByNoteId(paramNoteId)
            
        } else {
            titleField.text = param?.title
            bodyView.text   = param?.body

            note = nsManager.getByNoteId(param!.note_id)
            
            let submitDate:NSDate = param!.submit_date as NSDate
            let updateDate:NSDate = param!.update_date as NSDate
            
            let dateFormatter:NSDateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle;
            dateFormatter.timeStyle = .ShortStyle;
            
            submitDateStr = NSString(format: NSLocalizedString("note_page_submitdate_format", comment: ""), dateFormatter.stringFromDate(submitDate)) as String
            updateDateStr = NSString(format: NSLocalizedString("note_page_updatedate_format", comment: ""), dateFormatter.stringFromDate(updateDate)) as String
        }
        
        originalNoteId = note.note_id
    }
    
    // MARK: - TextView Placeholder
    func textViewDidBeginEditing(textView: UITextView) {
        // textColorがlightGrayだと、textViewに入っている文字を消去する。
        if textView.textColor == UIColor.lightGrayColor(){
            textView.text = nil
            textView.textColor = UIColor.darkGrayColor()
        }
    }
    
    // MARK: - Action
    func onSaveButton(sender: UIBarButtonItem) {
        if !save() {
            return
        }
        titleField.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onCancelButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // 保存処理
    func save() -> Bool {
        let title:String    = titleField.text!
        var body:String     = bodyView.text
        let noteId:NSNumber = note.note_id
        
        
        // 入力チェック（タイトルのみ、本文は空欄でもよい）
        if !TextValidation.length(title, min: titleMinLength, max: titleMaxLength) {
            self.view.makeToast(NSLocalizedString("msg_note_page_title_length", comment: ""),
                duration: (NSTimeInterval)(2.0),
                position: CSToastPositionCenter)
            return false
        }
        
        if (param == nil) {
            // 追加
            // プレイスフォルダー文字（本文）であれば除去する
            if body == NSLocalizedString("note_page_placeholder_body", comment: "") {
                NSLog("PlaceHolderと同じ文字なので除去しました : \(body)")
                body = ""
            }
            
            psManager.add(title, body: body, noteId: noteId)
        } else {
            // 編集
            param?.title        = title
            param?.body         = body
            param?.note_id      = noteId
            param?.update_date  = NSDate()
            if let item = param {
                do {
                    try item.managedObjectContext!.save()
                } catch _ {
                };
            }
        }
        
        // 指定のノートへ遷移
        NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameNoteBackForm(),
            object: nil,
            userInfo: ["note_id":noteId])
        
        return true
    }
    
    // MARK: - TableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return heights.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heights[section].count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return heights[indexPath.section][indexPath.row]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.contentView.addSubview(titleField)
            } else if indexPath.row == 1 {
                cell.contentView.addSubview(bodyView)
            } else if indexPath.row == 2 {
                cell.textLabel?.text = note.title
                cell.accessoryType = .DisclosureIndicator
            } else if indexPath.row == 3 {
                cell.textLabel?.text = submitDateStr + "\n" + updateDateStr
                cell.textLabel?.numberOfLines = 2
                cell.textLabel?.textAlignment = .Center
                cell.textLabel?.textColor = UIColor.grayColor()
            }
            break;
        case 1:
            cell.textLabel?.text = NSLocalizedString("note_page_delete", comment: "")
            cell.textLabel?.textColor = UIColor.redColor()
            cell.textLabel?.textAlignment = .Center
            break;
        default:
            break;
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if NSIndexPath(forRow: 2, inSection: 0) == indexPath {
            // ノート変更
            skipViewWillAppear = true
            editListViewController.param = note
            self.navigationController?.pushViewController(editListViewController, animated: true)
        } else if NSIndexPath(forRow: 0, inSection: 1) == indexPath {
            // 削除
            psManager.delete(param!)
            
            // 指定のノートへ遷移
            NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameNoteBackForm(),
                object: nil,
                userInfo: ["note_id":originalNoteId])
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
