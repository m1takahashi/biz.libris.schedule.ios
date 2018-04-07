//
//  NoteListEditViewController.swift
//

import UIKit

class NoteListEditViewController: UITableViewController, UITextFieldDelegate {
    var textField:UITextField!

    let minLength:Int = 1
    let maxLength:Int = 30
    
    var nsManager:NoteStoreManager!
    var param:NoteStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.tableView.frame, style: .Grouped)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        self.navigationItem.title = NSLocalizedString("note_list_add", comment: "")

        let rightButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done,
            target:self,
            action: "onSaveButton:")
        self.navigationItem.rightBarButtonItem = rightButton

        let margin:CGFloat  = 15
        let x:CGFloat       = margin
        let y:CGFloat       = 0
        let width:CGFloat   = self.view.frame.size.width - (margin * 2)
        let height:CGFloat  = 44

        textField = UITextField(frame: CGRectMake(x, y, width, height))
        textField.placeholder = NSLocalizedString("note_list_placeholder", comment: "")
        textField.returnKeyType = .Done;
        textField.delegate = self
        
        nsManager = NoteStoreManager()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (param != nil) {
            textField.text = param?.title;
        }
    }
    
    func onSaveButton(sender: UIBarButtonItem) {
        if !save() {
            return
        }
        textField.resignFirstResponder()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //-- TextFeild Delegate --//
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if !save() {
            return false
        }
        textField.resignFirstResponder()
        self.navigationController?.popViewControllerAnimated(true)
        return true
    }
    
    // 保存処理
    func save() -> Bool {
        let title:String = textField.text!
        
        // 入力チェック
        if !TextValidation.length(title, min: minLength, max: maxLength) {
            self.view.makeToast(NSLocalizedString("msg_note_length", comment: ""),
                duration: (NSTimeInterval)(2.0),
                position: CSToastPositionCenter)
            return false
        }
        
        if (param == nil) {
            print("---- save() : Add ----")
            nsManager.add(title)
        } else {
            // 編集
            print("---- save() : Edit ----")
            param?.title = title
            if let item = param {
                try! item.managedObjectContext!.save();
            }
        }
        return true
    }
    
    // MARK: - Table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        cell.addSubview(textField)
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
