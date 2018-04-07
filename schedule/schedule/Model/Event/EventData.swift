//
//  EventData.swift
//  カレンダーイベント取得クラス
//

import UIKit
import EventKit

class EventData: NSObject {
    var eventStore: EKEventStore!
    var calendars: [EKCalendar]!
    
    init(eventStore:EKEventStore, calendars:[EKCalendar]) {
        self.eventStore = eventStore
        self.calendars = calendars
    }
    
    // 1日分のイベントデータを取得
    func getDayData(date:NSDate) -> [EKEvent] {
        var events:[EKEvent] = []
        let data = getDayRawData(date)
        if (data != nil) {
            events = data as! [EKEvent]
        }
        return events
    }
    
    // 1週間分のイベントデータを取得
    func getWeekData(start:NSDate) -> [[EKEvent]] {
        var events:[EKEvent] = []
        let dates:[NSDate] = CalendarUtilWeek.getWeekList(start)
        let data = getWeekRawData(start)
        if (data != nil) {
            events = data as! [EKEvent]
        }
        let list:[[EKEvent]] = getDataByArray(dates, events: events)
        return list
    }
    
    // 一ヶ月分のカレンダーデータを取得する
    func getMonthData(year:Int, month:Int) -> [[EKEvent]] {
        var events:[EKEvent] = []
        let dates:[NSDate] = CalendarUtilMonth.getMonthList(year, month: month)
        let data = getMonthRawData(year, month: month)
        if (data != nil) {
            events = data as! [EKEvent]
        }
        let list:[[EKEvent]] = getDataByArray(dates, events: events)
        return list
    }
    
    // 配列で返す
    private func getDataByArray(dateList:[NSDate], events:[EKEvent]) -> [[EKEvent]]{
        var list:[[EKEvent]] = []
        for (_, d) in dateList.enumerate() {
            var tmp:[EKEvent] = []
            for event in events {
                let type:EventCalendarTermType = EventUtil.getTermType(d, event: event)
                if (type != EventCalendarTermType.EventCalendarTermTypeNone) {
                    tmp.append(event)
                }
            }
            list.append(tmp)
        }
        return list;
    }
    
    /**
     * 1日分の生データを取得
     * 範囲指定 2015/3/15 00:00:00 - 2015/3/15 23:59:59
     */
    private func getDayRawData(date:NSDate) -> [AnyObject]! {
        let startDate:NSDate = NSDate.create(year: date.year, month: date.month, day: date.day, hour: 0, minute: 0, second: 0)!
        let endDate:NSDate = NSDate.create(year: date.year, month: date.month, day: date.day, hour: 23, minute: 59, second: 59)!
        return fetchEvents(startDate, end: endDate)
    }
    
    /**
     * 1週間分の生データを取得
     * 範囲指定 2015/3/15 00:00:00 - 2015/3/21 23:59:59
     */
    private func getWeekRawData(start:NSDate) -> [AnyObject]! {
        let end:NSDate = CalendarUtilWeek.getLastWeekDay(start)
        let startDate:NSDate = NSDate.create(year: start.year, month: start.month, day: start.day, hour: 0, minute: 0, second: 0)!
        let endDate:NSDate = NSDate.create(year: end.year, month: end.month, day: end.day, hour: 23, minute: 59, second: 59)!
        return fetchEvents(startDate, end: endDate)
    }
    
    /**
     * 1ヶ月分の生データを取得
     * 2015/03/01 00:00:00 -> 2015/03/31 23:59:59
     */
    private func getMonthRawData(year:Int, month:Int) -> [AnyObject]! {
        let lastday:Int = CalendarUtilMonth.getLastDay(year, month: month)!
        let startDate:NSDate = NSDate.create(year: year, month: month, day: 1, hour: 0, minute: 0, second: 0)!
        let endDate:NSDate = NSDate.create(year: year, month: month, day: lastday, hour: 23, minute: 59, second: 59)!
        return fetchEvents(startDate, end: endDate)
    }
    
    // イベントのフェッチ
    private func fetchEvents(start:NSDate, end:NSDate) -> [AnyObject]! {
        var predicate = NSPredicate()
        predicate = eventStore.predicateForEventsWithStartDate(start, endDate: end, calendars: calendars)
        return eventStore.eventsMatchingPredicate(predicate)
    }
}
