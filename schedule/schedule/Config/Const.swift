//
//  Const.swift
//

import UIKit

enum StartPageMode : Int {
    case Calendar   = 0
    case Reminder   = 1
    case Note       = 2
}

enum StartPageType : Int {
    case Month = 0
    case Week  = 1
    case Day   = 2
}

// （1:日曜日、2:月曜日）
enum StartWeek : Int {
    case Sunday     = 1
    case Monday     = 2
    case Tuesday    = 3
    case Wednesday  = 4
    case Thursday   = 5
    case Friday     = 6
    case Saturday   = 7
}

enum ScrollDirection : Int {
    case Vertical   = 0
    case Horizontal = 1
}

enum ReminderPriority : Int {
    case None   = 0
    case Low    = 1
    case Normal = 2
    case High   = 3
}

enum NoteSortOrder : Int {
    case TitleASC       = 0
    case SubmitDateDESC = 1
    case SubmitDateASC  = 2
    case UpdateDateDESC = 3
    case UpdateDateASC  = 4
}

class Const: NSObject {
    //-- URL --//
    class func getAppUrl() -> String {
        return "https://itunes.apple.com/us/app/smiledays/id963571230?l=ja&ls=1&mt=8"
    }
    
    //-- Mail Common --//
    class func getSupportMailAddr() -> String {
        return "cmpusinfo@gmail.com"
    }

    //-- Invite Friends --//
    class func getInviteMail() -> String {
        return "mailto: ?Subject=" + Const.getInviteMailSubject() + "&body=" + Const.getInviteMailBody()
    }
    
    class func getInviteMailSubject() -> String {
        return NSLocalizedString("mail_subject", comment: "")
    }
    
    class func getInviteMailBody() -> String {
        return NSLocalizedString("mail_body", comment: "") + Const.getAppUrl()
    }
    
    //-- Notification Center --//
    class func getNotificationNameEventAddDayTL() -> String {
        return "event_add_day_tl"
    }
    
    class func getNotificationNameEventAddWeekGrid() -> String {
        return "event_add_week_grid"
    }
    
    class func getNotificationNameEventEdit() -> String {
        return "event_edit"
    }
    
    class func getNotificationNameDismissPopup() -> String {
        return "dismiss_popup"
    }
    
    class func getNotificationNameThisMonth() -> String {
        return "this_month"
    }

    class func getNotificationNameThisWeek() -> String {
        return "this_week"
    }
    
    class func getNotificationNameToday() -> String {
        return "today"
    }
    
    //-- Reminder --//
    // ReminderViewからEditViewを表示
    class func getNotificationNameReminderDisplayForm() -> String {
        return "reminder_display_form"
    }
    
    // EditViewから、MainViewへ戻ってきた時に表示内容をリロードする
    class func getNotificationNameReminderBackForm() -> String {
        return "reminder_back_form"
    }
    
    //-- Note --//
    class func getNotificationNameNoteDisplayForm() -> String {
        return "note_display_form"
    }
    
    class func getNotificationNameNoteShare() -> String {
        return "note_share"
    }
    
    // EditViewから、MainViewへ戻ってきた時に表示内容をリロードする
    class func getNotificationNameNoteBackForm() -> String {
        return "note_back_form"
    }
}
