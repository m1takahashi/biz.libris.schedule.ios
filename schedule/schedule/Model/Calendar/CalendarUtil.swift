//
//  CalenderUtil.swift
//  カレンダーユーティリティ（共通）
//  note:
//  http://qiita.com/kitanoow/items/65b1418527eabf31e45b
//

import UIKit

class CalendarUtil: NSObject {
    // 同一日か比較
    class func isSameDate(date1:NSDate, date2:NSDate) -> Bool {
        let calender = NSCalendar.currentCalendar()
        return calender.isDate(date1, inSameDayAsDate: date2)
    }
    
    // 曜日を数値（1:日曜日、2:月曜日）で取得
    class func getWeekday(date:NSDate) -> Int {
        let calender = NSCalendar.currentCalendar()
        let components = calender.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday], fromDate: date)
        let weekday = components.weekday
        return weekday
    }
    
    // 曜日を日本語文字で取得
    class func getWeekdayString(date:NSDate) -> String {
        let weekday:Int = CalendarUtil.getWeekday(date)
        var labels:[String] = CalendarUtil.getWeekLabel()
        return labels[weekday - 1]
    }

    // 曜日を日本語文字で取得（フル）
    class func getWeekdayStringFull(date:NSDate) -> String {
        let weekday:Int = CalendarUtil.getWeekday(date)
        var labels:[String] = CalendarUtil.getWeekLabelFull()
        return labels[weekday - 1]
    }
    
    // NSDateで取得
    // note: 日本時間ではない
    // http://swiftdev.blog.fc2.com/blog-entry-7.html
    class func dateSerial(year : Int, month : Int, day : Int) -> NSDate {
        let comp = NSDateComponents()
        comp.year = year
        comp.month = month
        comp.day = day
        let cal = NSCalendar.currentCalendar()
        let date = cal.dateFromComponents(comp)
        return date!
    }
        
    // 週のラベルを取得（短縮）
    class func getWeekLabel() -> [String] {
        let dayOfWeek:[String] = [NSLocalizedString("sun", comment: ""),
            NSLocalizedString("mon", comment: ""),
            NSLocalizedString("tue", comment: ""),
            NSLocalizedString("wed", comment: ""),
            NSLocalizedString("thu", comment: ""),
            NSLocalizedString("fri", comment: ""),
            NSLocalizedString("sat", comment: "")]
        return dayOfWeek
    }

    // 週のラベルを取得（フル）
    class func getWeekLabelFull() -> [String] {
        let dayOfWeek:[String] = [NSLocalizedString("sunday", comment: ""),
            NSLocalizedString("monday", comment: ""),
            NSLocalizedString("tuesday", comment: ""),
            NSLocalizedString("wednesday", comment: ""),
            NSLocalizedString("thursday", comment: ""),
            NSLocalizedString("friday", comment: ""),
            NSLocalizedString("saturday", comment: "")]
        return dayOfWeek
    }
}
