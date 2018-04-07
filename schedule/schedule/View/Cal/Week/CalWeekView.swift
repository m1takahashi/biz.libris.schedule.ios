//
//  CalWeekWeekView.swift
//

import UIKit
import EventKit

class CalWeekView: CalView {
    var width:CGFloat!
    var height:CGFloat!
    
    var gridWidth:CGFloat!
    var gridHeightLeft:CGFloat!
    var gridHeightRight:CGFloat!
    
    let dayFontSize:CGFloat     = 18.0
    let weekFontSize:CGFloat    = 12.0
    let rokuyouFontSize:CGFloat = 12.0
    
    let dayWidth:CGFloat        = 30.0
    let dayHeight:CGFloat       = 20.0
    let weekWidth:CGFloat       = 80.0
    let weekHeight:CGFloat      = 20.0
    let rokuyouWidth:CGFloat    = 30.0
    let rokuyouHeight:CGFloat   = 20.0
    let eventHeight:CGFloat     = 20.0

    let marginTop:CGFloat       = 0.0
    let marginRight:CGFloat     = 10.0
    let marginBottom:CGFloat    = 2.0
    let marginLeft:CGFloat      = 0.0
    
    var holidayType:Int!
    var holidayCustom:[Bool]!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame:frame)
        
        width   = frame.size.width
        height  = frame.size.height
        
        // 背景画像と合わせるために切り捨てる
        gridWidth       = width / 2
        gridHeightLeft  = (CGFloat)((Int)(height / 3.0))
        gridHeightRight = (CGFloat)((Int)(height / 4.0))

        let resolution:DisplayDiagonal = DeviceManager.getDisplayDiagonal()
        let imageName:NSString = "Rule_Week_" + (resolution.rawValue as String)
        let image:UIImage = UIImage(named: imageName as String)!
        self.backgroundColor = UIColor(patternImage: image)
    }
    
    // date: 週の開始日
    func setContents(date:NSDate, list:[[EKEvent]]) {
        // 休日選択
        holidayType = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyHolidayType.rawValue, defaultValue: HolidayType.Default.rawValue)
        holidayCustom = UDWrapper.getArray(UDWrapperKey.UDWrapperKeyHolidayCustom.rawValue, defaultValue: Holiday.getDefaultCustom()) as! [Bool]
        
        cleanup()
        setDate(date)
        setData(date, list: list)
    }
    
    func setDate(date:NSDate) {
        let rokuyouVisible = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyRokuyou.rawValue, defaultValue: true)

        let today:NSDate = NSDate()
        var list:[NSDate] = CalendarUtilWeek.getWeekList(date)
        
        var posX:CGFloat = marginLeft
        var posY:CGFloat = marginRight
        var posRightX:CGFloat = gridWidth
        
