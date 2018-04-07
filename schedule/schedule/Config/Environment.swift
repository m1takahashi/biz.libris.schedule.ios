//
//  Environment.swift
//

import UIKit

class Environment: NSObject {
    class func isDevelopment() -> Bool {
        #if DEBUG
            return true
            #else
            return false
        #endif
    }
    
    class func isLocaleJapanise() -> Bool {
        let pre:String = NSLocale.preferredLanguages()[0] 
        if pre.hasPrefix("ja-") {
            return true
        }
        return false
    }
}
