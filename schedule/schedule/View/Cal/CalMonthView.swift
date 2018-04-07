//
//  CalMonthView.swift
//

import UIKit
import EventKit

class CalMonthView: CalView {
    var gridWidth, gridHeight:CGFloat!
    
    let dayFontSize:CGFloat     = 14.0
    let rokuyouFontSize:CGFloat = 11.0
    
    // GridWidthの左寄せ
    let dayHeight:CGFloat           = 16.0
    let dayMarginLeft:CGFloat       = 3.0
    
    // GridWidthの右寄せ
    let rokuyouHeight:CGFloat       = 16.0
    let rokuyouMarginRight:CGFloat  = 2.0
    
    let eventHeight:CGFloat         = 16.0
    
    var rokuyouVisible:Bool = true
    var startWeekday:Int!
    var weekNum:Int!
    
    var holidayType:Int!
    var holidayCustom:[Bool]!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    func setContents(year:Int, month:Int, list:[[EKEvent]]) {
        // Load Setting
        rokuyouVisible = UDWrapper.getBool(UDWrapperKey.UDWrapperKeyRokuyou.rawValue, defaultValue: true)
        startWeekday = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyStartWeekday.rawValue, defaultValue: StartWeek.Sunday.rawValue)
        holidayType = UDWrapper.getInt(UDWrapperKey.UDWrapperKeyHolidayType.rawValue, defaultValue: HolidayType.Default.rawValue)
        holidayCustom = UDWrapper.getArray(UDWrapperKey.UDWrapperKeyHolidayCustom.rawValue, defaultValue: Holiday.getDefaultCustom()) as! [Bool]
        
        // 何週間あるか取得
        weekNum = CalendarUtilMonth.getWeekNum(year, month: month, startWeek: startWeekday)
        
        gridWidth = (CGFloat)((Int)(frame.size.width / 7))                  // 固定
        gridHeight = (CGFloat)((Int)(frame.size.height / CGFloat(weekNum))) // 可変

