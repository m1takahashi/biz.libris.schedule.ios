//
//  ColorManager.swift
//

import UIKit

class ColorManager: NSObject {

    class func getDayColor() -> UIColor {
        return UIColor.darkGrayColor()
    }
    
    class func getWeekColor() -> UIColor {
        return UIColor.lightGrayColor()
    }
    
    class func getRokuyouColor() -> UIColor {
        return UIColor.lightGrayColor()
    }
    
    // 休日（任意）
    class func getHolidayColor() -> UIColor {
        return UIColor(hexString: "EA5532", alpha: 1.0)
    }
    
    // 日曜
    class func getSundayColor() -> UIColor {
        return UIColor.redColor()
    }
    
    // 土曜
    class func getSaturdayColor() -> UIColor {
        return UIColor.blueColor()
    }
    
    class func getTodayBackgroundColor() -> UIColor {
        return UIColor(hexString: "FF0000", alpha: 0.3)
    }
    
    class func getDrawerCellText() -> UIColor {
        return UIColor.darkGrayColor()
    }
    
    class func getSettingCellText() -> UIColor {
        return UIColor.darkGrayColor()
    }
    
    class func getCalendarOutGrid() -> UIColor {
        return UIColor(hexString: "CCCCCC", alpha: 0.3)
    }
    
    // Custom Theme
    class func getThemeCustomNavBarString() -> String {
        return "FF5487"
    }
    
    class func getThemeCustomNavTextString() -> String {
        return "FFE5ED"
    }
    
    //-- Reminder --//
    class func getReminderCellText() -> UIColor {
        return UIColor.darkGrayColor()
    }
    
    class func getReminderCellTextDetail() -> UIColor {
        return UIColor.lightGrayColor()
    }
    
    // Remove
    class func getReminderRemove() -> UIColor {
        return UIColor(hexString: "FF3B30", alpha: 1.0)
    }
    
    
    
}