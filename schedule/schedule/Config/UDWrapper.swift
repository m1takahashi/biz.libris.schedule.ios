//
//  UDWapper.swift
//  https://gist.githubusercontent.com/fwhenin/b770228a982230bd8690/raw/7cc78a338332a535f16ec187ff50ee335526b6f9/UDWrapper.swift
//

import UIKit
import Foundation

enum UDWrapperKey: String {
    case UDWrapperKeyEULA                       = "eula"                        // Bool:EULA
    case UDWrapperKeyStartWeekday               = "start_weekday"               // Int:週の開始（1=日曜日, 2=月曜日...）
    case UDWrapperKeyStartPageMode              = "start_page_mode"             // Int:スタートページ（カレンダー|ToDo）
    case UDWrapperKeyStartPage                  = "start_page"                  // Int:スタートページ
    case UDWrapperKeyRokuyou                    = "rokuyou"                     // Bool:六曜の表示・非表示
    case UDWrapperKeyDisableCalendars           = "disable_calendars"           // Array:表示しないカレンダーリスト
    case UDWrapperKeyTheme                      = "theme"                       // String:テーマ
    case UDWrapperKeyCustomNavBarColor          = "custom_nav_bar_color"        // String:Color
    case UDWrapperKeyCustomNavTextColor         = "custom_nav_text_color"       // String:Color
    case UDWrapperKeyCoachMarksMonth            = "coach_marks_month"           // Bool
    case UDWrapperKeyCoachMarksWeek             = "coach_marks_week"            // Bool
    case UDWrapperKeyCoachMarksDay              = "coach_marks_day"             // Bool
    case UDWrapperKeyCoachMarksReminder         = "coach_marks_reminder"        // Bool
    case UDWrapperKeyCoachMarksNote             = "coach_marks_note"            // Bool
    case UDWrapperKeyHolidayType                = "holiday_type"                // Int
    case UDWrapperKeyHolidayCustom              = "holiday_custom"              // [Bool]
    case UDWrapperKeyScrollDirection            = "scroll_direction"            // Int
    case UDWrapperKeyScrollDirectionWeek        = "scroll_direction_week"       // Int
    case UDWrapperKeyReminderDisplayCompleted   = "reminder_display_completed"  // Bool
    case UDWrapperKeyReminderListSeq            = "reminder_list_seq"           // [String]:CalendarId
    case UDWrapperKeyNoteSortOrder              = "note_sort_order"             // Int:NoteSortOrder
    case UDWrapperKeyAdDisplayedList            = "ad_displayed_list"           // Array:表示済み広告ID一覧
}

class UDWrapper{
    class func getObject(key: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(key)
    }
    
    class func getInt(key: String) -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(key)
    }
    
    class func getBool(key: String) -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(key)
    }
    
    class func getFloat(key: String) -> Float {
        return NSUserDefaults.standardUserDefaults().floatForKey(key)
    }
    
    class func getString(key: String) -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(key)
    }
    
    class func getData(key: String) -> NSData? {
        return NSUserDefaults.standardUserDefaults().dataForKey(key)
    }
    
    class func getArray(key: String) -> NSArray? {
        return NSUserDefaults.standardUserDefaults().arrayForKey(key)
    }
    
    class func getDictionary(key: String) -> NSDictionary? {
        return NSUserDefaults.standardUserDefaults().dictionaryForKey(key)
    }
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Get value with default value
    //-------------------------------------------------------------------------------------------
    
    class func getObject(key: String, defaultValue: AnyObject) -> AnyObject? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getObject(key)
    }
    
    class func getInt(key: String, defaultValue: Int) -> Int {
        if getObject(key) == nil {
            return defaultValue
        }
        return getInt(key)
    }
    
    class func getBool(key: String, defaultValue: Bool) -> Bool {
        if getObject(key) == nil {
            return defaultValue
        }
        return getBool(key)
    }
    
    class func getFloat(key: String, defaultValue: Float) -> Float {
        if getObject(key) == nil {
            return defaultValue
        }
        return getFloat(key)
    }
    
    class func getString(key: String, defaultValue: String) -> String? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getString(key)
    }
    
    class func getData(key: String, defaultValue: NSData) -> NSData? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getData(key)
    }
    
    class func getArray(key: String, defaultValue: NSArray) -> NSArray? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getArray(key)
    }
    
    class func getDictionary(key: String, defaultValue: NSDictionary) -> NSDictionary? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getDictionary(key)
    }
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Set value
    //-------------------------------------------------------------------------------------------
    
    class func setObject(key: String, value: AnyObject?) {
        if value == nil {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        } else {
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setInt(key: String, value: Int) {
        NSUserDefaults.standardUserDefaults().setInteger(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setBool(key: String, value: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setFloat(key: String, value: Float) {
        NSUserDefaults.standardUserDefaults().setFloat(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setString(key: String, value: NSString?) {
        if (value == nil) {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        } else {
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setData(key: String, value: NSData) {
        setObject(key, value: value)
    }
    
    class func setArray(key: String, value: NSArray) {
        setObject(key, value: value)
    }
    
    
    class func setDictionary(key: String, value: NSDictionary) {
        setObject(key, value: value)
    }
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Synchronize
    //-------------------------------------------------------------------------------------------
    
    class func Sync() {
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