        cleanup()
        setDate(year, month: month)
        setData(year, month: month, list: list)
    }
    
    // カレンダーに必要な日付とかのみ表示する
    func setDate(year:Int, month:Int) {
        
        // 当月判断
        var thisMonth:Bool = false
        let thisMonthDate:NSDate = NSDate()
        if thisMonthDate.year == year && thisMonthDate.month == month {
            thisMonth = true
        }
        
        
        // 背景画像セット
        let resolution:DisplayDiagonal = DeviceManager.getDisplayDiagonal()
        let imageName:NSString = "Rule_Month_" + (resolution.rawValue as String) + "_\(weekNum)"
        print("Image Name : \(imageName)")
        let image:UIImage = UIImage(named: imageName as String)!
        self.backgroundColor = UIColor(patternImage: image)

        var list:[NSDate] = CalendarUtilMonth.getMonthList(year, month:month)

        // 月初の曜日を取得する
        let beginWeekday:Int = CalendarUtil.getWeekday(list[0])
        
      
        var threshold:Int = beginWeekday - startWeekday
        if (threshold < 0) {
            // thresholdはマイナス値
            threshold = 7 + threshold
        }
        
        // 月の日数を取得
//        var last:Int = CalendarUtilMonth.getLastDay(year, month: month)!
        
        var posX:CGFloat = 0.0
        var posY:CGFloat = 0.0
        var index:Int = 0
        var end:Bool = false
        
        for_j: for (var j = 0; j < weekNum; j++) {
            for (var i = 0; i < 7; i++) {
                if ((j == 0) && (i < threshold)) {
                    // 月初スキップ
                    renderOutGrid(weekNum, row: j, col: i, width: gridWidth, height: gridHeight)
                } else {
                    if (end == false) {
                        let date:NSDate = list[index]
                        
                        // 今日
                        if (thisMonth && thisMonthDate.day == date.day) {
                            renderTodayGrid(j, col: i, width: gridWidth, height: gridHeight)
                        }

                        let weekday:Int = CalendarUtil.getWeekday(date) // 曜日
                    
                        // Color
                        var dayColor:UIColor = ColorManager.getDayColor()
                        var rokuyouColor:UIColor = ColorManager.getRokuyouColor()
                        
                        if holidayType == HolidayType.Custom.rawValue {
                            if (holidayCustom[ weekday - 1 ] == true) {
                                dayColor = ColorManager.getHolidayColor()
                                rokuyouColor = ColorManager.getHolidayColor()
                            }
                        } else {
                            if weekday == 1 {
                                dayColor = ColorManager.getSundayColor()
                                rokuyouColor = ColorManager.getSundayColor()
                            } else if weekday == 7 {
                                dayColor = ColorManager.getSaturdayColor()
                                rokuyouColor = ColorManager.getSaturdayColor()
                            }
                        }
                    
                        posX = gridWidth * CGFloat(i)
                        posY = gridHeight * CGFloat(j)
                    
                        // 透明なボタンを用意する
                        let button:EXUIButton = EXUIButton(frame: CGRectMake(posX, posY, gridWidth, gridHeight))
                        button.addTarget(self, action: "onButton:", forControlEvents: .TouchUpInside)
                        button.tag = cleanupTergetTag
                        button.date = date
                        self.addSubview(button)

                        renderDay(date.day, posX:posX, posY:posY, color:dayColor)
                        
                        if (rokuyouVisible) {
                            renderRokuyou(date.year, month: date.month, day: date.day, posX: posX, posY: posY, color: rokuyouColor)
                        }
                    } else {
                        //break for_j
                        renderOutGrid(weekNum, row: j, col: i, width: gridWidth, height: gridHeight)
                    }

                    if (index < list.count - 1) {
                        index++
                    } else {

                        end = true // あと判断
                    }
                }
            }
        }
    }
    
    func setData(year:Int, month:Int, list:[[EKEvent]]) {
        // 月初の曜日を取得する
        let begin:NSDate = NSDate.create(year: year, month: month, day: 1, hour: 0, minute: 0, second: 0)!
        let beginWeekday:Int = CalendarUtil.getWeekday(begin)
        
        // 月の日数を取得
//        var last:Int = CalendarUtilMonth.getLastDay(year, month: month)!
        
        var x:CGFloat = 0.0
        var y:CGFloat = 0.0
        var index:Int = 0
        
        // 表示件数
        let displayNum:Int = (Int)(floor((gridHeight - dayHeight) / eventHeight))

        var threshold:Int = beginWeekday - startWeekday
        if (threshold < 0) {
            // thresholdはマイナス値
            threshold = 7 + threshold
        }
        
        for_j: for (var j = 0; j < weekNum ; j++) {
            for (var i = 0; i < 7; i++) {
                let baseLine:CGFloat = gridHeight * CGFloat(j) + dayHeight

                if ((j == 0) && (i < threshold)) {
                    // 月初スキップ
                } else {
                    let events:[EKEvent] = list[index]
                    for (e, event) in events.enumerate() {
                        if (e < displayNum) {
                            x = gridWidth * CGFloat(i)
                            y = baseLine + (eventHeight * CGFloat(e))
                            renderEvent(event, posX: x, posY: y)
                        }
                    }
                    // More Events
                    if (events.count > displayNum) {
                        renderEventMore(events.count - displayNum, weekNum: weekNum, row: j, col: i, width: gridWidth, height: gridHeight)
                    }
                    
                    if (index < list.count - 1) {
                        index++
                    } else {
                        break for_j
                    }
                }
            }
        }
    }
    
    //-- Action --//
    func onButton(sender: EXUIButton){
        let date:NSDate = sender.date as NSDate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.switchCenterView(CenterViewType.CenterViewTypeCalDay, param: ["date" : date])
    }
    
    //-- Rendaring --//
    private func renderEvent(event:EKEvent, posX:CGFloat, posY:CGFloat) {
        let fontSize:CGFloat       = 10.0
        
        var x:CGFloat = posX
        var y:CGFloat = posY
        
        var width:CGFloat!
        var height:CGFloat!

        let marginLeft:CGFloat      = 0.5
        let marginRight:CGFloat     = 1.0
        let marginTopAllday:CGFloat = 0.5

        x = x + marginLeft
        width = gridWidth - (marginLeft + marginRight)
        height = eventHeight
        if (event.allDay) {
            height = eventHeight - marginTopAllday
            y = posY + marginTopAllday
        }
        
        let label = UILabel(frame: CGRectMake(x, y, width, height))
        label.font = UIFont.systemFontOfSize(fontSize)
        label.tag = cleanupTergetTag
        
        if (event.allDay) {
            label.text = " " + event.title + " "
            label.backgroundColor = UIColor(CGColor: event.calendar.CGColor)
            label.textColor = UIColor.whiteColor()
            label.layer.masksToBounds  = true
            label.layer.cornerRadius = 2.0
        } else {
            label.text = "\(event.title)"
            label.textColor = UIColor(CGColor: event.calendar.CGColor)
        }
        self.addSubview(label)
    }
    
    // More Events
    private func renderEventMore(count:Int, weekNum:Int, row:Int, col:Int, width:CGFloat, height:CGFloat) {
        let imageWidth:CGFloat = 20.0
        let imageHeight:CGFloat = 20.0
        let x:CGFloat = CGFloat(col) * width
        let y:CGFloat = CGFloat(row) * height
        var w:CGFloat = width
        var h:CGFloat = height
        if (row == weekNum - 1) {
            h = frame.size.height - (gridHeight * CGFloat(weekNum - 1))
        }
        if (col == 6) {
            w = frame.size.width - (width * 6)
        }

        // Theme Color
        let themeId:String = UDWrapper.getString(UDWrapperKey.UDWrapperKeyTheme.rawValue, defaultValue:"Theme_01")!
        var themeData:ThemeData!
        if (themeId.hasPrefix("Custom")) {
            themeData = ThemeDataUtil.getCustomData()
        } else {
            themeData = ThemeDataUtil.getThemeById(themeId)
        }
        
        var image:UIImage = UIImage(named: "More_Month")!
        image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let imageView:UIImageView = UIImageView(image: image)
        imageView.tag = cleanupTergetTag
        imageView.tintColor = UIColor(hexString: themeData.navBg, alpha: 1.0)
        imageView.frame = CGRectMake(x + w - imageWidth, y + h - imageHeight, imageWidth, imageHeight)
        self.addSubview(imageView)
        
        let labelWidth:CGFloat = imageWidth / 2
        let labelHeight:CGFloat = imageHeight / 2
        
        let label = UILabel(frame: CGRectMake(x + w - labelWidth, y + h - labelHeight, labelWidth, labelHeight))
        label.font = UIFont.systemFontOfSize(8.0)
        label.tag = cleanupTergetTag
        label.text = "\(count)"
        label.textAlignment = .Center
        label.textColor = UIColor(hexString: themeData.navText, alpha: 1.0)
        self.addSubview(label)
    }
    
    // 日付表示
    private func renderDay(day:Int, posX:CGFloat, posY:CGFloat, color:UIColor) {
        // 左寄せで左マージン
        let x:CGFloat = posX + dayMarginLeft
        let width:CGFloat = gridWidth - dayMarginLeft

        let labelDay:UILabel = UILabel(frame: CGRectMake(x, posY, width, dayHeight))
        labelDay.text = "\(day)"
        labelDay.font = UIFont.boldSystemFontOfSize(dayFontSize)
        labelDay.textColor = color
        labelDay.tag = cleanupTergetTag
        self.addSubview(labelDay)
    }
    
    // 六曜表示
    private func renderRokuyou(year:Int, month:Int, day:Int, posX:CGFloat, posY:CGFloat, color:UIColor) {
        // 右寄せで右マージン
        let width = gridWidth - rokuyouMarginRight

        let rokuyou:Rokuyou = Rokuyou(year: "\(year)")
        let rokuyouStr:String = rokuyou.getRokuyou("\(year)/\(month)/\(day)") // フォーマット:2015/3/15
        let labelRokuyou:UILabel = UILabel(frame: CGRectMake(posX, posY, width, rokuyouHeight))
        labelRokuyou.font = UIFont.systemFontOfSize(rokuyouFontSize)
        labelRokuyou.textColor = color
        labelRokuyou.textAlignment = NSTextAlignment.Right
        labelRokuyou.text = rokuyouStr
        labelRokuyou.tag = cleanupTergetTag
        self.addSubview(labelRokuyou)
    }
    
    // 範囲外のグリッドを塗りつぶす
    // 5列目と7行目の場合、セル自体が割りきれてない可能性があるので調整する
    private func renderOutGrid(weekNum:Int, row:Int, col:Int, width:CGFloat, height:CGFloat) {
        let x:CGFloat = CGFloat(col) * width
        let y:CGFloat = CGFloat(row) * height
        var w:CGFloat = width
        var h:CGFloat = height
        if (row == weekNum - 1) {
            h = frame.size.height - (gridHeight * CGFloat(weekNum - 1))
        }
        if (col == 6) {
            w = frame.size.width - (width * 6)
        }
        let view:UIView = UIView(frame: CGRectMake(x, y, w, h))
        view.tag = cleanupTergetTag
        view.backgroundColor = ColorManager.getCalendarOutGrid()
        self.addSubview(view)
    }
    
    // 今日
    private func renderTodayGrid(row:Int, col:Int, width:CGFloat, height:CGFloat) {
        // テーマ色取得
        let themeId:String = UDWrapper.getString(UDWrapperKey.UDWrapperKeyTheme.rawValue, defaultValue:"Theme_01")!
        var themeData:ThemeData!
        if (themeId.hasPrefix("Custom")) {
            themeData = ThemeDataUtil.getCustomData()
        } else {
            themeData = ThemeDataUtil.getThemeById(themeId)
        }

        let x:CGFloat = CGFloat(col) * width
        let y:CGFloat = CGFloat(row) * height
        var w:CGFloat = width
        var h:CGFloat = height
        if (row == weekNum - 1) {
            h = frame.size.height - (gridHeight * CGFloat(weekNum - 1))
        }
        if (col == 6) {
            w = frame.size.width - (width * 6)
        }
        let view:UIView = UIView(frame: CGRectMake(x, y, w, h))
        view.tag = cleanupTergetTag
        view.backgroundColor = UIColor(hexString: themeData.navBg, alpha: 0.2)
        self.addSubview(view)
    }
}
