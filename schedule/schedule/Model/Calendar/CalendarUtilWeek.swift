//
//  CalenderUtilWeek.swift
//

import UIKit

class CalendarUtilWeek: NSObject {
    // ナビゲーションバーに表示するタイトル（YYYY/MM）を取得する
    class func getWeekTitle(list:[NSDate]) -> String {
        var titles:[String] = []

        // 週の中に多い月の方を優先する
        for date in list {
            let dateFormatter:NSDateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "yyyy/M"
            let dateString:String = dateFormatter.stringFromDate(date)
            titles.append(dateString)
        }
        
        // 同じ週に２ヶ月以上が入ることはない
        let title1:String = titles[0]
        let title2:String = titles[titles.count - 1]
        var title1Cnt:Int = 0
        var title2Cnt:Int = 0
        
        if (title1 == title2) {
            return title1
        }
        
        for (var i = 0; i < titles.count; i++) {
            if (title1 == titles[i]) {
                title1Cnt += 1
            } else if (title2 == titles[i]) {
                title2Cnt += 1
            }
        }
        if (title2Cnt > title1Cnt) {
            return title2
        }
        return title1
    }
    
    // 週初めの日付を取得
    class func getStartOfWeekDay(startOfWeek:Int, today:NSDate) -> NSDate {
        var interval:NSTimeInterval = 24 * 60 * 60 // 1日（秒）
        let weekday:Int = CalendarUtil.getWeekday(today)
        
        let diff:Int = weekday - startOfWeek
        if (diff < 0) {
            // diffはマイナス値
            interval *= -NSTimeInterval(7 + diff)
        } else {
            interval *= -NSTimeInterval(diff)
        }
        
        let date:NSDate = NSDate(timeInterval: interval, sinceDate: today)
        return date
    }
    
    // 指定日から一週間後を取得
    class func getNextWeekDay(date:NSDate) -> NSDate {
        var interval:NSTimeInterval = 24 * 60 * 60 // 1日（秒）
        interval *= NSTimeInterval(7)
        let date:NSDate = NSDate(timeInterval: interval, sinceDate: date)
        return date
    }
    
    // 指定日から一週間前を取得
    class func getPrevWeekDay(date:NSDate) -> NSDate {
        var interval:NSTimeInterval = 24 * 60 * 60 // 1日（秒）
        interval *= -NSTimeInterval(7)
        let date:NSDate = NSDate(timeInterval: interval, sinceDate: date)
        return date
    }
    
    // 指定日の一週間の最終日を取得
    class func getLastWeekDay(date:NSDate) -> NSDate {
        var interval:NSTimeInterval = 24 * 60 * 60 // 1日（秒）
        interval *= NSTimeInterval(6)
        let date:NSDate = NSDate(timeInterval: interval, sinceDate: date)
        return date
    }
    
    // 一週間を取得
    class func getWeekList(start:NSDate) -> [NSDate] {
        let oneday:NSTimeInterval = 24 * 60 * 60 // 1日（秒）
        var list:[NSDate] = []
        for (var i = 0; i < 7; i++) {
            let date:NSDate = NSDate(timeInterval: oneday * NSTimeInterval(i), sinceDate: start)
            list.append(date)
        }
        return list
    }

}
