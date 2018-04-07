//
//  NoteListViewController.swift
//

import UIKit

class NoteMainViewController: NoteViewController, UIScrollViewDelegate, WSCoachMarksViewDelegate {
    var statusBarHeight:CGFloat!
    var navBarHeight:CGFloat    = 44
    var tabBarHeight:CGFloat    = 44
    
    // Nav
    var customNavBar:CustomNavigationBar!
    var btnAdd:UIButton!
    var imageViewMenu:UIImageView!
    // Contents
    var contentsWidth:CGFloat!
    var contentsHeight:CGFloat!
    var pagingScrollView:UIScrollView!
    // ToolBar
    var imageViewList:UIImageView!
    var imageViewSort:UIImageView!
    var labelSort:UILabel!
    
    var skipViewWillAppear:Bool = false
    
    var currentPage:Int = 0
    var pages:Int = 0
    var contentViews = [NoteView]()

    var nsManager:NoteStoreManager = NoteStoreManager()
    var psManager:PageStoreManager = PageStoreManager()
    
    var list:[NoteStore]!
    var sortOrder:Int = NoteSortOrder.TitleASC.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        
        initCustomNavigationBar()
        initCustomTabBar()
        initNotification()
        
        customNavBar.setTitleText(NSLocalizedString("note", comment: ""))
        
        contentsWidth   = self.view.frame.width
        contentsHeight  = self.view.frame.height - (statusBarHeight + navBarHeight + tabBarHeight)
        
        pagingScrollView = UIScrollView(frame: CGRectMake(0, statusBarHeight + navBarHeight, contentsWidth, contentsHeight))
        pagingScrollView.pagingEnabled = true
        pagingScrollView.bounces = false
        pagingScrollView.contentOffset = CGPointMake(0, 0)
        pagingScrollView.delegate = self
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(pagingScrollView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("--- NoteMainViewController#viewWillAppear() ---")
        
        if skipViewWillAppear {
            skipViewWillAppear = false
            return
        }
        
        // ソート条件
        sortOrder = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyNoteSortOrder.rawValue, defaultValue: NoteSortOrder.TitleASC.rawValue)
        
        // Theme
        customNavBar.setBgColor(ThemeDataUtil.getNavigationColor(theme))
        customNavBar.setTitleColor(UIColor(hexString: theme.navText, alpha: 1.0))
        self.setNavTintColor(UIColor(hexString: theme.navText, alpha: 1.0))
        imageViewList.tintColor = UIColor(hexString: theme.tabSegctr, alpha: 1.0)
        imageViewSort.tintColor = UIColor(hexString: theme.tabSegctr, alpha: 1.0)
        labelSort.textColor     = UIColor(hexString: theme.tabSegctr, alpha: 1.0)
        
        loadNotes(sortOrder)
        movePage(0) // 先頭ページ
        
