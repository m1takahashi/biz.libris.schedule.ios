//
//  ReminderSeq.swift
//

import UIKit
import EventKit

class ReminderSeq: NSObject {
    class func getSortedCalendars(calendars:[EKCalendar]) -> [EKCalendar] {
        print("ReminderUtil#getSortedCalendars()")
        // 保存済みのID配列
        let d = [] as NSArray
        var seq:[String] = UDWrapper.getArray(UDWrapperKey.UDWrapperKeyReminderListSeq.rawValue, defaultValue: d) as! [String]
        
        var items:[EKCalendar] = []
        var itemsNotFind:[EKCalendar] = []
        
        // ソートデータがあるもの
        for (var i = 0; i < seq.count; i++) {
            for calendar in calendars {
                if seq[i] == calendar.calendarIdentifier {
                    items.append(calendar)
                    break;
                }
            }
        }
        
        // ソートデータがないもの
        for calendar in calendars {
            var find:Bool = false
            for (var i = 0; i < seq.count; i++) {
                if (calendar.calendarIdentifier == seq[i]) {
                    find = true
                    break
                }
            }
            if !find {
                itemsNotFind.append(calendar)
            }
        }
        
        // マージ
        items = items + itemsNotFind
        return items
    }
    
    // 順番データを保存する
    class func saveSortData(calendars:[EKCalendar]) {
        var seq = [String]() // 初期化
        
        for calendar in calendars {
            seq.append(calendar.calendarIdentifier)
        }
        
        UDWrapper.setArray(UDWrapperKey.UDWrapperKeyReminderListSeq.rawValue, value: seq)
    }
    
    // 先頭に追加する
    class func addSortData(identifier:String) {
        let d = [] as NSArray
        let seq:[String] = UDWrapper.getArray(UDWrapperKey.UDWrapperKeyReminderListSeq.rawValue, defaultValue: d) as! [String]
        
        var newSeq:[String] = []
        newSeq.append(identifier)
        
        for id in seq {
            newSeq.append(id)
        }
        
        UDWrapper.setArray(UDWrapperKey.UDWrapperKeyReminderListSeq.rawValue, value: newSeq)
    }
}
