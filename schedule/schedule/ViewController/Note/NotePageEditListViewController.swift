//
//  NotePageEditListViewController.swift
//

import UIKit

class NotePageEditListViewController: UITableViewController {
    let nsManager:NoteStoreManager = NoteStoreManager()
    var list:[NoteStore]!
    var param:NoteStore!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        list = nsManager.getList(true) as! [NoteStore]
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        cell.selectionStyle = .None
        
        let data:NoteStore = list[indexPath.row];
        cell.textLabel?.text = data.title
        if (data.note_id == param.note_id) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        param = list[indexPath.row]; // 上書き
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
