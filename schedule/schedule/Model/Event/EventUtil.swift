//
//  EventUtil.swift
//

import UIKit
import EventKit

enum EventCalendarTermType: String {
    case EventCalendarTermTypeNone      = "none"
    case EventCalendarTermTypeAllDay    = "allday"
    case EventCalendarTermTypeDay       = "day"
    case EventCalendarTermTypeStartDay  = "start"
    case EventCalendarTermTypeMiddleDay = "middle"
    case EventCalendarTermTypeEndDay    = "end"
}

class EventUtil: NSObject {
    /**
     * 重複した予定数を取得
     */
    class func getDuplicateEventCount(date:NSDate, start:NSDate, end:NSDate, termList:[Int]) -> Int {
        var count:Int = 0
        var indexes:[Int] = EventUtil.getTermIndexes(date, start: start, end: end)
        for (var i = 0; i < indexes.count; i++) {
            if (termList[ indexes[i] ] > count) {
                count = termList[ indexes[i] ]
            }
        }
        return count
    }
    
    /**
     * カレンダーの日表示用
     * タイムラインは、30毎に分割されているので、48（24 * 2）マスあることになる
     */
    class func getTermIndexes(date:NSDate, start:NSDate, end:NSDate) -> [Int] {
        let tsSection:NSTimeInterval = 30 * 60 // 1コマ30分
        
        var indexes:[Int] = []
        var section:Int = 0 // コマ
        
        var startDate:NSDate = start
        var endDate:NSDate = end
        
        var tsStart:NSTimeInterval = startDate.timeIntervalSinceReferenceDate
        var tsEnd:NSTimeInterval = endDate.timeIntervalSinceReferenceDate
        
        // 同一日のイベントか判別
        if (start.year == end.year && start.month == end.month && start.day == end.day) {
            print("同一日のイベントです")
            // なにもしない
            
        } else if (start.year == date.year && start.month == date.month && start.day == date.day) {
            print("開始日です")
            // 開始日（該当日の23:59:59を終了とする）
            endDate = NSDate.create(year: start.year, month: start.month, day: start.day, hour: 23, minute: 59, second: 59)!
            tsEnd = endDate.timeIntervalSinceReferenceDate
            
        } else if (end.year == date.year && end.month == date.month && end.day == date.day) {
            print("終了日です")
            // 終了を開始と入れ替える
            // 開始を0:0:0からにする
            startDate = NSDate.create(year: date.year, month: date.month, day: date.day, hour: 0, minute: 0, second: 0)!
            tsStart = startDate.timeIntervalSinceReferenceDate

        } else {
            print("中日です")
            // 該当日の00:00:00 ~ 23:59:59
            startDate = NSDate.create(year: date.year, month: date.month, day: date.day, hour: 0, minute: 0, second: 0)!
            endDate = NSDate.create(year: date.year, month: date.month, day: date.day, hour: 23, minute: 59, second: 59)!
            tsStart = startDate.timeIntervalSinceReferenceDate
            tsEnd = endDate.timeIntervalSinceReferenceDate
        }
        
        let tsDiff = tsEnd - tsStart
//        println("TS Diff  : \(tsDiff)")
        
        // ローカライズ済みの開始日時
        let startHour:Int = startDate.hour
        let startMin:Int = startDate.minute
        var index:Int = startHour * 2 // 0〜29分
        if (startMin >= 30) {
            index += 1
        }
        
        if (tsDiff <= tsSection) {
            // 1コマ場合
            indexes.append(index)
            return indexes // 1コマ
        } else {
            // 複数コマの場合
            section = (Int)(ceil(tsDiff / tsSection))
            print("Section : \(section)")
            
            var counter = 0
            while counter < section {
                indexes.append(index)
                index++
                counter++
            }
        }
        return indexes
    }
    
    /**
     * 指定した日にそのイベントが該当するか
     * TimeIntervalによる比較を行う
     */
    class func getTermType(date:NSDate, event:EKEvent) -> EventCalendarTermType {
        // YYYY/MM/DD 00:00:00 統一
        let criteriaStart:NSDate = NSDate.create(year: date.year, month: date.month, day: date.day, hour: 0, minute: 0, second: 0)!
        let criteriaEnd:NSDate = NSDate.create(year: date.year, month: date.month, day: date.day, hour: 23, minute: 59, second: 59)!
        
        let tsCriteriaStart:NSTimeInterval = criteriaStart.timeIntervalSinceReferenceDate
        let tsCriteriaEnd:NSTimeInterval = criteriaEnd.timeIntervalSinceReferenceDate
        
        let tsStart:NSTimeInterval = event.startDate.timeIntervalSinceReferenceDate
        let tsEnd:NSTimeInterval = event.endDate.timeIntervalSinceReferenceDate

        // 終日判別
        if event.allDay {
            if (event.startDate.year == date.year && event.startDate.month == date.month && event.startDate.day == date.day) {
                // 開始日
                return .EventCalendarTermTypeAllDay
                
            } else if (event.endDate.year == date.year && event.endDate.month == date.month && event.endDate.day == date.day) {
                // 終了日
                return .EventCalendarTermTypeAllDay
                
            } else if (tsCriteriaStart >= tsStart && tsCriteriaEnd <= tsEnd) {
                // 中日：イベント自体の開始・終了日の中に、指定した日が入っている
                return .EventCalendarTermTypeAllDay
            }
        } else {
            if ((tsStart >= tsCriteriaStart) && (tsStart <= tsCriteriaEnd) && (tsEnd >= tsCriteriaStart) && (tsEnd <= tsCriteriaEnd)) {
                // 当日のみ
                return .EventCalendarTermTypeDay
                
            } else if (tsStart >= tsCriteriaStart) && (tsStart <= tsCriteriaEnd) {
                // 開始日
                return .EventCalendarTermTypeStartDay
                
            } else if ((tsEnd >= tsCriteriaStart) && (tsEnd <= tsCriteriaEnd)) {
                // 終了日
                return .EventCalendarTermTypeEndDay
                
            } else if (tsCriteriaStart >= tsStart && tsCriteriaEnd <= tsEnd) {
                // 中日
                return .EventCalendarTermTypeMiddleDay
            }
        }
        
        return .EventCalendarTermTypeNone
    }
}
