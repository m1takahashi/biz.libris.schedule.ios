//
//  CalWeekViewController.swift
//  http://qiita.com/kitanoow/items/65b1418527eabf31e45b
//

import UIKit
import EventKit
import EventKitUI

class CalWeekViewController: CalViewController, UIScrollViewDelegate {

    var contentsView:UIView?
    var scrollView:UIScrollView!
    var prevView:CalWeekView!
    var currentView:CalWeekView!
    var nextView:CalWeekView!
    
    var contentsHeight:CGFloat!
    
    var index:Int = 1;
    var startOfWeek:Int = 1 // 1:日曜日、2:月曜日
    
    var currentDate:NSDate! // 週初め関係ない持ち回し用日付
    
    var currentWeek:NSDate! // 基準は週初め
    var prevWeek:NSDate!
    var nextWeek:NSDate!
    
    var currentData:[[EKEvent]]!
    var prevData:[[EKEvent]]!
    var nextData:[[EKEvent]]!
    
    var scrollDirection:Int = ScrollDirection.Horizontal.rawValue
    
    var customTabBar:CustomTabBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "receiveAddEvent:", name: Const.getNotificationNameEventAddWeekGrid(), object: nil)
        nc.addObserver(self, selector: "receiveEditEvent:", name: Const.getNotificationNameEventEdit(), object: nil)
        nc.addObserver(self, selector: "receiveMoveThisWeek:", name: Const.getNotificationNameThisWeek(), object: nil)
        
        initCustomTabBar()
        
        contentsHeight = self.view.frame.height - (statusBarHeight + navBarHeight + tabBarHeight)
        
        scrollView = UIScrollView(frame: CGRectMake(0, statusBarHeight + navBarHeight, self.view.frame.width, contentsHeight))
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        scrollDirection = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyScrollDirectionWeek.rawValue, defaultValue: ScrollDirection.Horizontal.rawValue)
        switch (scrollDirection ) {
        case ScrollDirection.Vertical.rawValue:
            scrollView.contentSize = CGSizeMake(self.view.frame.width, contentsHeight * 3)
            scrollView.contentOffset = CGPointMake(0, contentsHeight)
            currentView = CalWeekView(frame: CGRectMake(0, contentsHeight, self.view.frame.size.width, contentsHeight))
            prevView = CalWeekView(frame: CGRectMake(0, 0, self.view.frame.size.width, contentsHeight))
            nextView = CalWeekView(frame: CGRectMake(0, contentsHeight * 2, self.view.frame.size.width, contentsHeight))
            break;
        case ScrollDirection.Horizontal.rawValue:
            scrollView.contentSize = CGSizeMake(self.view.frame.width * 3.0, contentsHeight)
            scrollView.contentOffset = CGPointMake(self.view.frame.width, 0.0)
            currentView = CalWeekView(frame: CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, contentsHeight))
            prevView = CalWeekView(frame: CGRectMake(0.0, 0, self.view.frame.size.width, contentsHeight))
            nextView = CalWeekView(frame: CGRectMake(self.view.frame.size.width * 2.0, 0, self.view.frame.size.width, contentsHeight))
        default:
            break;
        }
        
        scrollView.addSubview(currentView)
        scrollView.addSubview(prevView)
        scrollView.addSubview(nextView)
        self.view.addSubview(scrollView)
        
        showCoachMarks() // 最後
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 再読み込み不要
        if skipViewWillAppear {
            skipViewWillAppear = false
            return
        }
        
        var date:NSDate = NSDate()
        if (currentDate != nil) {
            date = currentDate
            currentDate = nil
        }
        
        loadAllData(date)
        
        scrollDirection = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyScrollDirectionWeek.rawValue,
            defaultValue: ScrollDirection.Horizontal.rawValue)
        switch (scrollDirection ) {
        case ScrollDirection.Vertical.rawValue:
            scrollView.contentSize = CGSizeMake(self.view.frame.width, contentsHeight * 3)
            scrollView.contentOffset = CGPointMake(0, contentsHeight)
            currentView.frame = CGRectMake(0, contentsHeight, self.view.frame.size.width, contentsHeight)
            prevView.frame = CGRectMake(0, 0, self.view.frame.size.width, contentsHeight)
            nextView.frame = CGRectMake(0, contentsHeight * 2, self.view.frame.size.width, contentsHeight)
            break;
        case ScrollDirection.Horizontal.rawValue:
            scrollView.contentSize = CGSizeMake(self.view.frame.width * 3.0, contentsHeight)
            scrollView.contentOffset = CGPointMake(self.view.frame.width, 0.0)
            currentView.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, contentsHeight)
            prevView.frame = CGRectMake(0.0, 0, self.view.frame.size.width, contentsHeight)
            nextView.frame = CGRectMake(self.view.frame.size.width * 2.0, 0, self.view.frame.size.width, contentsHeight)
        default:
            break;
        }
        
        setContents(currentWeek, pWeek: prevWeek, nWeek: nextWeek, cData: currentData, pData: prevData, nData: nextData)
        customTabBar.setSelected(CustomTabBarType.Week)
        customTabBar.setSegctrColor(UIColor(hexString: themeData.tabSegctr, alpha: 1.0))
    }
    
    //-- EKEventViewEditController --//
    // イベント追加完了
    override func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction) {
        switch (action.rawValue) {
        case EKEventEditViewAction.Canceled.rawValue:
            skipViewWillAppear = true // 再読み込み不要
            break;
        case EKEventEditViewAction.Saved.rawValue:
            // 実際に編集した内容を反映させる
            // viewWillAppear()で自動的に再読み込み
            currentDate = NSDate.create(year: controller.event!.startDate.year,
                month: controller.event!.startDate.month,
                day: controller.event!.startDate.day,
                hour: 0,
                minute: 0,
                second: 0)!
            do {
                try controller.eventStore.saveEvent(controller.event!, span: EKSpan.ThisEvent)
            } catch _ {
            }
            break;
        case EKEventEditViewAction.Deleted.rawValue:
            // viewWillAppear()で自動的に再読み込み
            currentDate = NSDate.create(year: controller.event!.startDate.year,
                month: controller.event!.startDate.month,
                day: controller.event!.startDate.day,
                hour: 0,
                minute: 0,
                second: 0)!
            break;
        default:
            break;
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // date: 週の開始関係ない日付
    private func loadAllData(date:NSDate) {
        let startWeekday:Int = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyStartWeekday.rawValue,
            defaultValue: StartWeek.Sunday.rawValue)

        currentWeek = CalendarUtilWeek.getStartOfWeekDay(startWeekday, today: date)
//        println("----  Cueernt Week : \(currentWeek.year)/\(currentWeek.month)/\(currentWeek.day)")
        prevWeek = CalendarUtilWeek.getPrevWeekDay(currentWeek)
        nextWeek = CalendarUtilWeek.getNextWeekDay(currentWeek)
        
        let eventData:EventData = EventData(eventStore: eventStore, calendars: getSelectedCalendars())
        currentData = eventData.getWeekData(currentWeek)
        prevData = eventData.getWeekData(prevWeek)
        nextData = eventData.getWeekData(nextWeek)
    }
    
    //-- Scroll View Delegate --//
    func scrollViewDidScroll(scrollView:UIScrollView) {
        switch (scrollDirection ) {
        case ScrollDirection.Vertical.rawValue:
            let pos:CGFloat = scrollView.contentOffset.y / scrollView.bounds.size.height
            let deff:CGFloat = pos - 1.0
            if fabs(deff) >= 1.0 {
                if (deff > 0) {
                    self.showNextView()
                } else {
                    self.showPrevView()
                }
            }
            break;
        case ScrollDirection.Horizontal.rawValue:
            let pos:CGFloat = scrollView.contentOffset.x / scrollView.bounds.size.width
            let deff:CGFloat = pos - 1.0
            if fabs(deff) >= 1.0 {
                if (deff > 0) {
                    self.showNextView()
                } else {
                    self.showPrevView()
                }
            }
        default:
            break;
        }
    }
    
    // 次の週を表示
    func showNextView() {
        currentWeek = CalendarUtilWeek.getNextWeekDay(currentWeek)
        prevWeek = CalendarUtilWeek.getPrevWeekDay(currentWeek)
        nextWeek = CalendarUtilWeek.getNextWeekDay(currentWeek)
 
        prevData = currentData
        currentData = nextData
        let eventData:EventData = EventData(eventStore: eventStore, calendars: getSelectedCalendars())
        nextData = eventData.getWeekData(nextWeek)
        
        setContents(currentWeek, pWeek: prevWeek, nWeek: nextWeek, cData: currentData, pData: prevData, nData: nextData)
        resetContentOffset()
    }
    
    // 前の週を表示
    func showPrevView() {
        currentWeek = CalendarUtilWeek.getPrevWeekDay(currentWeek)
        prevWeek = CalendarUtilWeek.getPrevWeekDay(currentWeek)
        nextWeek = CalendarUtilWeek.getNextWeekDay(currentWeek)
        
        nextData = currentData
        currentData = prevData
        let eventData:EventData = EventData(eventStore: eventStore, calendars: getSelectedCalendars())
        prevData = eventData.getWeekData(prevWeek)
        
        setContents(currentWeek, pWeek: prevWeek, nWeek: nextWeek, cData: currentData, pData: prevData, nData: nextData)
        resetContentOffset()
    }
    
    private func setContents(cWeek:NSDate, pWeek:NSDate, nWeek:NSDate, cData:[[EKEvent]], pData:[[EKEvent]], nData:[[EKEvent]]) {
        currentView.setContents(cWeek, list: cData)
        prevView.setContents(pWeek, list: pData)
        nextView.setContents(nWeek, list: nData)
        setNavigationTitle(cWeek)
    }
    
    func resetContentOffset() {
        switch (scrollDirection ) {
        case ScrollDirection.Vertical.rawValue:
            prevView.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
            currentView.frame = CGRectMake(0, contentsHeight, scrollView.frame.size.width, scrollView.frame.size.height)
            nextView.frame = CGRectMake(0, contentsHeight * 2, scrollView.frame.size.width, scrollView.frame.size.height)
            
            let scrollViewDelegate:UIScrollViewDelegate = scrollView.delegate!
            scrollView.delegate = nil
            scrollView.contentOffset = CGPointMake(0, contentsHeight)
            scrollView.delegate = scrollViewDelegate
            
            break;
            case ScrollDirection.Horizontal.rawValue:
                prevView.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
                currentView.frame = CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height)
                nextView.frame = CGRectMake(scrollView.frame.size.width * 2.0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
                
                let scrollViewDelegate:UIScrollViewDelegate = scrollView.delegate!
                scrollView.delegate = nil
                scrollView.contentOffset = CGPointMake(scrollView.frame.size.width, 0.0)
                scrollView.delegate = scrollViewDelegate
        default:
            break;
        }
    }
    
    //-- Notification Center --//
    func receiveAddEvent(notification: NSNotification?) {
        if let userInfo = notification?.userInfo {
            let date = userInfo["date"]! as! NSDate
            
            // 時間のみ現在時刻を参照する
            let today:NSDate = NSDate()
            
            let startDate:NSDate = NSDate.create(year: date.year, month: date.month, day: date.day, hour: today.hour, minute: 0, second: 0)!
            let endDate:NSDate = NSDate.create(year: date.year, month: date.month, day: date.day, hour: today.hour + 1, minute: 0, second: 0)!
            
            let event:EKEvent = EKEvent(eventStore: eventStore)
            event.startDate = startDate
            event.endDate = endDate
            
            let controller:EKEventEditViewController = EKEventEditViewController()
            controller.eventStore = eventStore
            controller.event = event
            controller.editViewDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func receiveEditEvent(notification: NSNotification?) {
        if let userInfo = notification?.userInfo {
            let result = userInfo["event"]! as! EKEvent
            let controller:EKEventEditViewController = EKEventEditViewController()
            controller.eventStore = eventStore
            controller.event = result
            controller.editViewDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func receiveMoveThisWeek(notification: NSNotification?) {
        let today:NSDate = NSDate()
        loadAllData(today)
        setContents(currentWeek,
            pWeek: prevWeek,
            nWeek: nextWeek,
            cData: currentData,
            pData: prevData,
            nData: nextData)
    }
    
    //-- Design --//
    private func setNavigationTitle(date:NSDate) {
        let list:[NSDate] = CalendarUtilWeek.getWeekList(date)
        let title:String = CalendarUtilWeek.getWeekTitle(list)
        customNavBar.setTitleText(title)
    }
    
    private func initCustomTabBar() {
        let posY:CGFloat = self.view.frame.size.height - CustomTabBar.defaultHeight
        customTabBar = CustomTabBar(frame: CGRectMake(0.0, posY, self.view.frame.size.width, CustomTabBar.defaultHeight), type: CustomTabBarType.Week)
        self.view.addSubview(customTabBar)
    }
    
    //-- Coach Marks (Tutorial) --//
    private func showCoachMarks() {
        let eulaAgree = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyEULA.rawValue, defaultValue: false)
        let isCoachMarks = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyCoachMarksWeek.rawValue, defaultValue: false)
        
        if eulaAgree == true && isCoachMarks == false {
            let value:NSValue = NSValue(CGRect: CGRectMake(0, statusBarHeight + navBarHeight, self.view.frame.width, contentsHeight))
            
            let coachMarks = [
                ["rect": value, "caption": NSLocalizedString("caption_week_scroll", comment: "")]]
            
            let coachMarksView:WSCoachMarksView = WSCoachMarksView(frame: self.view.bounds, coachMarks: coachMarks)
            self.view.addSubview(coachMarksView)
            coachMarksView.start()
            
            UDWrapper.setBool(UDWrapperKey.UDWrapperKeyCoachMarksWeek.rawValue, value: true)
        }
    }
    
    deinit {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name: Const.getNotificationNameEventAddWeekGrid(), object: nil)
        nc.removeObserver(self, name: Const.getNotificationNameEventEdit(), object: nil)
        nc.removeObserver(self, name: Const.getNotificationNameThisWeek(), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
