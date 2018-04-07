//
//  CalenderUtilMonth.swift
//

import UIKit

class CalendarUtilMonth: NSObject {
    // 一ヶ月分の日付を取得
    // NSDateで返すので、日本時間ではない
    class func getMonthList(year:Int, month:Int) -> [NSDate] {
        // 月の日数を取得
        let last:Int = CalendarUtilMonth.getLastDay(year, month: month)!
        var list:[NSDate] = []
        for (var i = 1; i <= last; i++) {
            let date:NSDate = CalendarUtil.dateSerial(year, month: month, day: i)
            list.append(date)
        }
        return list
    }
    
    // その月の最終日の取得
    class func getLastDay(var year:Int,var month:Int) -> Int?{
        let dateFormatter:NSDateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy/MM/dd";
        if month == 12 {
            month = 0
            year++
        }
        let targetDate:NSDate? = dateFormatter.dateFromString(String(format:"%04d/%02d/01",year,month+1));
        if targetDate != nil {
            //月初から一日前を計算し、月末の日付を取得
            let orgDate = NSDate(timeInterval:(24*60*60)*(-1), sinceDate: targetDate!)
            let str:String = dateFormatter.stringFromDate(orgDate)
            //lastPathComponentを利用するのは目的として違う気も。。
            return Int((str as NSString).lastPathComponent);
        }
        return nil;
    }
    
    // 次月を取得
    class func getNextYearAndMonth (year:Int, month:Int) -> (year:Int,month:Int){
        var next_year:Int = year
        var next_month:Int = month + 1
        if next_month > 12 {
            next_month = 1
            next_year++
        }
        return (next_year,next_month)
    }
    
    // 前月を取得
    class func getPrevYearAndMonth (year:Int, month:Int) -> (year:Int,month:Int){
        var prev_year:Int = year
        var prev_month:Int = month - 1
        if prev_month == 0 {
            prev_month = 12
            prev_year--
        }
        return (prev_year,prev_month)
    }
    
    // その月の週の数を取得
    class func getWeekNum(year:Int, month:Int, startWeek:Int) -> Int {
        let beginMonth:NSDate = NSDate.create(year: year, month: month, day: 1, hour: 0, minute: 0, second: 0)!
        let weekday:Int = CalendarUtil.getWeekday(beginMonth)
        var days:Int = CalendarUtilMonth.getLastDay(year, month: month)!
        
        // 第1週に何日入るか
        var firstWeekDays:Int = 7 + startWeek - weekday
        if (firstWeekDays > 7) {
            firstWeekDays = firstWeekDays - 7
        }
        
        days = days - firstWeekDays
        
        let dDays:Double = Double(days)
        
        // 第2週目以降に何週間あるか
        let num:Int = (Int)(ceil(dDays / 7.0))
        return num + 1 // 第1週分を含める
    }
}
