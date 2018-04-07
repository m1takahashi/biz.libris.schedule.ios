//
//  Holiday.swift
//  schedule
//

import UIKit

// 休日タイプ
enum HolidayType : Int {
    case Default = 0
    case Custom  = 1
}

class Holiday: NSObject {
    
    class func getDefaultType() -> HolidayType {
        return .Default
    }
    
    class func getDefaultCustom() -> [Bool] {
        return Array(count: 7, repeatedValue: false)
    }
}
