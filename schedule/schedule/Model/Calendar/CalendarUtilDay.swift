//
//  CalendarUtilDay.swift
//

import UIKit

class CalendarUtilDay: NSObject {

    // 次の日を取得
    class func getNextDay(date:NSDate) -> NSDate {
        var interval:NSTimeInterval = 24 * 60 * 60 // 1日（秒）
        interval *= NSTimeInterval(1)
        let date:NSDate = NSDate(timeInterval: interval, sinceDate: date)
        return date
    }
    
    // 前日を取得
    class func getPrevDay(date:NSDate) -> NSDate {
        var interval:NSTimeInterval = 24 * 60 * 60 // 1日（秒）
        interval *= -NSTimeInterval(1)
        let date:NSDate = NSDate(timeInterval: interval, sinceDate: date)
        return date
    }
}
