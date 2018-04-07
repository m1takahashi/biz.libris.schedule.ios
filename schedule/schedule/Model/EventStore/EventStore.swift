//
//  EventStore.swift
//  http://qiita.com/takecian/items/535742156f34ae36d2a9#2-5
//  http://qiita.com/1024jp/items/3a7bc437af3e79f74505
//  note: reset
//  http://qiita.com/hayakawatomoaki/items/22e631dfb9ebf9e8d578
//

import UIKit
import EventKit

class EventStore {
    private static var instance: EKEventStore?
    
    class var sharedInstance: EKEventStore {
        if let instance = instance {
            return instance
        }
        instance = EKEventStore()
        return instance!
    }
    
    class func deleteSharedInstance() {
        EventStore.instance = nil
    }
}