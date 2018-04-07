//
//  CalMonthScrollViewController.swift
//
import UIKit
import EventKit

class CalMonthViewController: CalViewController, UIScrollViewDelegate {
    var scrollView:UIScrollView!
    var scrollBeginingPoint: CGPoint!
    var contentsHeight:CGFloat!
    
    var menuWeek:CalMonthWeekdayView!
    
    var currentView:CalMonthView!
    var prevView:CalMonthView!
    var nextView:CalMonthView!
    
    var currentData:[[EKEvent]]!
    var prevData:[[EKEvent]]!
    var nextData:[[EKEvent]]!
    
    var currentYear:Int!
    var currentMonth:Int!
    
    var scrollDirection:Int = ScrollDirection.Vertical.rawValue
    
    var customTabBar:CustomTabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "receiveMoveThisMonth:", name: Const.getNotificationNameThisMonth(), object: nil)
        
        initCustomTabBar()

        contentsHeight = self.view.frame.height - (statusBarHeight + navBarHeight + CalMonthWeekdayView.defaultHeight + tabBarHeight)
        
        menuWeek = CalMonthWeekdayView(frame: CGRectMake(0, statusBarHeight + navBarHeight, self.view.frame.size.width, CalMonthWeekdayView.defaultHeight))
        self.view.addSubview(menuWeek)
        
        scrollView = UIScrollView(frame: CGRectMake(0, statusBarHeight + navBarHeight + CalMonthWeekdayView.defaultHeight, self.view.frame.width, contentsHeight))
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        scrollDirection = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyScrollDirection.rawValue, defaultValue: ScrollDirection.Vertical.rawValue)
        switch (scrollDirection ) {
        case ScrollDirection.Horizontal.rawValue:
            scrollView.contentSize = CGSizeMake(self.view.frame.width * 3, contentsHeight)
            scrollView.contentOffset = CGPointMake(self.view.frame.width, 0)
            currentView = CalMonthView(frame: CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, contentsHeight))
            prevView = CalMonthView(frame: CGRectMake(0, 0, self.view.frame.size.width, contentsHeight))
            nextView = CalMonthView(frame: CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, contentsHeight))
            break;
        case ScrollDirection.Vertical.rawValue:
            scrollView.contentSize = CGSizeMake(self.view.frame.width, contentsHeight * 3)
            scrollView.contentOffset = CGPointMake(0, contentsHeight)
            currentView = CalMonthView(frame: CGRectMake(0, contentsHeight, self.view.frame.size.width, contentsHeight))
            prevView = CalMonthView(frame: CGRectMake(0, 0, self.view.frame.size.width, contentsHeight))
            nextView = CalMonthView(frame: CGRectMake(0, contentsHeight * 2, self.view.frame.size.width, contentsHeight))
        default:
            break;
        }

        scrollView.addSubview(currentView)
        scrollView.addSubview(prevView)
        scrollView.addSubview(nextView)
        self.view.addSubview(scrollView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 再読み込み不要
        if skipViewWillAppear {
            skipViewWillAppear = false
            return
        }
        
        loadAllData()

        // Scroll
        scrollDirection = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyScrollDirection.rawValue, defaultValue: ScrollDirection.Vertical.rawValue)
        switch (scrollDirection ) {
        case ScrollDirection.Horizontal.rawValue:
            scrollView.contentSize = CGSizeMake(self.view.frame.width * 3, contentsHeight)
            scrollView.contentOffset = CGPointMake(self.view.frame.width, 0)
            currentView.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, contentsHeight)
            prevView.frame = CGRectMake(0, 0, self.view.frame.size.width, contentsHeight)
            nextView.frame = CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, contentsHeight)
            break;
        case ScrollDirection.Vertical.rawValue:
            scrollView.contentSize = CGSizeMake(self.view.frame.width, contentsHeight * 3)
            scrollView.contentOffset = CGPointMake(0, contentsHeight)
            currentView.frame = CGRectMake(0, contentsHeight, self.view.frame.size.width, contentsHeight)
            prevView.frame = CGRectMake(0, 0, self.view.frame.size.width, contentsHeight)
            nextView.frame = CGRectMake(0, contentsHeight * 2, self.view.frame.size.width, contentsHeight)
         default:
            break;
        }
        
        
        // 週メニュー
        let startWeekday:Int = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyStartWeekday.rawValue, defaultValue: StartWeek.Sunday.rawValue)
        menuWeek.changeStartWeek(startWeekday)
        
        customTabBar.setSelected(CustomTabBarType.Month)
        customTabBar.setSegctrColor(UIColor(hexString: themeData.tabSegctr, alpha: 1.0))
        
        showCoachMarks()
    }
    
    func loadAllData() {
        let today = NSDate()
        currentYear = today.year
        currentMonth = today.month
        
        let (prevYear, prevMonth) = CalendarUtilMonth.getPrevYearAndMonth(currentYear, month: currentMonth)
        let (nextYear, nextMonth) = CalendarUtilMonth.getNextYearAndMonth(currentYear, month: currentMonth)
        
        let eventData:EventData = EventData(eventStore: eventStore, calendars: getSelectedCalendars())
        currentData = eventData.getMonthData(currentYear, month: currentMonth)
        prevData = eventData.getMonthData(prevYear, month: prevMonth)
        nextData = eventData.getMonthData(nextYear, month: nextMonth)
        
        setContents(currentYear,
            cMonth: currentMonth,
            pYear: prevYear,
            pMonth: prevMonth,
            nYear: nextYear,
            nMonth: nextMonth,
            cData: currentData,
            pData: prevData,
            nData: nextData)
    }
    
    func scrollViewDidScroll(scrollView:UIScrollView) {
        switch (scrollDirection ) {
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
            break;
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
        default:
            break;
        }
    }
    
    // 次月
    func showNextView() {
        var (nextYear, nextMonth) = CalendarUtilMonth.getNextYearAndMonth(currentYear, month: currentMonth)
        currentYear = nextYear
        currentMonth = nextMonth

        let (prevYear, prevMonth) = CalendarUtilMonth.getPrevYearAndMonth(currentYear, month: currentMonth)
        (nextYear, nextMonth) = CalendarUtilMonth.getNextYearAndMonth(currentYear, month: currentMonth)

        // Current -> Prev, Next -> Current, Next -> Get NEW
        prevData = currentData
        currentData = nextData
        let eventData:EventData = EventData(eventStore: eventStore, calendars: getSelectedCalendars())
        nextData = eventData.getMonthData(nextYear, month: nextMonth)
        
        setContents(currentYear,
            cMonth: currentMonth,
            pYear: prevYear,
            pMonth: prevMonth,
            nYear: nextYear,
            nMonth: nextMonth,
            cData: currentData,
            pData: prevData,
            nData: nextData)
        
        resetContentOffset()
    }
    
    // 先月
    func showPrevView() {
        var (prevYear, prevMonth) = CalendarUtilMonth.getPrevYearAndMonth(currentYear, month: currentMonth)
        currentYear = prevYear
        currentMonth = prevMonth
        
        (prevYear, prevMonth) = CalendarUtilMonth.getPrevYearAndMonth(currentYear, month: currentMonth)
        let (nextYear, nextMonth) = CalendarUtilMonth.getNextYearAndMonth(currentYear, month: currentMonth)
        
        nextData = currentData
        currentData = prevData
        let eventData:EventData = EventData(eventStore: eventStore, calendars: getSelectedCalendars())
        prevData = eventData.getMonthData(prevYear, month: prevMonth)
        
        setContents(currentYear,
            cMonth: currentMonth,
            pYear: prevYear,
            pMonth: prevMonth,
            nYear: nextYear,
            nMonth: nextMonth,
            cData: currentData,
            pData: prevData,
            nData: nextData)

        resetContentOffset()
    }
    
    func setContents(cYear:Int, cMonth:Int, pYear:Int, pMonth:Int, nYear:Int, nMonth:Int, cData:[[EKEvent]], pData:[[EKEvent]], nData:[[EKEvent]]) {
        currentView.setContents(cYear, month: cMonth, list: cData)
        prevView.setContents(pYear, month: pMonth, list: pData)
        nextView.setContents(nYear, month: nMonth, list: nData)
        setTitle(cYear, month:cMonth)
    }

    // Reset Offset
    func resetContentOffset() {
        switch (scrollDirection ) {
        case ScrollDirection.Horizontal.rawValue:
            prevView.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
            currentView.frame = CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height)
            nextView.frame = CGRectMake(scrollView.frame.size.width * 2.0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
            
            let scrollViewDelegate:UIScrollViewDelegate = scrollView.delegate!
            scrollView.delegate = nil
            scrollView.contentOffset = CGPointMake(scrollView.frame.size.width, 0.0)
            scrollView.delegate = scrollViewDelegate
        
            break;
        case ScrollDirection.Vertical.rawValue:
            prevView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, contentsHeight)
            currentView.frame = CGRectMake(0.0, contentsHeight, self.view.frame.size.width, contentsHeight)
            nextView.frame = CGRectMake(0.0, contentsHeight*2, self.view.frame.size.width, contentsHeight)
            let scrollViewDelegate:UIScrollViewDelegate = scrollView.delegate!
            scrollView.delegate = nil
            scrollView.contentOffset = CGPointMake(0.0, scrollView.frame.size.height)
            scrollView.delegate = scrollViewDelegate
        default:
            break;
        }
    }
    
    //-- Design --//
    func setTitle(year:Int, month:Int) {
        customNavBar.setTitleText("\(year)/\(month)")
    }
    
    func initCustomTabBar() {
        let posY:CGFloat = self.view.frame.size.height - CustomTabBar.defaultHeight
        customTabBar = CustomTabBar(frame: CGRectMake(0.0, posY, self.view.frame.size.width, CustomTabBar.defaultHeight), type: CustomTabBarType.Month)
        self.view.addSubview(customTabBar)
    }
    
    //-- Coach Marks (Tutorial) --//
    func showCoachMarks() {
        let eulaAgree = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyEULA.rawValue, defaultValue: false)
        let isCoachMarks = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyCoachMarksMonth.rawValue, defaultValue: false)
        
        if eulaAgree == true && isCoachMarks == false {
            let value1:NSValue = NSValue(CGRect: CGRectMake(18, 20, 44, 44))
            let value2:NSValue = NSValue(CGRect: CGRectMake(0, statusBarHeight + navBarHeight + CalMonthWeekdayView.defaultHeight, self.view.frame.width, contentsHeight))
            
            let coachMarks = [
                ["rect": value1, "caption": NSLocalizedString("caption_month_menu", comment: "")],
                ["rect": value2, "caption": NSLocalizedString("caption_month_scroll", comment: "")]]
            
            let coachMarksView:WSCoachMarksView = WSCoachMarksView(frame: self.view.bounds, coachMarks: coachMarks)
            self.view.addSubview(coachMarksView)
            coachMarksView.start()
            
            UDWrapper.setBool(UDWrapperKey.UDWrapperKeyCoachMarksMonth.rawValue, value: true)
        }
    }
    
    //-- Notification --//
    func receiveMoveThisMonth(notification: NSNotification?) {
        loadAllData()
    }
    
    deinit {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name: Const.getNotificationNameThisMonth(), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}