        showCoachMarks()
    }

    override func viewWillDisappear(animated: Bool) {
        // ソート条件保存
        UDWrapper.setInt(UDWrapperKey.UDWrapperKeyNoteSortOrder.rawValue, value: sortOrder)
        super.viewWillDisappear(animated)
    }
    
    
    func loadNotes(order:Int) {
//        currentPage = 0 // 0から配列の添え字
        
        // Cleanup
        contentViews = [] // 初期化
        let subViews:[UIView] = pagingScrollView.subviews 
        for view in subViews {
            view.removeFromSuperview()
        }
        // ノート一覧取得
        list = nsManager.getList(true) as! [NoteStore]

        pages = list.count
        pagingScrollView.contentSize = CGSizeMake(contentsWidth * CGFloat(pages), contentsHeight)
        for (i, note) in list.enumerate() {
            let pageData:[PageStore] = psManager.getListByNoteId(note.note_id, order: order) as! [PageStore]
            
            let frame:CGRect = CGRectMake(contentsWidth * CGFloat(i), 0, contentsWidth, contentsHeight)
            let view = NoteView(frame: frame, theme: theme, pages: pageData)
            contentViews.append(view)
            pagingScrollView.addSubview(contentViews[i])
        }
        
        if pages > 0 {
            customNavBar.setTitleText(list[currentPage].title!)
        }
        
        // メニューボタン＆ラベル更新
        var imageSortASC:UIImage = UIImage(named: "Icon_Sort_ASC")!
        var imageSortDESC:UIImage = UIImage(named: "Icon_Sort_DESC")!
        imageSortASC = imageSortASC.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageSortDESC = imageSortDESC.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)

        switch (order) {
        case NoteSortOrder.TitleASC.rawValue:
            labelSort.text = NSLocalizedString("note_sort_title", comment: "")
            imageViewSort.image = imageSortASC
            break;
        case NoteSortOrder.SubmitDateDESC.rawValue:
            labelSort.text = NSLocalizedString("note_sort_submit", comment: "")
            imageViewSort.image = imageSortDESC
            break
        case NoteSortOrder.SubmitDateASC.rawValue:
            labelSort.text = NSLocalizedString("note_sort_submit", comment: "")
            imageViewSort.image = imageSortASC
            break
        case NoteSortOrder.UpdateDateDESC.rawValue:
            labelSort.text = NSLocalizedString("note_sort_update", comment: "")
            imageViewSort.image = imageSortDESC
            break
        case NoteSortOrder.UpdateDateASC.rawValue:
            labelSort.text = NSLocalizedString("note_sort_update", comment: "")
            imageViewSort.image = imageSortASC
            break
        default:
            break
        }
    }
    
    private func setNavTintColor(color:UIColor) {
        imageViewMenu.tintColor = color
        btnAdd.tintColor = color
    }
    
    // カスタムナビゲーションバー
    func initCustomNavigationBar() {
        let posY:CGFloat = UIApplication.sharedApplication().statusBarFrame.height
        customNavBar = CustomNavigationBar(frame: CGRectMake(0.0, posY, self.view.frame.size.width, CustomNavigationBar.defaultHeight))
        self.view.addSubview(customNavBar)
        
        // 右ボタン（共通で予定追加）
        let btnWidth:CGFloat    = 44.0
        let btnHeight:CGFloat   = 44.0
        let marginRight:CGFloat = 18.0
        let marginLeft:CGFloat  = 18.0
        
        let btnAddPosX:CGFloat = self.view.frame.size.width - (marginRight + btnWidth)
        
        var imageAdd:UIImage = UIImage(named: "Icon_Add")!
        imageAdd = imageAdd.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        btnAdd = UIButton(frame: CGRectMake(btnAddPosX, 0.0, btnWidth, btnHeight))
        btnAdd.setImage(imageAdd, forState: .Normal)
        btnAdd.addTarget(self, action: "onAddButton:", forControlEvents: UIControlEvents.TouchUpInside)
        customNavBar.addSubview(btnAdd)
        
        // 左ボタン（共通でメニュー開閉）UIViewの下に
        var imageMenu:UIImage = UIImage(named: "Icon_Menu")!
        imageMenu = imageMenu.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageViewMenu = UIImageView(image: imageMenu)
        imageViewMenu.frame = CGRectMake(marginLeft, 0.0, btnWidth, btnHeight)
        imageViewMenu.userInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "toggleMenu")
        imageViewMenu.addGestureRecognizer(tap)
        customNavBar.addSubview(imageViewMenu)
    }

    //-- TabBar --//
    func initCustomTabBar() {
        let width:CGFloat   = self.view.frame.size.width
        let height:CGFloat  = 44.0
        let x:CGFloat       = 0.0
        let y:CGFloat       = self.view.frame.size.height - height
        
        let iconNum:Int         = 2
        let iconWidth:CGFloat   = 44.0
        let iconHeight:CGFloat  = 44.0
        
        let container:UIView = UIView(frame: CGRectMake(x, y, width, height))
        container.backgroundColor = UIColor(patternImage: UIImage(named: "Border_Tab")!)
        
        let margin = (width - (iconWidth * CGFloat(iconNum))) / (CGFloat(iconNum) + 1)
        let posY:CGFloat = (height - iconHeight) / 2
        var posX = margin
        
        var imageList:UIImage = UIImage(named: "Icon_Numbered_List")!
        imageList = imageList.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageViewList = UIImageView(image: imageList)
        imageViewList.frame = CGRectMake(posX, posY, iconWidth, iconHeight)
        imageViewList.userInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onListButton")
        imageViewList.addGestureRecognizer(tap)
        container.addSubview(imageViewList)
        
        posX = posX + iconWidth + margin
        var imageSort:UIImage = UIImage(named: "Icon_Sort_ASC")!
        imageSort = imageSort.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageViewSort = UIImageView(image: imageSort)
        imageViewSort.frame = CGRectMake(posX, posY, iconWidth, iconHeight)
        imageViewSort.userInteractionEnabled = true
        let tapSort:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onSortButton")
        imageViewSort.addGestureRecognizer(tapSort)
        container.addSubview(imageViewSort)
        
        // ソート項目
        posX = posX + iconWidth
        labelSort = UILabel(frame: CGRectMake(posX, posY, 60, height))
        labelSort.text = NSLocalizedString("note_sort_title", comment: "")
        labelSort.font = UIFont.systemFontOfSize(12)
        labelSort.userInteractionEnabled = true
        labelSort.addGestureRecognizer(tapSort) // アイコンをタップした時同様アクションが起動する
        container.addSubview(labelSort)
        
        self.view.addSubview(container)
    }
    
    // MARK: - Scroll
    func scrollViewDidScroll(scrollView:UIScrollView) {
        if ((scrollView.contentOffset.x / self.view.frame.size.width) % 1 == 0) {
            let page:Int = (Int)(scrollView.contentOffset.x / self.view.frame.size.width)
            currentPage = page
            customNavBar.setTitleText(list[currentPage].title!)
        }
    }
    
    // 指定のページに移動させる
    func movePage(page:Int) {
        currentPage = page
        
        // 初回起動時にはリストがない場合もある
        if list.count > 0 {
            customNavBar.setTitleText(list[currentPage].title!)
        }
        
        let x:CGFloat = self.view.frame.size.width * CGFloat(page)
        pagingScrollView.setContentOffset(CGPointMake(x, 0), animated: false)
    }

    
    // MARK: - Action
    func onAddButton(sender: UIButton) {
        // ノートの存在確認
        if list.count <= 0 {
            self.view.makeToast(NSLocalizedString("msg_note_list_create", comment: ""),
                duration: (NSTimeInterval)(3.0),
                position: CSToastPositionCenter)
            return
        }
        
        skipViewWillAppear = true
        
        let editViewController = NotePageEditViewController()
        editViewController.paramNoteId = list[currentPage].note_id // ノート情報を渡す
        self.presentViewController(UINavigationController(rootViewController: editViewController),
            animated: true,
            completion: nil)
    }
    
    func toggleMenu() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.drawerController.toggleLeftDrawerSideAnimated(true, completion: nil)
    }
    
    func onListButton() {
        self.presentViewController(UINavigationController(rootViewController: NoteListViewController()),
            animated: true,
            completion: nil)
    }
    
    func onSortButton() {
        let actionSheetController: UIAlertController = UIAlertController(title: "",
            message: "",
            preferredStyle: .ActionSheet)

        let titleASCAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("note_sort_title_asc", comment: ""), style: .Default) {
            action -> Void in
            self.sortOrder = NoteSortOrder.TitleASC.rawValue
            self.loadNotes(self.sortOrder)
            NSLog("CurrentPage = \(self.currentPage)")
            self.movePage(self.currentPage)
        }
        let submitDESCAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("note_sort_submit_desc", comment: ""), style: .Default) {
            action -> Void in
            self.sortOrder = NoteSortOrder.SubmitDateDESC.rawValue
            self.loadNotes(self.sortOrder)
            self.movePage(self.currentPage)
        }
        let submitASCAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("note_sort_submit_asc", comment: ""), style: .Default) {
            action -> Void in
            self.sortOrder = NoteSortOrder.SubmitDateASC.rawValue
            self.loadNotes(self.sortOrder)
            self.movePage(self.currentPage)
        }
        let updateDESCAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("note_sort_update_desc", comment: ""), style: .Default) {
            action -> Void in
            self.sortOrder = NoteSortOrder.UpdateDateDESC.rawValue
            self.loadNotes(self.sortOrder)
            self.movePage(self.currentPage)
        }
        let updateASCAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("note_sort_update_asc", comment: ""), style: .Default) {
            action -> Void in
            self.sortOrder = NoteSortOrder.UpdateDateASC.rawValue
            self.loadNotes(self.sortOrder)
            self.movePage(self.currentPage)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("note_basic_cancel", comment: ""), style: .Cancel) {
            action -> Void in
        }
        actionSheetController.addAction(titleASCAction)
        actionSheetController.addAction(submitDESCAction)
        actionSheetController.addAction(submitASCAction)
        actionSheetController.addAction(updateDESCAction)
        actionSheetController.addAction(updateASCAction)
        actionSheetController.addAction(cancelAction)
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }

    // MARK: - Notification
    func initNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "receiveDisplayForm:",
            name: Const.getNotificationNameNoteDisplayForm(),
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "receiveShare:",
            name: Const.getNotificationNameNoteShare(),
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "receiveBackForm:",
            name: Const.getNotificationNameNoteBackForm(),
            object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: Const.getNotificationNameNoteDisplayForm(),
            object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: Const.getNotificationNameNoteShare(),
            object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: Const.getNotificationNameNoteBackForm(),
            object: nil)
    }
    
    // NoteViewからのページ"編集"フォーム表示
    func receiveDisplayForm(notification: NSNotification?) {
        if let userInfo = notification?.userInfo {
            skipViewWillAppear = true
            let page = userInfo["page"]! as! PageStore
            let editViewController = NotePageEditViewController()
            editViewController.param = page
            self.presentViewController(UINavigationController(rootViewController: editViewController),
                animated: true,
                completion: nil)
        }
    }
    
    // ページ追加・編集後に指定のノートへ遷移する
    func receiveBackForm(notification: NSNotification?){
        NSLog("NoteMainViewController#receiveBackForm()")
        if let userInfo = notification?.userInfo {
            let noteId = userInfo["note_id"]! as! Int
            NSLog("NoteID = \(noteId)")
            
            var page:Int = 0
            for (index, note) in list.enumerate() {
                if note.note_id == noteId {
                    page = index
                    break;
                }
            }
            NSLog("Page = \(page)")
            
            loadNotes(sortOrder) // 再読込
            movePage(page)
        }
    }
    
    // 共有メニュー表示
    func receiveShare(notification: NSNotification?){
        if let userInfo = notification?.userInfo {
            let page = userInfo["page"]! as! PageStore
            
            let title:String = page.title
            let body:String = page.body
            
            let activityViewController = UIActivityViewController(activityItems: [title, body], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:Array?, error:NSError?) in
                if (completed) {
                    // Noting to do
                }
            }
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    //-- Coach Marks (Tutorial) --//
    func showCoachMarks() {
        let isCoachMarks = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyCoachMarksNote.rawValue, defaultValue: false)
        if !isCoachMarks {
            let width:CGFloat   = self.view.frame.size.width
            let height:CGFloat  = self.view.frame.size.height
            
            let iconSize:CGFloat    = 44.0
            let navMargin:CGFloat   = 18.0
            let sortLabel:CGFloat   = 60
            let iconNum:Int         = 2
            
            let margin = (width - (iconSize * CGFloat(iconNum))) / (CGFloat(iconNum) + 1)
            var posX = margin
            var posY:CGFloat = height - tabBarHeight
            
            // ノート一覧（左下）
            let value1:NSValue = NSValue(CGRect: CGRectMake(posX, posY, iconSize, iconSize))
            
            // ページ追加（右上）
            posX = width - (iconSize + navMargin)
            posY = statusBarHeight
            let value2:NSValue = NSValue(CGRect: CGRectMake(posX, posY, iconSize, iconSize))
            
            // ページ並び替え（右下）
            posX = iconSize + (margin * 2)
            posY = height - tabBarHeight
            let value3:NSValue = NSValue(CGRect: CGRectMake(posX, posY, iconSize + sortLabel, iconSize))
            
            let coachMarks = [
                ["rect": value1, "caption": NSLocalizedString("caption_note_1", comment: "")],
                ["rect": value2, "caption": NSLocalizedString("caption_note_2", comment: "")],
                ["rect": value3, "caption": NSLocalizedString("caption_note_3", comment: "")],
            ]

            let coachMarksView:WSCoachMarksView = WSCoachMarksView(frame: self.view.bounds, coachMarks: coachMarks)
            coachMarksView.delegate = self
            self.view.addSubview(coachMarksView)
            coachMarksView.start()
            
            UDWrapper.setBool(UDWrapperKey.UDWrapperKeyCoachMarksNote.rawValue, value: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
