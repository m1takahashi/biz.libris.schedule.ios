///
//  AppDelegate.swift
//

import UIKit
import CoreData

enum CenterViewType {
    case CenterViewTypeCalMonth
    case CenterViewTypeCalWeek
    case CenterViewTypeCalDay
    case CenterViewTypeSettingTheme
    case CenterViewTypeSettingCal
    case CenterViewTypeSettingOther
    case CenterViewTypeReminder
    case CenterViewTypeNote
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var drawerViewController: DrawerViewController!
    var drawerController: DrawerController!
    var calDayViewController: CalDayViewController!
    var calMonthViewController: CalMonthViewController!
    var calWeekViewController: CalWeekViewController!
    var settingThemeViewController: SettingThemeViewController!
    var reminderMainViewController: ReminderMainViewController!
    var noteMainViewController: NoteMainViewController!
    var navSettingCalViewController: UINavigationController!
    var navSettingOtherViewController: UINavigationController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //-- Calender  --//
        calMonthViewController = CalMonthViewController()
        calWeekViewController = CalWeekViewController()
        calDayViewController = CalDayViewController()
        
        //-- Reminder --//
        reminderMainViewController = ReminderMainViewController()
        
        //-- Note --//
        noteMainViewController = NoteMainViewController()
        
        //-- Setting --//
        settingThemeViewController = SettingThemeViewController()
        let settingCalViewController:SettingCalViewController = SettingCalViewController()
        let settingOtherViewController:SettingOtherViewController = SettingOtherViewController()
        navSettingCalViewController = UINavigationController(rootViewController: settingCalViewController)
        navSettingOtherViewController = UINavigationController(rootViewController: settingOtherViewController)
        
        
        //-- Drawer --//
        // 左メニューはNavigationにしない
        drawerViewController = DrawerViewController()
        
        // スタートページ
        let startPageMode:Int = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyStartPageMode.rawValue, defaultValue: StartPageMode.Calendar.rawValue)
        if startPageMode == StartPageMode.Reminder.rawValue {
            self.drawerController = DrawerController(centerViewController: reminderMainViewController, leftDrawerViewController: drawerViewController)
        } else if startPageMode == StartPageMode.Note.rawValue {
            self.drawerController = DrawerController(centerViewController: noteMainViewController, leftDrawerViewController: drawerViewController)
        } else {
            let startPage:Int = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyStartPage.rawValue, defaultValue: StartPageType.Month.rawValue)
            switch (startPage) {
            case StartPageType.Week.rawValue:
                self.drawerController = DrawerController(centerViewController: calWeekViewController, leftDrawerViewController: drawerViewController)
                break;
            case StartPageType.Day.rawValue:
                self.drawerController = DrawerController(centerViewController: calDayViewController, leftDrawerViewController: drawerViewController)
                break;
            case StartPageType.Month.rawValue:
                self.drawerController = DrawerController(centerViewController: calMonthViewController, leftDrawerViewController: drawerViewController)
            default:
                break;
            }
        }
        
        self.drawerController.showsShadows = true
        self.drawerController.restorationIdentifier = "Drawer"
        self.drawerController.maximumLeftDrawerWidth = 240.0
        self.drawerController.openDrawerGestureModeMask = .All
        self.drawerController.closeDrawerGestureModeMask = .All
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let tintColor = UIColor(red: 29 / 255, green: 173 / 255, blue: 234 / 255, alpha: 1.0)
        self.window!.tintColor = tintColor
        
        self.window!.rootViewController = self.drawerController
        self.window?.makeKeyAndVisible()
        return true
    }
    
    // センター画面切り替え
    func switchCenterView(type: CenterViewType, param: AnyObject!) {
        switch type {
        case .CenterViewTypeSettingTheme:
            self.drawerController.centerViewController = settingThemeViewController
            break;
        case .CenterViewTypeSettingCal:
            self.drawerController.centerViewController = navSettingCalViewController
            break;
        case .CenterViewTypeSettingOther:
            self.drawerController.centerViewController = navSettingOtherViewController
            break;
        case .CenterViewTypeCalMonth:
            self.drawerController.centerViewController = calMonthViewController
            break;
        case .CenterViewTypeCalWeek:
            self.drawerController.centerViewController = calWeekViewController
            break;
        case .CenterViewTypeCalDay:
            if param != nil {
                if let date:NSDate = param["date"] as? NSDate {
                    calDayViewController.currentDate = date as NSDate
                }
            }
            self.drawerController.centerViewController = calDayViewController
            break;
        case .CenterViewTypeReminder:
            self.drawerController.centerViewController = reminderMainViewController
            break;
        case .CenterViewTypeNote:
            self.drawerController.centerViewController = noteMainViewController
            break;
        }
    }
    
    // Drawerテーマ切り替え
    func changeDrawerTheme(param: ThemeData) {
        drawerViewController.changeTheme(param)
    }
    
    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Note", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("schedule.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil

            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)

            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
}

