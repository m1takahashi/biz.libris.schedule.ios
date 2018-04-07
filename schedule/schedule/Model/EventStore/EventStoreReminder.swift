//
//  EventStoreReminder.swift
//

import UIKit
import EventKit

class EventStoreReminder {
    class var sharedInstance: EKEventStore {
        struct Singleton {
            static let instance = EKEventStore()
        }
        return Singleton.instance
    }
}