//        var isRightGrid:Bool = false
        for (var i = 0; i < 7; i++) {
            let tmpDate = list[i]
            
            //　今日背景
            if (today.year == tmpDate.year && today.month == tmpDate.month && today.day == tmpDate.day) {
                renderTodayGrid(i)
            }
            
            // イベント追加ボタン（透過）
            renderEventAddButton(i, date: tmpDate)
            
            if (i < 3) {
                posX = marginLeft
                posY = gridHeightLeft * CGFloat(i) + marginTop
                posRightX = gridWidth - marginRight
            } else {
                posX = gridWidth + marginLeft
                posY = gridHeightRight * CGFloat(i - 3) + marginTop
                posRightX = width - marginRight
//                isRightGrid = true
            }

            let weekday:Int = CalendarUtil.getWeekday(tmpDate)
            
            // Color
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
            
            renderDay(tmpDate.day, posX: posX, posY: posY, color: dayColor)
            renderWeek(tmpDate, posX: posX + dayWidth, posY: posY, color: weekColor)
            if (rokuyouVisible) {
                renderRokuyou(tmpDate.year, month: tmpDate.month, day: tmpDate.day, posX: posRightX - rokuyouWidth, posY: posY, color: rokuyouColor)
            }
        }
    }
    
    func setData(date:NSDate, list:[[EKEvent]]) {
        // 一週間分の日付一覧
        var dates:[NSDate] = CalendarUtilWeek.getWeekList(date)
        
        var displayNum:Int = 0
        for (var j = 0; j < list.count; j++) {
            if j < 3 {
                displayNum = (Int)(floor((gridHeightLeft - dayHeight) / eventHeight))
            } else {
                displayNum = (Int)(floor((gridHeightRight - dayHeight) / eventHeight))
            }
            // Events
            for (var i = 0; i < list[j].count; i++) {
                if (i < displayNum) {
                    renderEvent(dates[j], grid: j, count: i, event: list[j][i])
                } else {
                    break;
                }
            }
            // More Events
            if (list[j].count > displayNum) {
                let event:EKEvent = list[j][0] // あるハズ
                let date:NSDate = event.startDate
                renderEventMore(date, grid:j, count: list[j].count - displayNum)
            }
        }
    }
    
    //-- Action --//
    func onAddEventButton(sender: EXUIButton) {
        let date:NSDate = sender.date as NSDate
        NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameEventAddWeekGrid(),
            object: nil,
            userInfo: ["date": date])
    }
    
    func onEditEventButton(sender: EXUIButton) {
        let event:EKEvent = sender.event as EKEvent
        NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameEventEdit(),
            object: nil,
            userInfo: ["event": event])
    }
    
    func onMoveToDayButton(sender: EXUIButton) {
        let date:NSDate = sender.date as NSDate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.switchCenterView(CenterViewType.CenterViewTypeCalDay, param: ["date" : date])
    }
    
    //-- Render --//
    private func renderEvent(date:NSDate, grid:Int, count:Int, event:EKEvent) {
        let height:CGFloat          = 20.0
        let marginRight:CGFloat     = 2.0
        let marginLeft:CGFloat      = 2.0
        let marginAllday:CGFloat    = 1.0 // 終日の場合には背景がつながらないように調整
        let fontSize:CGFloat        = 13.0
        
        var posX:CGFloat!
        var posY:CGFloat!
        
        let width:CGFloat  = gridWidth - (marginLeft + marginRight)
        
        if (grid < 3) {
            // Left Grid
            posX = marginLeft
            posY = (gridHeightLeft * CGFloat(grid)) + (height * CGFloat(count)) + dayHeight
        } else {
            // Right Grid
            posX = gridWidth + marginLeft
            posY = gridHeightRight * CGFloat(grid - 3) + (height * CGFloat(count)) + dayHeight
        }
        
        var btnHeight:CGFloat = height
        if (event.allDay) {
            posY = posY + marginAllday
            btnHeight = height - marginAllday
        }
        
        let button:EXUIButton = EXUIButton(frame: CGRectMake(posX, posY, width, btnHeight))
        if event.calendar.allowsContentModifications {
            button.addTarget(self, action: "onEditEventButton:", forControlEvents: .TouchUpInside)
        }
        button.tag = cleanupTergetTag
        button.contentHorizontalAlignment = .Left
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(fontSize)
        
        // HH:MM Title
        var title:String = String(format:"%d:%02d", event.startDate.hour , event.startDate.minute) + " " + event.title
        var titleColor:UIColor = UIColor(CGColor: event.calendar.CGColor)
        
        if (event.allDay) {
            // Title
            title = " " + event.title
            titleColor = UIColor.whiteColor()
            button.backgroundColor = UIColor(CGColor: event.calendar.CGColor)
            button.layer.masksToBounds  = true
            button.layer.cornerRadius = 2.0
        } else {
            let termType:EventCalendarTermType = EventUtil.getTermType(date, event: event)
            switch (termType) {
            case .EventCalendarTermTypeStartDay:
                title = String(format:"%d:%02d - ", event.startDate.hour , event.startDate.minute) + " " + event.title
                break;
            case .EventCalendarTermTypeMiddleDay:
                title = "\(event.startDate.month)/\(event.startDate.day) - \(event.endDate.month)/\(event.endDate.day) " + event.title
                break;
            case .EventCalendarTermTypeEndDay:
                title = String(format:"- %d:%02d ", event.endDate.hour , event.endDate.minute) + " " + event.title
                break;
            default:
                break;
            }
        }
        
        button.event = event
        button.setTitle(title, forState: UIControlState.Normal)
        button.setTitleColor(titleColor, forState: UIControlState.Normal)

        self.addSubview(button)
    }
    
    // More Events
    private func renderEventMore(date:NSDate, grid:Int, count:Int) {
        let imageWidth:CGFloat  = 40.0
        let imageHeight:CGFloat = 40.0
    
        var x, y, w, h:CGFloat!
        
        if grid < 3 {
            x = 0
            y = gridHeightLeft * CGFloat(grid)
            w = gridWidth
            h = gridHeightLeft
            if (grid == 2) {
                h = height - gridHeightLeft * 2.0
            }
        } else {
            x = gridWidth
            y = gridHeightRight * CGFloat(grid - 3)
            w = gridWidth
            h = gridHeightRight
            if (grid == 6) {
                h = height - gridHeightRight * 3.0
            }
        }
        
        // Theme Color
        let themeId:String = UDWrapper.getString(UDWrapperKey.UDWrapperKeyTheme.rawValue, defaultValue:"Theme_01")!
        var themeData:ThemeData!
        if (themeId.hasPrefix("Custom")) {
            themeData = ThemeDataUtil.getCustomData()
        } else {
            themeData = ThemeDataUtil.getThemeById(themeId)
        }
        
        var image:UIImage = UIImage(named: "More_Week")!
        image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        let button:EXUIButton = EXUIButton(frame: CGRectMake(x + w - imageWidth, y + h - imageHeight, imageWidth, imageHeight))
        button.addTarget(self, action: "onMoveToDayButton:", forControlEvents: .TouchUpInside)
        button.tag = cleanupTergetTag
        button.date = date
        button.setImage(image, forState: .Normal)
        button.tintColor = UIColor(hexString: themeData.navBg, alpha: 0.6)
        self.addSubview(button)

        let labelWidth:CGFloat = imageWidth / 2
        let labelHeight:CGFloat = imageHeight / 2
        
        let label = UILabel(frame: CGRectMake(x + w - labelWidth, y + h - labelHeight, labelWidth, labelHeight))
        label.font = UIFont.boldSystemFontOfSize(14.0)
        label.tag = cleanupTergetTag
        label.text = "\(count)"
        label.textAlignment = .Center
        label.textColor = UIColor(hexString: themeData.navText, alpha: 1.0)
        self.addSubview(label)
    }
    
    // 日表示
    private func renderDay(day:Int, posX:CGFloat, posY:CGFloat, color:UIColor) {
        let labelDay = UILabel(frame: CGRectMake(posX, posY, dayWidth, dayHeight))
        labelDay.text = "\(day)"
        labelDay.textColor = color
        labelDay.font = UIFont.boldSystemFontOfSize(dayFontSize)
        labelDay.textAlignment = .Center;
        labelDay.tag = cleanupTergetTag
        self.addSubview(labelDay)
    }
    
    // 曜日表示
    private func renderWeek(date:NSDate, posX:CGFloat, posY:CGFloat, color:UIColor) {
        let labelWeek = UILabel(frame: CGRectMake(posX, posY, weekWidth, weekHeight))
        labelWeek.text = CalendarUtil.getWeekdayStringFull(date)
        labelWeek.textColor = color
        labelWeek.font = UIFont.systemFontOfSize(weekFontSize)
        labelWeek.textAlignment = .Left;
        labelWeek.tag = cleanupTergetTag
        self.addSubview(labelWeek)
    }
    
    // 六曜表示
    private func renderRokuyou(year:Int, month:Int, day:Int, posX:CGFloat, posY:CGFloat, color:UIColor) {
        let rokuyou:Rokuyou = Rokuyou(year: "\(year)")
        let rokuyouStr:String = rokuyou.getRokuyou("\(year)/\(month)/\(day)") // フォーマット:2015/3/15
        let labelRokuyou:UILabel = UILabel(frame: CGRectMake(posX, posY, rokuyouWidth, rokuyouHeight))
        labelRokuyou.font = UIFont.systemFontOfSize(rokuyouFontSize)
        labelRokuyou.textColor = color
        labelRokuyou.textAlignment = NSTextAlignment.Center
        labelRokuyou.text = rokuyouStr
        labelRokuyou.tag = cleanupTergetTag
        self.addSubview(labelRokuyou)
    }
    
    // 今日
    private func renderTodayGrid(pos:Int) {
        // Theme Color
        let themeId:String = UDWrapper.getString(UDWrapperKey.UDWrapperKeyTheme.rawValue, defaultValue:"Theme_01")!
        var themeData:ThemeData!
        if (themeId.hasPrefix("Custom")) {
            themeData = ThemeDataUtil.getCustomData()
        } else {
            themeData = ThemeDataUtil.getThemeById(themeId)
        }
        
        var x:CGFloat = 0.0
        var y:CGFloat = 0.0
        let w:CGFloat = gridWidth
        var h:CGFloat = gridHeightLeft

        // Position
        if (pos < 3) {
            y = gridHeightLeft * CGFloat(pos)
        } else {
            x = gridWidth
            y = gridHeightRight * CGFloat(pos - 3)
            h = gridHeightRight
        }
        
        // 一番下の隙間対策
        if (pos == 6) {
            h = height - gridHeightRight * CGFloat(3)
        } else if (pos == 2) {
            h = height - gridHeightLeft * CGFloat(2)
        }
        
        let view:UIView = UIView(frame: CGRectMake(x, y, w, h))
        view.backgroundColor = UIColor(hexString: themeData.navBg, alpha: 0.2)
        view.tag = cleanupTergetTag
        self.addSubview(view)
    }
    
    // グリッド内の追加ボタン
    private func renderEventAddButton(pos:Int, date:NSDate) {
        var x:CGFloat = 0.0
        var y:CGFloat = 0.0
        let w:CGFloat = gridWidth
        var h:CGFloat = gridHeightLeft
        
        // Position
        if (pos < 3) {
            y = gridHeightLeft * CGFloat(pos)
        } else {
            x = gridWidth
            y = gridHeightRight * CGFloat(pos - 3)
            h = gridHeightRight
        }
        
        // 一番下の隙間対策
        if (pos == 6) {
            h = height - gridHeightRight * CGFloat(3)
        } else if (pos == 2) {
            h = height - gridHeightLeft * CGFloat(2)
        }
        
        let button:EXUIButton = EXUIButton(frame: CGRectMake(x, y, w, h))
        button.addTarget(self, action: "onAddEventButton:", forControlEvents: .TouchUpInside)
        button.tag = cleanupTergetTag
        button.date = date
        self.addSubview(button)
    }
}
