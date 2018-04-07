//
//  SettingThemeViewController.swift
//  着せ替え
//  note:
//  https://github.com/hayashi311/Color-Picker-for-iOS
//

import UIKit

enum CustomNavColorType : String {
    case Bar   = "custom_nav_bar_color"
    case Text  = "custom_nav_text_color"
}

enum SegmentedType : Int {
    case Image  = 0
    case Color  = 1
    case Custom = 2
}

// SettingViewControllerの継承はしない（Navigationではないから）
class SettingThemeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let segmentedList: NSArray = [NSLocalizedString("setting_theme_image", comment: ""),
        NSLocalizedString("setting_theme_color", comment: ""),
        NSLocalizedString("setting_theme_custom", comment: "")]
    
    let customList:[String] = [NSLocalizedString("setting_theme_custom_nav_bar_color", comment: ""),
        NSLocalizedString("setting_theme_custom_nav_text_color", comment: "")]
    
    var customNavBar:CustomNavigationBar!
    var tableView:UITableView!
    var segmentedCtr:UISegmentedControl!
    
    var btnSave:UIButton!
    var imageViewMenu:UIImageView!
    

    var selectedSegmented:Int = SegmentedType.Image.rawValue
    var displayList:[ThemeData] = []
    var colorList:[ThemeData] = []
    var imageList:[ThemeData] = []
    
    var statusBarHeight:CGFloat!
    var navBarHeight:CGFloat!
    
    var tmpThemeData:ThemeData!
    
    var registerdTheme:String!
    var registerdCustomNavBarColor:String!
    var registerdCustomNavTextColor:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCustomNavigationBar()
        self.view.backgroundColor = UIColor.whiteColor()
        statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        navBarHeight = CustomNavigationBar.defaultHeight
        
        // SegmentedControlを作成する.
        let segCtrHeight:CGFloat = 32.0
        let segCtrMarginTop:CGFloat = 6.0
        let segCtrMarginButtom:CGFloat = 6.0
        
        segmentedCtr = UISegmentedControl(items: segmentedList as [AnyObject])
        let width:CGFloat = 300.0
        let height:CGFloat = segCtrHeight
        
        let posX = (self.view.frame.size.width - width) / 2
        let posY = statusBarHeight + navBarHeight + segCtrMarginTop
        segmentedCtr.frame = CGRectMake(posX, posY, width, height)
        segmentedCtr.addTarget(self, action: "segconChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(segmentedCtr)
        
        // TableView
        let tablePosY = statusBarHeight + navBarHeight + (segCtrMarginTop + segCtrHeight + segCtrMarginButtom)
        let tableHeight = self.view.frame.size.height - tablePosY
        
        tableView = UITableView(frame: CGRect(x: 0, y: tablePosY, width: self.view.frame.size.width, height: tableHeight))
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        
        colorList = ThemeDataUtil.getColorList()
        imageList = ThemeDataUtil.getImageList()
        
        // NotificationCenter オブザーバー登録
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "receiveDismissPopup:",
            name: Const.getNotificationNameDismissPopup(),
            object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        // Color_01, Theme_01, Custom
        registerdTheme = UDWrapper.getString(UDWrapperKey.UDWrapperKeyTheme.rawValue, defaultValue: "")
        registerdCustomNavBarColor = UDWrapper.getString(UDWrapperKey.UDWrapperKeyCustomNavBarColor.rawValue, defaultValue: ColorManager.getThemeCustomNavBarString())
        registerdCustomNavTextColor = UDWrapper.getString(UDWrapperKey.UDWrapperKeyCustomNavTextColor.rawValue, defaultValue: ColorManager.getThemeCustomNavTextString())
        // defaultに指定してもダメな時がある
        if registerdCustomNavBarColor == "" {
            registerdCustomNavBarColor = ColorManager.getThemeCustomNavBarString()
        }
        if registerdCustomNavTextColor == "" {
            registerdCustomNavTextColor = ColorManager.getThemeCustomNavTextString()
        }

        var separated = registerdTheme.componentsSeparatedByString("_")
        var segIndex = 0
        if (separated[0] == "Color") {
            segIndex = 1
            tmpThemeData = ThemeDataUtil.getThemeById(registerdTheme)

        } else if (separated[0] == "Custom") {
            segIndex = 2
            // Preview
            tmpThemeData = ThemeData(id: "Custom_01",
                name: "Custom_01",
                navBg: registerdCustomNavBarColor,
                navText: registerdCustomNavTextColor,
                tabSegctr: registerdCustomNavBarColor,
                type: ThemeType.ThemeTypeCustom)
        } else {
            // Image
            segIndex = 0
            tmpThemeData = ThemeDataUtil.getThemeById(registerdTheme)
            
        }
        
        // SegmentedCtr 選択済み
        segmentedCtr.selectedSegmentIndex = segIndex
        self.changeDisplay(segmentedCtr.selectedSegmentIndex)
        
        // Preview
        changeTheme(tmpThemeData)
    }

    // カスタムナビゲーションバー
    func initCustomNavigationBar() {
        let posY:CGFloat = UIApplication.sharedApplication().statusBarFrame.height
        customNavBar = CustomNavigationBar(frame: CGRectMake(0.0, posY, self.view.frame.size.width, CustomNavigationBar.defaultHeight))
        customNavBar.setTitleText(NSLocalizedString("setting_theme", comment: ""))
        customNavBar.setTitleColor(UIColor(hexString: "333333", alpha: 1.0))
        self.view.addSubview(customNavBar)
        
        // 保存ボタン
        let btnSaveWidth:CGFloat = 80.0
        let btnSavePosX = self.view.frame.size.width - btnSaveWidth
        print("btnSavePosX : \(btnSavePosX)")
        btnSave = UIButton(frame: CGRectMake(btnSavePosX, 0, btnSaveWidth, CustomNavigationBar.defaultHeight))
        btnSave.setTitle(NSLocalizedString("btn_save", comment: ""), forState: UIControlState.Normal)
        btnSave.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        btnSave.titleLabel?.font = UIFont.boldSystemFontOfSize(18.0)
        btnSave.addTarget(self, action: "onSaveButton:", forControlEvents: UIControlEvents.TouchUpInside)
        customNavBar.addSubview(btnSave)
        
        // メニューボタン
        var image:UIImage = UIImage(named: "Icon_Menu")!
        image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageViewMenu = UIImageView(image: image)
        imageViewMenu.userInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "toggleMenu")
        imageViewMenu.addGestureRecognizer(tap)
        imageViewMenu.frame = CGRectMake(18.0, 0.0, 44.0, 44.0)
        customNavBar.addSubview(imageViewMenu)
    }
    
    func toggleMenu() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.drawerController.toggleLeftDrawerSideAnimated(true, completion: nil)
    }
    
    func onSaveButton(sender:UIButton!) {
        switch (selectedSegmented) {
        case SegmentedType.Image.rawValue:
            UDWrapper.setString(UDWrapperKey.UDWrapperKeyTheme.rawValue, value: tmpThemeData.id)
            UDWrapper.setString(UDWrapperKey.UDWrapperKeyCustomNavBarColor.rawValue, value: "")  // Empty Set
            UDWrapper.setString(UDWrapperKey.UDWrapperKeyCustomNavTextColor.rawValue, value: "") // Empty Set
            break;
        case SegmentedType.Color.rawValue:
            UDWrapper.setString(UDWrapperKey.UDWrapperKeyTheme.rawValue, value: tmpThemeData.id)
            UDWrapper.setString(UDWrapperKey.UDWrapperKeyCustomNavBarColor.rawValue, value: "")  // Empty Set
            UDWrapper.setString(UDWrapperKey.UDWrapperKeyCustomNavTextColor.rawValue, value: "") // Empty Set
            break;
        case SegmentedType.Custom.rawValue:
            UDWrapper.setString(UDWrapperKey.UDWrapperKeyTheme.rawValue, value: "Custom_00") // 固定
            UDWrapper.setString(UDWrapperKey.UDWrapperKeyCustomNavBarColor.rawValue, value: tmpThemeData.navBg)
            UDWrapper.setString(UDWrapperKey.UDWrapperKeyCustomNavTextColor.rawValue, value: tmpThemeData.navText)
            break;
        default:
            break;
        }
        
        self.view.makeToast(NSLocalizedString("msg_save_success", comment: ""), duration: (NSTimeInterval)(2.0), position: CSToastPositionCenter)
    }

    //-- TableView --//
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedSegmented == SegmentedType.Custom.rawValue {
            let view:SettingThemeColorPickerViewController = SettingThemeColorPickerViewController()
            if (indexPath.row == 1) {
                view.type = CustomNavColorType.Text
                view.colorStr = registerdCustomNavTextColor
            } else {
                view.type = CustomNavColorType.Bar
                view.colorStr = registerdCustomNavBarColor
            }
            presentPopupViewController(view, animationType:MJPopupViewAnimationSlideBottomBottom)

        } else {
            let data:ThemeData = displayList[indexPath.row]
            tmpThemeData = data // 選択中テーマ
            changeTheme(data) // 表示変更

            // チェックマークつける
            let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        // チェックマーク解除
        if selectedSegmented == SegmentedType.Custom.rawValue {
            
        } else {
            let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSegmented == SegmentedType.Custom.rawValue {
            return customList.count
        }
        return displayList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        cell.selectionStyle = .None
        cell.textLabel?.font = FontManager.getSettingCellText()
        
        if selectedSegmented == SegmentedType.Image.rawValue {
            let data:ThemeData = displayList[indexPath.row]

            cell.textLabel?.text = NSLocalizedString(data.name, comment: "")
            cell.accessoryType = .None
            cell.textLabel?.textColor = ColorManager.getSettingCellText()
            
            if tmpThemeData.id ==  data.id {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            
        } else if selectedSegmented == SegmentedType.Color.rawValue {
            let data:ThemeData = displayList[indexPath.row]
            
            cell.textLabel?.text = "■" + NSLocalizedString(data.name, comment: "")
            cell.accessoryType = .None

            let colorStr:String = displayList[indexPath.row].navBg
            cell.textLabel?.textColor = UIColor(hexString: colorStr, alpha: 1.0)
            
            if tmpThemeData.id ==  data.id {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }

        } else if selectedSegmented == SegmentedType.Custom.rawValue {
            cell.textLabel?.text = customList[indexPath.row]
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.textColor = ColorManager.getSettingCellText()

        }
        return cell
    }
    
    // テーマ設定変更
    func changeTheme(param: ThemeData) {
        
        let navBgColor:UIColor = ThemeDataUtil.getNavigationColor(param)
        
        customNavBar.setBgColor(navBgColor) // Nav Bg
        customNavBar.setTitleColor(UIColor(hexString: param.navText, alpha: 1.0))               // Nav Text
        segmentedCtr.tintColor = UIColor(hexString: param.tabSegctr, alpha: 1.0)                // SegCtr
        imageViewMenu.tintColor = UIColor(hexString: param.navText, alpha: 1.0)                 // Menu
        btnSave.setTitleColor(UIColor(hexString: param.navText, alpha: 1.0), forState: .Normal) // Save
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.changeDrawerTheme(param)
    }
    
    //-- Segmented Control --//
    func segconChanged(segcon: UISegmentedControl){
        changeDisplay(segcon.selectedSegmentIndex)
    }
    
    // 表示内容の変更
    func changeDisplay(param: Int) {
        selectedSegmented = param
        switch param {
        case SegmentedType.Image.rawValue:
            displayList = imageList
        case SegmentedType.Color.rawValue:
            displayList = colorList
        case SegmentedType.Custom.rawValue:
            print("Selected Custom")
        default:
            displayList = imageList
        }
        tableView.reloadData()
    }
    
    //-- Notification Center --//
    func receiveDismissPopup(notification: NSNotification?) {
        if let userInfo = notification?.userInfo {
            let typeStr = userInfo["type_str"]! as! String
            let colorStr = userInfo["color_str"]! as! String
            if (typeStr == CustomNavColorType.Bar.rawValue) {
                registerdCustomNavBarColor = colorStr
            } else if (typeStr == CustomNavColorType.Text.rawValue) {
                registerdCustomNavTextColor = colorStr
            }
            // Preview
            tmpThemeData = ThemeData(id: "Custom_01",
                name: "Custom_01",
                navBg: registerdCustomNavBarColor,
                navText: registerdCustomNavTextColor,
                tabSegctr: registerdCustomNavBarColor,
                type: ThemeType.ThemeTypeCustom)
            changeTheme(tmpThemeData)
        }
        self.dismissPopupViewControllerWithanimationType(MJPopupViewAnimationFade)
    }
    
    deinit {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self,
            name: Const.getNotificationNameDismissPopup(),
            object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
