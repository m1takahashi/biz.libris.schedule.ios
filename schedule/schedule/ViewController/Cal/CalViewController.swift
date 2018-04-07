//
//  CalViewController.swift
//  カレンダー基底クラス
//  http://qiita.com/takecian/items/535742156f34ae36d2a9#2-5
//

import UIKit
import EventKit
import EventKitUI

class CalViewController: UIViewController, EKEventEditViewDelegate {
    var statusBarHeight:CGFloat!
    var navBarHeight:CGFloat!   = 44.0
    var tabBarHeight:CGFloat!
    
    var customNavBar:CustomNavigationBar!

    var themeData:ThemeData!
    var eventStore:EKEventStore!

    var adContainer:UIView!
    
    var eulaAgree:Bool = false
    
    var btnAdd:UIButton!
    var imageViewMenu:UIImageView!
    
    var skipViewWillAppear:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        tabBarHeight = CustomTabBar.defaultHeight
        
        initCustomNavigationBar()
        
        eventStore = EventStore.sharedInstance
        allowAuthorization()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let themeId:String = UDWrapper.getString(UDWrapperKey.UDWrapperKeyTheme.rawValue, defaultValue:"")!
        if (themeId.hasPrefix("Custom")) {
            themeData = ThemeDataUtil.getCustomData()
        } else {
            // 安全のためテーマが見つからなくても、デフォルトのテーマが返ってくる
            themeData = ThemeDataUtil.getThemeById(themeId)
        }
        NSLog("ThemeID : \(themeId)")
        print("Theme Name : \(themeData.name)")
        
        // テーマ反映
        customNavBar.setBgColor(ThemeDataUtil.getNavigationColor(themeData))
        customNavBar.setTitleColor(UIColor(hexString: themeData.navText, alpha: 1.0))
        self.setNavTintColor(UIColor(hexString: themeData.navText, alpha: 1.0))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        popupEULA()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    private func setNavTintColor(color:UIColor) {
        imageViewMenu.tintColor = color
        btnAdd.tintColor = color
    }
    
    // 選択済みカレンダー
    // 保存してあるのは、”表示しない”カレンダーリスト
    func getSelectedCalendars() -> [EKCalendar] {
        let registered = UDWrapper.getDictionary(UDWrapperKey.UDWrapperKeyDisableCalendars.rawValue, defaultValue: Dictionary<String,String> ()) as! Dictionary<String, String>
        var selectedCalendars:[EKCalendar] = []
        let calenders = eventStore.calendarsForEntityType(EKEntityType.Event) 
        for calender in calenders {
            print("Calendar : \(calender)")
            if let _ = registered[ calender.calendarIdentifier ] {
                // println("該当あり")
            } else {
                // println("該当なし")
                selectedCalendars.append(calender)
            }
        }
        return selectedCalendars
    }
    
    //-- Auth --//
    func getAuthorization_status() -> Bool {
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        switch status {
        case EKAuthorizationStatus.NotDetermined:
            print("Calendar Auth : NotDetermined")
            return false
            
        case EKAuthorizationStatus.Denied:
            print("Calendar Auth : Denied")
            return false
            
        case EKAuthorizationStatus.Authorized:
            print("Calendar Auth : Authorized")
            return true
            
        case EKAuthorizationStatus.Restricted:
            print("Calendar Auth : Restricted")
            return false            
        }
    }

    func allowAuthorization() {
        if getAuthorization_status() {
            return
        } else {
            eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
                (granted , error) -> Void in
                if granted {
                    // 初回起動時（NotDetermined）の場合には、認証が完了した後に、EventStoreを再セットする
                    // 再セットしないと、イベントの追加などができなくなる
                    EventStore.deleteSharedInstance()
                    self.eventStore = EventStore.sharedInstance

                    return
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let myAlert = UIAlertController(title: NSLocalizedString("privacy_alert_title", comment: ""),
                            message: NSLocalizedString("privacy_alert_message", comment: ""),
                            preferredStyle: UIAlertControllerStyle.Alert)

                        let okAction = UIAlertAction(title: "OK",
                            style: UIAlertActionStyle.Default,
                            handler: nil)
                        
                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    })
                }
            })
        }
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
        btnAdd.addTarget(self, action: "onAddEventButton:", forControlEvents: UIControlEvents.TouchUpInside)
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

    //-- EKEventEditViewController --//
    func onAddEventButton(sender: UIButton) {
        let controller:EKEventEditViewController = EKEventEditViewController()
        controller.eventStore = eventStore
        controller.editViewDelegate = self
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func toggleMenu() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.drawerController.toggleLeftDrawerSideAnimated(true, completion: nil)
    }
    
    // イベント追加完了
    // 現状、月表示での追加のみ利用、週・日は、Overrideして利用している
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction) {
        switch (action.rawValue) {
        case EKEventEditViewAction.Canceled.rawValue:
            print("キャンセルされました")
            break;
        case EKEventEditViewAction.Saved.rawValue:
            print("保存されました")
            NSLog("%@", controller.event!)
            do {
                try controller.eventStore.saveEvent(controller.event!, span: EKSpan.ThisEvent)
            } catch _ {
            }
            break;
        case EKEventEditViewAction.Deleted.rawValue:
            print("削除されました")
            break;
        default:
            break;
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //-- EULA --//
    func popupEULA() {
        let eulaAgree = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyEULA.rawValue, defaultValue: false)
        if (eulaAgree == false) {
            let eulaViewController:EulaViewController = EulaViewController()
            eulaViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            self.presentViewController(eulaViewController, animated: true, completion: nil)
        }
    }
}
