//
//  FontManager.swift
//

import UIKit

class FontManager: NSObject {
    
    class func getDrawerCellText() -> UIFont {
        return UIFont.boldSystemFontOfSize(14.0)
    }
    
    class func getSettingCellText() -> UIFont {
        return UIFont.boldSystemFontOfSize(14.0)
    }
    
    //-- Reminder --//
    class func getReminderCellText() -> UIFont {
        return UIFont.boldSystemFontOfSize(14.0)
    }
    
    class func getReminderCellTextDetail() -> UIFont {
        return UIFont.boldSystemFontOfSize(12.0)
    }
}
