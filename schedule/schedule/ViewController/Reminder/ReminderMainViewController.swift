//
//  ReminderMainViewController.swift
//

import UIKit
import EventKit
import EventKitUI

class ReminderMainViewController: ReminderViewController, WSCoachMarksViewDelegate {
    var statusBarHeight:CGFloat!
    var navBarHeight:CGFloat    = 44.0
    var tabBarHeight:CGFloat    = 44.0
    
    var contentsWidth:CGFloat!
    var contentsHeight:CGFloat!
    
    var pagingScrollView:UIScrollView!
    var customNavBar:CustomNavigationBar!
    var imageViewCheckmark:UIImageView!
    
    var adContainer:UIView!
    
    var btnAdd:UIButton!
    var imageViewMenu:UIImageView!
    var imageViewList:UIImageView!
    
    var skipViewWillAppear:Bool = false
    var displayCompleted:Bool   = true
    
    var currentPage:Int = 0
    var pages:Int = 0
    var contentViews = [ReminderView]()
    var items = [[EKReminder]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ReminderViewの詳細ボタンを押した時に、編集フォームを表示する
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "receiveDisplayForm:",
            name: Const.getNotificationNameReminderDisplayForm(),
            object: nil)
        
        // 編集フォームから戻った時にデータを再読み込みして、任意のページへ遷移する
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "receiveBackForm:",
            name: Const.getNotificationNameReminderBackForm(),
            object: nil)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        
        initCustomNavigationBar()
        initCustomTabBar()
        customNavBar.setTitleText(NSLocalizedString("reminder", comment: ""))
        
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
        print("--- ReminderMainViewController#viewWillAppear() ---")
        
        if skipViewWillAppear {
            skipViewWillAppear = false
            return
        }
        
        // Theme
        customNavBar.setBgColor(ThemeDataUtil.getNavigationColor(theme))
        customNavBar.setTitleColor(UIColor(hexString: theme.navText, alpha: 1.0))
        self.setNavTintColor(UIColor(hexString: theme.navText, alpha: 1.0))
        imageViewCheckmark.tintColor = UIColor(hexString: theme.tabSegctr, alpha: 1.0)
        imageViewList.tintColor = UIColor(hexString: theme.tabSegctr, alpha: 1.0)

        loadCalendars()
        loadAllData()
        movePage(0) // 表示ページリセット

        // 完了済み表示・非表示設定
        displayCompleted = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyReminderDisplayCompleted.rawValue,
            defaultValue: true)

        showCoachMarks()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
   
    func loadCalendars() {
        currentPage = 0 // 0から配列の添え字
        
        // Cleanup
        contentViews = [] // 初期化
        let subViews:[UIView] = pagingScrollView.subviews 
        for view in subViews {
            view.removeFromSuperview()
        }
        
        pages = calendars.count
        pagingScrollView.contentSize = CGSizeMake(contentsWidth * CGFloat(pages), contentsHeight)
        for (i, calendar) in calendars.enumerate() {
            let view = ReminderView(frame: CGRectMake(contentsWidth * CGFloat(i), 0, contentsWidth, contentsHeight),
                theme: theme,
                eventStore: eventStore,
                calendar: calendar)
            
            contentViews.append(view)
            pagingScrollView.addSubview(contentViews[i])
        }
        
        if pages > 0 {
            customNavBar.setTitleText(calendars[currentPage].title)
        }
    }
    
    // 一括取得（非同期）
    func loadAllData() {
        items = []
        let predicate:NSPredicate = eventStore.predicateForRemindersInCalendars(calendars)
        eventStore.fetchRemindersMatchingPredicate(predicate, completion: {(reminders: [EKReminder]?) -> Void in
            for (_, calendar) in self.calendars.enumerate() {
                var list = [EKReminder]()
                for reminder in reminders! {
                    if (calendar.calendarIdentifier == reminder.calendar.calendarIdentifier) {
                        list.append(reminder)
                    }
                }
                self.items.append(list)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // アイテムデータセット
                for (i, view) in self.contentViews.enumerate() {
                    view.setReminder(self.items[i])
                }
                
                // 完了済み表示・非表示設定適用
                // 起動直後など、データのセットが終わる前に、設定しても意味がない
                self.setCheckmark(self.displayCompleted)
            })
        })
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
    
    //-- Scroll --//
    func scrollViewDidScroll(scrollView:UIScrollView) {
        if ((scrollView.contentOffset.x / self.view.frame.size.width) % 1 == 0) {
            let page:Int = (Int)(scrollView.contentOffset.x / self.view.frame.size.width)
            currentPage = page
            customNavBar.setTitleText(calendars[currentPage].title)
        }
    }
    
    // 指定のページに移動させる
    func movePage(page:Int) {
        let x:CGFloat = self.view.frame.size.width * CGFloat(page)
        pagingScrollView.setContentOffset(CGPointMake(x, 0), animated: false)
    }
    
    //-- Action --//
    func onAddButton(sender: UIButton) {
        // 未許可 -> 操作不可
        if !getAuthorization_status() {
            self.view.makeToast(NSLocalizedString("msg_reminder_privacy", comment: ""),
                duration: (NSTimeInterval)(2.0),
                position: CSToastPositionCenter)
            return
        }
        // リスト確認
        if calendars.count <= 0 {
            self.view.makeToast(NSLocalizedString("msg_reminder_list_create", comment: ""),
                duration: (NSTimeInterval)(3.0),
                position: CSToastPositionCenter)
            return
        }
        skipViewWillAppear = true
        let editViewController = ReminderEditViewController()
        editViewController.calendar = calendars[currentPage]
        self.presentViewController(UINavigationController(rootViewController: editViewController),
            animated: true,
            completion: nil)
    }
    
    func toggleMenu() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.drawerController.toggleLeftDrawerSideAnimated(true, completion: nil)
    }
    
    func onCheckmarkButton() {
        // 未許可 -> 操作不可
        if !getAuthorization_status() {
            self.view.makeToast(NSLocalizedString("msg_reminder_privacy", comment: ""),
                duration: (NSTimeInterval)(2.0),
                position: CSToastPositionCenter)
            return
        }
        // リスト確認
        if calendars.count <= 0 {
            print("操作が無効です。（リストがありません）")
            return
        }
        
        if displayCompleted {
            displayCompleted = false
        } else {
            displayCompleted = true
        }
        setCheckmark(displayCompleted)
    }
    
    func onListButton() {
        // 未許可 -> 操作不可
        if !getAuthorization_status() {
            self.view.makeToast(NSLocalizedString("msg_reminder_privacy", comment: ""),
                duration: (NSTimeInterval)(2.0),
                position: CSToastPositionCenter)
            return
        }
        self.presentViewController(UINavigationController(rootViewController: ReminderListViewController()),
            animated: true,
            completion: nil)
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
        
        // チェック済み表示・非表示
        var imageCheckmark:UIImage = UIImage(named: "Icon_Checkmark")!
        imageCheckmark = imageCheckmark.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageViewCheckmark = UIImageView(image: imageCheckmark)
        imageViewCheckmark.frame = CGRectMake(posX, posY, iconWidth, iconHeight)
        imageViewCheckmark.userInteractionEnabled = true
        let tapCheckmark:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onCheckmarkButton")
        imageViewCheckmark.addGestureRecognizer(tapCheckmark)
        container.addSubview(imageViewCheckmark)
        
        // リスト編集
        posX = posX + iconWidth + margin
        var imageList:UIImage = UIImage(named: "Icon_Numbered_List")!
        imageList = imageList.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageViewList = UIImageView(image: imageList)
        imageViewList.frame = CGRectMake(posX, posY, iconWidth, iconHeight)
        imageViewList.userInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onListButton")
        imageViewList.addGestureRecognizer(tap)
        container.addSubview(imageViewList)
        
        self.view.addSubview(container)
    }
    
    // 完了済み表示・非表示
    // ContentViewが呼び出された後に実行
    func setCheckmark(display:Bool) {
        var image:UIImage!
        if display {
            image = UIImage(named: "Icon_Checkmark_Filled")
        } else {
            image = UIImage(named: "Icon_Checkmark")!
        }
        image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageViewCheckmark.image = image
        
        // Viewの設定を一括変更
        for (var i = 0; i < contentViews.count; i++) {
            contentViews[i].setDisplayCompleted(displayCompleted)
        }
        
        // 設定保存
        UDWrapper.setBool(UDWrapperKey.UDWrapperKeyReminderDisplayCompleted.rawValue,
            value: displayCompleted)
    }
    
    //-- Coach Marks (Tutorial) --//
    func showCoachMarks() {
        let isCoachMarks = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyCoachMarksReminder.rawValue, defaultValue: false)
        if !isCoachMarks {
            let width:CGFloat   = self.view.frame.size.width
            let height:CGFloat  = self.view.frame.size.height
            
            let iconSize:CGFloat    = 44.0
            let navMargin:CGFloat   = 18.0
            let itemMarginLeft:CGFloat  = 5.0
            let itemMarginRight:CGFloat = 5.0
            
            let value1:NSValue = NSValue(CGRect: CGRectMake(width - (navMargin + iconSize), statusBarHeight, iconSize, iconSize))
            let value2:NSValue = NSValue(CGRect: CGRectMake(itemMarginLeft, statusBarHeight + navBarHeight, iconSize, iconSize))
            let value3:NSValue = NSValue(CGRect: CGRectMake(width - (itemMarginRight + iconSize), statusBarHeight + navBarHeight, iconSize, iconSize))
            
            let posY:CGFloat = height - tabBarHeight

            let iconNum:Int         = 2
            let margin = (width - (iconSize * CGFloat(iconNum))) / (CGFloat(iconNum) + 1)
            var posX = margin
            
            let value4:NSValue = NSValue(CGRect: CGRectMake(posX, posY, iconSize, iconSize))
            
            posX = posX + iconSize + margin
            let value5:NSValue = NSValue(CGRect: CGRectMake(posX, posY, iconSize, iconSize))
            
            let coachMarks = [
                ["rect": value1, "caption": NSLocalizedString("caption_reminder_1", comment: "")],
                ["rect": value2, "caption": NSLocalizedString("caption_reminder_2", comment: "")],
                ["rect": value3, "caption": NSLocalizedString("caption_reminder_3", comment: "")],
                ["rect": value4, "caption": NSLocalizedString("caption_reminder_4", comment: "")],
                ["rect": value5, "caption": NSLocalizedString("caption_reminder_5", comment: "")]
            ]

            // ダミーアイテムの表示
            showDummyItem()
            
            let coachMarksView:WSCoachMarksView = WSCoachMarksView(frame: self.view.bounds, coachMarks: coachMarks)
            coachMarksView.delegate = self
            self.view.addSubview(coachMarksView)
            coachMarksView.start()
            
            UDWrapper.setBool(UDWrapperKey.UDWrapperKeyCoachMarksReminder.rawValue, value: true)
        }
    }
    
    func showDummyItem() {
        let dummy:UIView = UIView(frame: CGRectMake(0, statusBarHeight + navBarHeight, self.view.frame.size.width, 44))
        dummy.backgroundColor = UIColor.whiteColor()
        dummy.tag = 99 // 削除対象
        
        var image:UIImage = UIImage(named: "Icon_Reminder_Checkmark_ON")!
        image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        var imageView:UIImageView = UIImageView(frame: CGRectMake(17, 11, 22, 22))
        imageView.image = image
        imageView.tintColor = UIColor(hexString: theme.tabSegctr, alpha: 1.0)
        dummy.addSubview(imageView)
        
        let label:UILabel = UILabel(frame: CGRectMake(54, 0, 200, 44))
        label.text = NSLocalizedString("reminder_default_item_title", comment: "")
        label.textColor = ColorManager.getReminderCellText()
        label.font = FontManager.getReminderCellText()
        dummy.addSubview(label)

        image = UIImage(named: "Icon_Reminder_Dummy_Info")!
        image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageView = UIImageView(frame: CGRectMake(self.view.frame.size.width - 37, 11, 22, 22))
        imageView.image = image
        imageView.tintColor = UIColor(hexString: theme.tabSegctr, alpha: 1.0)
        dummy.addSubview(imageView)
        
        self.view.addSubview(dummy)
    }
    
    /*
    func coachMarksViewWillCleanup(coachMarksView: WSCoachMarksView!) {
    }*/
    
    func coachMarksViewDidCleanup(coachMarksView: WSCoachMarksView!) {
        // ダミーアイテムの削除
        let subViews:[UIView] = self.view.subviews
        for view in subViews {
            if view.tag == 99 {
                view.removeFromSuperview()
            }
        }
    }
    
    //-- Notification Center --//
    // ReminderViewからの編集フォームの呼び出し
    func receiveDisplayForm(notification: NSNotification?) {
        if let userInfo = notification?.userInfo {
            skipViewWillAppear = true
            let reminder = userInfo["reminder"]! as! EKReminder
            let reminderItemFormView:ReminderEditViewController = ReminderEditViewController()
            reminderItemFormView.reminder = reminder
            self.presentViewController(UINavigationController(rootViewController: reminderItemFormView),
                animated: true,
                completion: nil)
        }
    }
    
    // 編集フォームから戻ってきた
    func receiveBackForm(notification: NSNotification?) {
        print("--- receiveBackForm() ---")
        if let userInfo = notification?.userInfo {
            let reminder = userInfo["reminder"] as! EKReminder
            // カレンダー情報から該当のページをサーチ
            var page:Int = 0
            for (i, calendar) in calendars.enumerate() {
                if calendar.calendarIdentifier == reminder.calendar.calendarIdentifier {
                    page = i
                    break;
                }
            }
            print("Page : \(page)")
            loadAllData()   // 再読み込み
            movePage(page)  // 指定のページへ移動
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: Const.getNotificationNameReminderDisplayForm(),
            object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: Const.getNotificationNameReminderBackForm(),
            object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
