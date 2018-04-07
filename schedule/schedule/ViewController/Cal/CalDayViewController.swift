//
//  CalDayViewController.swift
//

import UIKit
import EventKit
import EventKitUI

class CalDayViewController: CalViewController, UIScrollViewDelegate {
    var contentsWidth:CGFloat!
    var contentsHeight:CGFloat!

    var customTabBar:CustomTabBar!
    var pagingScrollView:UIScrollView!
    
    var currentView:CalDayView!
    var prevView:CalDayView!
    var nextView:CalDayView!
    
    var currentDate:NSDate! // 外からもアクセスされる
    var prevDate:NSDate!
    var nextDate:NSDate!
    
    var currentData:[EKEvent]!
    var prevData:[EKEvent]!
    var nextData:[EKEvent]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "receiveAddEvent:", name: Const.getNotificationNameEventAddDayTL(), object: nil)
        nc.addObserver(self, selector: "receiveEditEvent:", name: Const.getNotificationNameEventEdit(), object: nil)
        nc.addObserver(self, selector: "receiveMoveToday:", name: Const.getNotificationNameToday(), object: nil)

        initCustomTabBar()
        
        contentsWidth   = self.view.frame.width
        contentsHeight  = self.view.frame.height - (statusBarHeight + navBarHeight + tabBarHeight)
        
        pagingScrollView = UIScrollView(frame: CGRectMake(0, statusBarHeight + navBarHeight, contentsWidth, contentsHeight))
        pagingScrollView.pagingEnabled = true
        pagingScrollView.bounces = false
        pagingScrollView.contentSize = CGSizeMake(contentsWidth * 3.0, contentsHeight)
        pagingScrollView.contentOffset = CGPointMake(contentsWidth, 0.0)
        pagingScrollView.delegate = self
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(pagingScrollView)
        
        currentView = CalDayView(frame: CGRectMake(contentsWidth, 0, contentsWidth, contentsHeight))
        prevView = CalDayView(frame: CGRectMake(0.0, 0, contentsWidth, contentsHeight))
        nextView = CalDayView(frame: CGRectMake(contentsWidth * 2.0, 0, contentsWidth, contentsHeight))
        
        pagingScrollView.addSubview(currentView)
        pagingScrollView.addSubview(prevView)
        pagingScrollView.addSubview(nextView)
        
        showCoachMarks()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // 再読み込み不要
        if skipViewWillAppear {
            skipViewWillAppear = false
            return
        }
        
        if currentDate == nil {
            currentDate = NSDate()
        }
        
        loadAllData(currentDate)
        setContents(currentDate, pDate: prevDate, nDate: nextDate, cData: currentData, pData: prevData, nData: nextData)
        
        customTabBar.setSelected(CustomTabBarType.Day)
        customTabBar.setSegctrColor(UIColor(hexString: themeData.tabSegctr, alpha: 1.0))
    }
    
    //-- EKEventEditViewController --//
    // 日表示のイベント追加のみ、表示している日時をデフォルトでセットする
    override func onAddEventButton(sender: UIButton) {
        let today:NSDate = NSDate()
        
        let startDate:NSDate = NSDate.create(year: currentDate.year,
            month: currentDate.month,
            day: currentDate.day,
            hour: today.hour,
            minute: 0,
            second: 0)!
        
        let endDate:NSDate = NSDate.create(year: currentDate.year,
            month: currentDate.month,
            day: currentDate.day,
            hour: today.hour + 1,
            minute: 0,
            second: 0)!
        
        let event:EKEvent = EKEvent(eventStore: eventStore)
        event.startDate = startDate
        event.endDate = endDate
        
        let controller:EKEventEditViewController = EKEventEditViewController()
        controller.eventStore = eventStore
        controller.event = event
        controller.editViewDelegate = self
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
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
            break;
        default:
            break;
        }        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 当日、前日、次の日のデータ、全てを取得しセットする
    private func loadAllData(date:NSDate) {
        //currentDate = NSDate()
        currentDate = date
        prevDate = CalendarUtilDay.getPrevDay(currentDate)
        nextDate = CalendarUtilDay.getNextDay(currentDate)

        let eventData:EventData = EventData(eventStore: eventStore, calendars: getSelectedCalendars())
        currentData = eventData.getDayData(currentDate)
        prevData = eventData.getDayData(prevDate)
        nextData = eventData.getDayData(nextDate)
    }
    
    //-- Scroll View Delegate --//
    func scrollViewDidScroll(scrollView:UIScrollView) {
        let pos:CGFloat = scrollView.contentOffset.x / scrollView.bounds.size.width
        let deff:CGFloat = pos - 1.0
        if fabs(deff) >= 1.0 {
            if (deff > 0) {
                self.showNextView()
            } else {
                self.showPrevView()
            }
        }
    }
    
    private func showNextView() {
        currentDate = CalendarUtilDay.getNextDay(currentDate)
        prevDate = CalendarUtilDay.getPrevDay(currentDate)
        nextDate = CalendarUtilDay.getNextDay(currentDate)

        prevData = currentData
        currentData = nextData
        let eventData:EventData = EventData(eventStore: eventStore, calendars: getSelectedCalendars())
        nextData = eventData.getDayData(nextDate)
        
        setContents(currentDate, pDate: prevDate, nDate: nextDate, cData: currentData, pData: prevData, nData: nextData)
        self.resetContentOffset()
    }
    
    private func showPrevView() {
        currentDate = CalendarUtilDay.getPrevDay(currentDate)
        prevDate = CalendarUtilDay.getPrevDay(currentDate)
        nextDate = CalendarUtilDay.getNextDay(currentDate)
        
        nextData = currentData
        currentData = prevData
        let eventData:EventData = EventData(eventStore: eventStore, calendars: getSelectedCalendars())
        prevData = eventData.getDayData(prevDate)
        
        setContents(currentDate, pDate: prevDate, nDate: nextDate, cData: currentData, pData: prevData, nData: nextData)
        self.resetContentOffset()
    }
    
    private func setContents(cDate:NSDate, pDate:NSDate, nDate:NSDate, cData:[EKEvent], pData:[EKEvent], nData:[EKEvent]) {
        currentView.setContents(cDate, events: cData)
        prevView.setContents(pDate, events: pData)
        nextView.setContents(nDate, events: nData)
        setNavigationTitle(cDate)
    }
    
    func resetContentOffset() {
        prevView.frame = CGRectMake(0, 0, pagingScrollView.frame.size.width, pagingScrollView.frame.size.height)
        currentView.frame = CGRectMake(pagingScrollView.frame.size.width, 0, pagingScrollView.frame.size.width, pagingScrollView.frame.size.height)
        nextView.frame = CGRectMake(pagingScrollView.frame.size.width * 2.0, 0, pagingScrollView.frame.size.width, pagingScrollView.frame.size.height)
        let scrollViewDelegate:UIScrollViewDelegate = pagingScrollView.delegate!
        pagingScrollView.delegate = nil
        pagingScrollView.contentOffset = CGPointMake(pagingScrollView.frame.size.width, 0.0)
        pagingScrollView.delegate = scrollViewDelegate
    }
    
    //-- Design --//
    func setNavigationTitle(date:NSDate) {
        let title:String = "\(date.year)/\(date.month)"
        customNavBar.setTitleText(title)
    }
    
    func initCustomTabBar() {
        let posY:CGFloat = self.view.frame.size.height - (CustomTabBar.defaultHeight)
        customTabBar = CustomTabBar(frame: CGRectMake(0.0, posY, self.view.frame.size.width, CustomTabBar.defaultHeight), type: CustomTabBarType.Day)
        self.view.addSubview(customTabBar)
    }
    
    //-- Notification Center --//
    func receiveAddEvent(notification: NSNotification?) {
        if let userInfo = notification?.userInfo {
            let date = userInfo["date"]! as! NSDate
            
            let endDate:NSDate = NSDate.create(year: date.year,
                month: date.month,
                day: date.day,
                hour: date.hour + 1,
                minute: 0,
                second: 0)!
            
            let event:EKEvent = EKEvent(eventStore: eventStore)
            event.startDate = date
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
    
    func receiveMoveToday(notification: NSNotification?) {
        loadAllData(NSDate()) // 今日を指定
        setContents(currentDate, pDate: prevDate, nDate: nextDate, cData: currentData, pData: prevData, nData: nextData)
    }
    
    //-- Coach Marks (Tutorial) --//
    func showCoachMarks() {
        let eulaAgree = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyEULA.rawValue, defaultValue: false)
        let isCoachMarks = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyCoachMarksDay.rawValue, defaultValue: false)
        if eulaAgree == true && isCoachMarks == false {
            let value:NSValue = NSValue(CGRect: CGRectMake(0, statusBarHeight + navBarHeight, self.view.frame.width, contentsHeight))
            let coachMarks = [["rect": value, "caption": NSLocalizedString("caption_day_scroll", comment: "")]]
            let coachMarksView:WSCoachMarksView = WSCoachMarksView(frame: self.view.bounds, coachMarks: coachMarks)
            self.view.addSubview(coachMarksView)
            coachMarksView.start()
            UDWrapper.setBool(UDWrapperKey.UDWrapperKeyCoachMarksDay.rawValue, value: true)
        }
    }

    deinit {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name: Const.getNotificationNameEventAddDayTL(), object: nil)
        nc.removeObserver(self, name: Const.getNotificationNameEventEdit(), object: nil)
        nc.removeObserver(self, name: Const.getNotificationNameToday(), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
