//
//  CalDayView.swift
//

import UIKit
import EventKit
import EventKitUI

class CalDayView: CalView {
    var width:CGFloat!
    let allDayHeight:CGFloat                = 80.0
    let timelineRowHeight:CGFloat           = 60.0
    var timelineContentsHeight:CGFloat!
    let timelineContentsHourWidth:CGFloat   = 60.0
    let allDayPrefixWidth:CGFloat           = 60.0 // ２日、月曜日、赤口
    
    let dayFontSize:CGFloat     = 22.0
    let weekFontSize:CGFloat    = 12.0
    let rokuyouFontSize:CGFloat = 12.0
    
    let timeFontSize:CGFloat    = 12.0
    let titleFontSize:CGFloat   = 12.0
    
    var topView:UIView!
    var allDayView:UIScrollView!
    var allDayContentsView:UIView!
    var timelineScrollView:UIScrollView!
    var timelineContentsView:UIView!
    
    var holidayType:Int!
    var holidayCustom:[Bool]!

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        width = frame.size.width
        timelineContentsHeight = timelineRowHeight * CGFloat(24)
        initTemplate()
    }
    
    func initTemplate() {
        topView = UIView(frame: CGRectMake(0, 0, width, allDayHeight))
        let image:UIImage = UIImage(named: "Border_Allday")!
        topView.backgroundColor = UIColor(patternImage: image)
        self.addSubview(topView)
        
        // AllDay ScrollView
        allDayView = UIScrollView(frame: CGRectMake(allDayPrefixWidth, 0, width - allDayPrefixWidth, allDayHeight))
        topView.addSubview(allDayView)
        
        // AllDay ContentsView
        allDayContentsView = UIView(frame: CGRectMake(0, 0, allDayView.bounds.size.width, allDayHeight))
        
        
        // タイムライン部分
        let timelinePosY = allDayHeight;
        let timelineHeight = self.frame.size.height - allDayHeight
        
        timelineScrollView = UIScrollView(frame: CGRectMake(0, timelinePosY, width, timelineHeight))
        timelineScrollView.contentSize = CGSizeMake(width, timelineRowHeight * 24)
        self.addSubview(timelineScrollView)
        
        // 罫線画像準備
        let resolution:DisplayDiagonal = DeviceManager.getDisplayDiagonal()
        let imageRuleName:NSString = "Rule_Day_" + (resolution.rawValue as String)
        let imageRule:UIImage = UIImage(named: imageRuleName as String)!
        
        // コンテンツ生成（24時間分）
        timelineContentsView = UIView(frame: CGRectMake(0, 0, width, timelineContentsHeight))
        timelineContentsView.backgroundColor = UIColor(patternImage: imageRule) // 一列分の背景を自動的に繰り返させる
        timelineScrollView.addSubview(timelineContentsView)
        
        // 時間ラベル・背景画像マッピング
        for (var i = 0; i < 24; i++) {
            // 00:00
            let labelHour:UILabel = UILabel(frame: CGRectMake(4.0, 60.0 * CGFloat(i), timelineContentsHourWidth, 20))
            labelHour.textColor = UIColor.darkGrayColor()
            labelHour.font = UIFont.systemFontOfSize(14)
            let str:NSString = "\(i):00"
            labelHour.text = str as String
            timelineContentsView.addSubview(labelHour)
        }
    }
    
    override func cleanup() {
        var subViews:[UIView] = self.subviews 
        for view in subViews {
            if view.tag == cleanupTergetTag {
                view.removeFromSuperview()
            }
        }
        // TopViewの中を全てクリーンアップ（変数使い回し）
        subViews = topView.subviews 
        for view in subViews {
            if view.tag == cleanupTergetTag {
                view.removeFromSuperview()
            }
        }
        // AlldaysViewの赤を全てクリーンアップ
        subViews = self.allDayContentsView.subviews 
        for view in subViews {
            view.removeFromSuperview()
        }
        // TL 
        subViews = self.timelineContentsView.subviews as! [UIButton]
        for view in subViews {
            if view.tag == cleanupTergetTag {
                view.removeFromSuperview()
            }
        }
        
    }
    
    func setContents(date:NSDate, events:[EKEvent]) {
        // 休日選択
        holidayType = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyHolidayType.rawValue, defaultValue: HolidayType.Default.rawValue)
        holidayCustom = UDWrapper.getArray(UDWrapperKey.UDWrapperKeyHolidayCustom.rawValue, defaultValue: Holiday.getDefaultCustom()) as! [Bool]
        
        cleanup()
        setDate(date)
        setData(date, events: events)
        
        let today:NSDate = NSDate()
        //let today:NSDate = NSDate.create(year: 2015, month: 4, day: 10, hour: 22, minute: 0, second: 0)! // DEBUG:
        setPointer(today) // 最上部
    }
    
    //　日付・週・六曜を表示
    func setDate(date:NSDate) {
        let weekday:Int = CalendarUtil.getWeekday(date)
        var dayColor:UIColor = ColorManager.getDayColor()
        var weekColor:UIColor = ColorManager.getWeekColor()
        var rokuyouColor:UIColor = ColorManager.getRokuyouColor()
        
        if holidayType == HolidayType.Custom.rawValue {
            if (holidayCustom[ weekday - 1 ] == true) {
                dayColor = ColorManager.getHolidayColor()
                weekColor = ColorManager.getHolidayColor()
                rokuyouColor = ColorManager.getHolidayColor()
            }
        } else {
            if weekday == 1 {
                dayColor = ColorManager.getSundayColor()
                weekColor = ColorManager.getSundayColor()
                rokuyouColor = ColorManager.getSundayColor()
            } else if weekday == 7 {
                dayColor = ColorManager.getSaturdayColor()
                weekColor = ColorManager.getSaturdayColor()
                rokuyouColor = ColorManager.getSaturdayColor()
            }
        }
        
        renderDay(date.day, color: dayColor)
        renderWeek(date, color: weekColor)

        let rokuyouVisible = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyRokuyou.rawValue, defaultValue: true)
        if (rokuyouVisible) {
            renderRokuyou(date.year, month: date.month, day: date.day, color:rokuyouColor)
        }
        
        // イベント追加フォーム表示用ボタン（透過）
        renderEventAddButtonToTL(date)
    }
    
    func setPointer(date:NSDate) {
        let pointerWidth:CGFloat        = 12.0
        let pointerHeight:CGFloat       = 12.0
        let pointerLineHeight:CGFloat   = 1.0
        
        // Theme Color
        let themeId:String = UDWrapper.getString(UDWrapperKey.UDWrapperKeyTheme.rawValue, defaultValue:"Theme_01")!
        var themeData:ThemeData!
        if (themeId.hasPrefix("Custom")) {
            themeData = ThemeDataUtil.getCustomData()
        } else {
            themeData = ThemeDataUtil.getThemeById(themeId)
        }
        
        let x:CGFloat = timelineContentsHourWidth
        let y:CGFloat = CGFloat(date.hour) * 60.0 + CGFloat(date.minute) // 指定の時間より1時間まえのキリのよい時間
        
        var imagePointer:UIImage = UIImage(named: "Pointer")!
        imagePointer = imagePointer.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let pointerView:UIImageView = UIImageView(image: imagePointer)
        pointerView.tag = cleanupTergetTag
        pointerView.tintColor = UIColor(hexString: themeData.navBg, alpha: 0.8)
        
        var imagePointerLine = UIImage(named: "Pointer_Line")!
        imagePointerLine = imagePointerLine.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let pointerLineView = UIImageView(image: imagePointerLine)
        pointerLineView.tag = cleanupTergetTag
        pointerLineView.tintColor = UIColor(hexString: themeData.navBg, alpha: 0.8)

        pointerView.frame = CGRectMake(x - pointerWidth, y - (pointerHeight / 2), pointerWidth, pointerHeight)
        // - 1 少しかぶせる
        pointerLineView.frame = CGRectMake(timelineContentsHourWidth - 1, y - (pointerLineHeight / 2), width - timelineContentsHourWidth, pointerLineHeight)
        
        timelineContentsView.addSubview(pointerView)
        timelineContentsView.addSubview(pointerLineView)
        
        // Scroll Offset
        let timelineHeight = self.frame.size.height - allDayHeight
        var scrollOffsetY:CGFloat = y - (60 + CGFloat(date.minute)) // 上に1時間分のマージンを残した位置
        if (scrollOffsetY < 0) {
            scrollOffsetY = 0 // 0時台の場合には、0位置
        } else if (timelineContentsHeight - timelineHeight < scrollOffsetY) {
            scrollOffsetY = timelineContentsHeight - timelineHeight // スクロール内のコンテンツ高さから、表示高さを引いた位置
        }
        timelineScrollView.contentOffset = CGPointMake(0, scrollOffsetY)
    }
    
    func setData(date:NSDate, events:[EKEvent]) {
        var term:[Int] = [Int](count: 48, repeatedValue: 0)
        var tlPos:[Int] = [Int](count: 48, repeatedValue: 0)

        var allDayEvents:[EKEvent] = []
        var tlEvents:[EKEvent] = []
        
        // 終日、タイムラインイベントに分ける
        for event in events {
            if (event.allDay) {
                allDayEvents.append(event)
            } else {
                tlEvents.append(event)
                // 一度すべてのイベントの被り具合を走査
                var indexes:[Int] = EventUtil.getTermIndexes(date, start: event.startDate, end: event.endDate)
                for (var i = 0; i < indexes.count; i++) {
                    term[ indexes[i] ] = term[ indexes[i] ] + 1
                }
            }
        }
        
        // 終日
        renderEventAllDay(allDayEvents)
        
        // タイムライン
        for (_, event) in tlEvents.enumerate() {
            print("TL Event Title : \(event.title)")
            let duplicateCount:Int = EventUtil.getDuplicateEventCount(date, start: event.startDate, end: event.endDate, termList: term)
            print("Duplicate Count : \(duplicateCount)")
            var indexes:[Int] = EventUtil.getTermIndexes(date , start: event.startDate, end: event.endDate)
            
            // 開始時間帯（1コマ）の開始位置を取得
            let pos:Int = tlPos[ indexes[0] ]
            print("Pos : \(pos)")
            let eventWidth:CGFloat = (width - (timelineContentsHourWidth)) / CGFloat(duplicateCount)
            
            // 一時間の長さはちょうど、高さ60になっている
            // 2015-03-02 08:30:00 +0000
            let posX:CGFloat = timelineContentsHourWidth + (eventWidth * CGFloat(pos));
            let posY:CGFloat = CGFloat(indexes[0]) * 30.0
            let height:CGFloat = CGFloat(indexes.count) * 30.0
//            println("\(posX)  \(posY)  \(eventWidth)  \(height)")
            
            renderEvent(posX, y: posY, width: eventWidth, height: height, event: event)

            // 時間帯の被り具合を更新
            for (var i = 0; i < indexes.count; i++) {
                tlPos[ indexes[i] ] = tlPos[ indexes[i] ] + 1
            }
        }
    }
    
    //-- Notification Center (POST) --//
    func onAddEventButton(sender: EXUIButton) {
        let date:NSDate = sender.date
//        println("Date : \(date.year)/\(date.month)/\(date.day)/ \(date.hour)/\(date.minute)/")
        NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameEventAddDayTL(),
            object: nil,
            userInfo: ["date": date])
    }
    
    func onEditEventButtonAll(sender: EXUIButton) {
        let event:EKEvent = sender.event
        NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameEventEdit(),
            object: nil,
            userInfo: ["event": event])
    }
    
    func onEditEventButton(sender: EXUIButton){
        let event:EKEvent = sender.event
        NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameEventEdit(),
            object: nil,
            userInfo: ["event": event])
    }
    
    //-- Render --//
    private func renderEvent(x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat, event:EKEvent) {
        let eventMarginRight:CGFloat    = 1.0
        let eventMarginBottom:CGFloat   = 1.0
        let timeHeight:CGFloat          = 15.0
        let timeMarginLeft:CGFloat      = 2.0
        let titleHeight:CGFloat         = 15.0
        let titleMarginLeft:CGFloat     = 2.0
        
        let eventWidth:CGFloat = width - eventMarginRight
        let eventHeight:CGFloat = height - eventMarginBottom
        
        let bgView:EXUIButton = EXUIButton(frame: CGRectMake(x, y, eventWidth, eventHeight))
        bgView.event = event
        bgView.tag = cleanupTergetTag
        bgView.backgroundColor = UIColor(hexString: event.calendar.CGColor.hexString!, alpha: 0.3)
        if event.calendar.allowsContentModifications {
            bgView.addTarget(self, action: "onEditEventButton:", forControlEvents: .TouchUpInside)
        }
        
        let barView:UIView = UIView(frame: CGRectMake(0, 0, 1, eventHeight))
        barView.backgroundColor = UIColor(CGColor: event.calendar.CGColor)
        bgView.addSubview(barView)
        
        // 同一日、連日で表示を変える
        var startStr:String = ""
        var endStr:String   = ""
        if (event.startDate.year == event.endDate.year && event.startDate.month == event.endDate.month && event.startDate.day == event.endDate.day) {
            startStr = "\(event.startDate.hour):" + (NSString(format: "%02d", event.startDate.minute) as String)
            endStr   = "\(event.endDate.hour):" + (NSString(format: "%02d", event.endDate.minute) as String)
        } else {
            startStr = "\(event.startDate.month)/\(event.startDate.day) \(event.startDate.hour):" + (NSString(format: "%02d", event.startDate.minute) as String)
            endStr   = "\(event.endDate.month)/\(event.endDate.day) \(event.endDate.hour):" + (NSString(format: "%02d", event.endDate.minute) as String)
        }
        
        let labelTime:UILabel = UILabel(frame: CGRectMake(timeMarginLeft, 0, eventWidth, timeHeight))
        labelTime.text = startStr + " - " + endStr
        labelTime.font = UIFont.boldSystemFontOfSize(titleFontSize)
        labelTime.textColor = UIColor.darkGrayColor()
        bgView.addSubview(labelTime)
        
        let labelTitle:UILabel = UILabel(frame: CGRectMake(titleMarginLeft, timeHeight, eventWidth, titleHeight))
        labelTitle.text = event.title
        labelTitle.textColor = UIColor.darkGrayColor()
        labelTitle.font = UIFont.boldSystemFontOfSize(titleFontSize)
        bgView.addSubview(labelTitle)

        timelineContentsView.addSubview(bgView)
    }
    
    private func renderEventAllDay(events:[EKEvent]) {
        let fontSize:CGFloat    = 14.0
        
        let marginTop:CGFloat   = 0.5
        let marginLeft:CGFloat  = 0.0
        let marginRight:CGFloat = 4.0
        
        let eventWidth:CGFloat = width - (allDayPrefixWidth + marginLeft + marginRight)
        let eventHeight:CGFloat = 24.0
        
        let posX:CGFloat = marginLeft
        var posY:CGFloat = marginTop

        let contentsHeight:CGFloat = (marginTop + eventHeight) * (CGFloat)(events.count)

        allDayContentsView.frame = CGRectMake(0, 0, allDayView.bounds.size.width, contentsHeight)
        allDayView.contentSize = CGSizeMake(allDayView.frame.size.width, contentsHeight)
        allDayView.addSubview(allDayContentsView)

        for (_, event) in events.enumerate() {
            let button:EXUIButton = EXUIButton(frame: CGRectMake(posX, posY, eventWidth, eventHeight))
            button.event = event
            button.tag = cleanupTergetTag
            button.backgroundColor = UIColor(CGColor: event.calendar.CGColor)
            button.layer.masksToBounds  = true
            button.layer.cornerRadius = 2.0
            button.titleLabel?.font = UIFont.systemFontOfSize(fontSize)
            button.setTitle("  " + event.title, forState: UIControlState.Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.contentHorizontalAlignment = .Left
            if event.calendar.allowsContentModifications {
                button.addTarget(self, action: "onEditEventButtonAll:", forControlEvents: .TouchUpInside)
            }
            allDayContentsView.addSubview(button)
            posY = posY + marginTop + eventHeight
        }
    }

    private func renderDay(day:Int, color:UIColor) {
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, allDayPrefixWidth, 30))
        label.font = UIFont.boldSystemFontOfSize(dayFontSize)
        label.textColor = color
        label.textAlignment = NSTextAlignment.Center
        label.text = "\(day)"
        label.tag = cleanupTergetTag
        topView.addSubview(label)
    }
    
    private func renderWeek(date:NSDate, color:UIColor) {
        let label:UILabel = UILabel(frame: CGRectMake(0, 30, allDayPrefixWidth, 16))
        label.font = UIFont.systemFontOfSize(weekFontSize)
        label.textColor = color
        label.textAlignment = NSTextAlignment.Center
        label.text = CalendarUtil.getWeekdayStringFull(date)
        label.tag = cleanupTergetTag
        topView.addSubview(label)
    }
    
    private func renderRokuyou(year:Int, month:Int, day:Int, color:UIColor) {
        let rokuyou:Rokuyou = Rokuyou(year: "\(year)")
        let str:String = rokuyou.getRokuyou("\(year)/\(month)/\(day)") // フォーマット:2015/3/15
        let label:UILabel = UILabel(frame: CGRectMake(0, 45, allDayPrefixWidth, 16))
        label.font = UIFont.systemFontOfSize(rokuyouFontSize)
        label.textColor = color
        label.textAlignment = NSTextAlignment.Center
        label.text = str
        label.tag = cleanupTergetTag
        topView.addSubview(label)
    }
    
    // TL内のイベント追加ボタン
    private func renderEventAddButtonToTL(date:NSDate) {
        let tlHeight:CGFloat = 60
        
        let x:CGFloat = timelineContentsHourWidth
        let w:CGFloat = width - timelineContentsHourWidth
        let h:CGFloat = tlHeight
        
        // 24h
        for (var i = 0; i < 24; i++) {
            let newDate = NSDate.create(year: date.year,
                month: date.month,
                day: date.day,
                hour: i,
                minute: 0,
                second: 0)

            let button:EXUIButton = EXUIButton(frame: CGRectMake(x, tlHeight * CGFloat(i), w, h))
            button.addTarget(self, action: "onAddEventButton:", forControlEvents: .TouchUpInside)
            button.tag = cleanupTergetTag
            button.date = newDate
            timelineContentsView.addSubview(button)
        }
    }
}
