//
//  NoteListViewController.swift
//

import UIKit

class NoteListViewController: NoteViewController, UITableViewDelegate, UITableViewDataSource {
    var tableViewList: UITableView!
    let tabBarHeight:CGFloat = 44.0
    
    var nsManager:NoteStoreManager = NoteStoreManager()
    var psManager:PageStoreManager = PageStoreManager()

    var list:[NoteStore]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = NSLocalizedString("note_list", comment: "")
        let leftButton = UIBarButtonItem(title: NSLocalizedString("note_list_close", comment: ""),
            style: .Plain,
            target: self,
            action: "onCloseButton:")
        self.navigationItem.leftBarButtonItem = leftButton
        
        let rightButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit,
            target: self,
            action: "onEditButton:")
        self.navigationItem.rightBarButtonItem = rightButton
        
        tableViewList = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - tabBarHeight))
        tableViewList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableViewList.backgroundColor = UIColor.clearColor()
        tableViewList.dataSource = self
        tableViewList.delegate = self
        tableViewList.scrollEnabled = true
        self.view.addSubview(tableViewList)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initTabBar()    // TODO: 重複しないか？

        // 並び順リセット
        // ここで振りなおしておくと、連続して追加した場合でも順番が崩れることがない
        nsManager.resetSeq()
        list = nsManager.getList(true) as! [NoteStore]
        
        tableViewList.reloadData()
    }
    
    //-- TabBar --//
    func initTabBar() {
        let tabBarView:UIView = UIView(frame: CGRectMake(0, self.view.frame.size.height - tabBarHeight, self.view.frame.size.width, tabBarHeight))
        let image:UIImage = UIImage(named: "Border_Tab")!
        tabBarView.backgroundColor = UIColor(patternImage: image)
        self.view.addSubview(tabBarView)
        
        let buttonAdd:UIButton = UIButton(frame: CGRectMake(0, 0, tabBarView.bounds.size.width, tabBarView.bounds.size.height))
        buttonAdd.setTitle(NSLocalizedString("note_list_add", comment: ""), forState: .Normal)
        buttonAdd.setTitleColor(UIColor(hexString: theme.tabSegctr, alpha: 1.0), forState: .Normal)
        buttonAdd.addTarget(self,
            action: "onAddButton:",
            forControlEvents:.TouchUpInside)
        tabBarView.addSubview(buttonAdd)
    }
    
    // MARK: - Action
    func onCloseButton(sender: UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onAddButton(sender: UIButton) {
        self.navigationController?.pushViewController(NoteListEditViewController(), animated: true)
    }
    
    func onEditButton(sender: UIBarButtonItem) {
        if tableViewList.editing {
            tableViewList.setEditing(false, animated: true)
            // 並び順保存
            for (index, note) in list.enumerate() {
                print("Title : \(note.title),  Index : \(index)")
                note.seq = index
                do {
                    try note.managedObjectContext!.save()
                } catch _ {
                };
            }
        } else {
            tableViewList.setEditing(true, animated: true)
            // TODO: ノートは最低一つ必要？
        }
    }
    
    // MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    // 移動可
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let view = NoteListEditViewController()
        view.param = list[indexPath.row]
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        let data:NoteStore = list[indexPath.row]
        cell.textLabel!.text = data.title
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            if list.count <= 1 {
                self.view.makeToast(NSLocalizedString("msg_note_list_more_one", comment: ""),
                    duration: (NSTimeInterval)(2.0),
                    position: CSToastPositionCenter)
                return
            }
            
            let note:NoteStore = list[indexPath.row] as NoteStore
            // ページを削除
            psManager.deleteByNoteId(note.note_id)
            // ノート削除
            nsManager.delete(note)
            
            list.removeAtIndex(indexPath.row)
            
            tableViewList.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
        default:
            return
        }
    }
    
    // 並び替え
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        print("Source : \(sourceIndexPath.row), Dist : \(destinationIndexPath.row)")

        var swap1:NoteStore!
        var swap2:NoteStore!
        
        if sourceIndexPath.row > destinationIndexPath.row {
            // 上へ
            for (var i = 0; i <= list.count; i++) {
                if (i < destinationIndexPath.row) {
                    // なにもしない
                } else if (i == destinationIndexPath.row) {
                    swap1 = list[i]
                    list[i] = list[sourceIndexPath.row]
                } else if (i == sourceIndexPath.row) {
                    list[i] = swap1
                    break;
                } else if (i == list.count) {
                    list[i - 1] = swap1
                } else {
                    swap2 = list[i]
                    list[i] = swap1
                    swap1 = swap2
                }
            }
            
        } else if sourceIndexPath.row < destinationIndexPath.row {
            // 下へ移動
            for (var i = list.count; i >= 0; i--) {
                if (i > destinationIndexPath.row) {
                    // なしもしない
                } else if (i == destinationIndexPath.row) {
                    swap1 = list[i]
                    list[i] = list[sourceIndexPath.row]
                } else if (i == sourceIndexPath.row) {
                    list[i] = swap1
                    break;
                } else if (i <= 0) {
                    list[0] = swap1
                } else {
                    swap2 = list[i]
                    list[i] = swap1
                    swap1 = swap2
                }
            }
        }
        tableViewList.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
