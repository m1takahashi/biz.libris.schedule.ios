//
//  ReminderUtil.swift
//

import UIKit
import EventKit

class ReminderUtil: NSObject {
    var eventStore:EKEventStore!
    
    init(eventStore: EKEventStore) {
        self.eventStore = eventStore
    }
    
    // デフォルトリスト作成
    func createDefaultCalendar() -> Bool {
        let calendar:EKCalendar = EKCalendar(forEntityType: EKEntityType.Reminder, eventStore: eventStore)
        calendar.title = NSLocalizedString("reminder_default_list_title", comment: "")
        
        var theSource:EKSource!
        for source in eventStore.sources {
            if (source.sourceType.rawValue == EKSourceType.Local.rawValue) {
                theSource = source 
                break;
            }
        }
        calendar.source = theSource
        
        ReminderSeq.addSortData(calendar.calendarIdentifier) // Seq 最前面に
        
        var writeError: NSError?
        do {
            try eventStore.saveCalendar(calendar, commit: true)
        } catch let error1 as NSError {
            writeError = error1
            if let error = writeError {
                print("Error, Reminder write failure: \(error.localizedDescription)")
                return false
            }
        }
        
        // アイテム作成
        if !createDefaultItem(calendar) {
            return false
        }
        
        return true
    }
    
    // デフォルトアイテムを作成する
    func createDefaultItem(calendar:EKCalendar) -> Bool {
        let reminder:EKReminder = EKReminder(eventStore: eventStore)
        reminder.calendar = calendar
        reminder.title = NSLocalizedString("reminder_default_item_title", comment: "")
        reminder.priority = ReminderPriority.None.rawValue

        var writeError: NSError?
        var result: Bool
        do {
            try eventStore.saveReminder(reminder, commit: true)
            result = true
        } catch let error as NSError {
            writeError = error
            result = false
        }
        if !result {
            if let error = writeError {
                print("write failure: \(error.localizedDescription)")
            }
        }
        return result
    }
}
