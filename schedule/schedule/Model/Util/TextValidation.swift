//
//  TextValidation.swift
//

import UIKit

class TextValidation: NSObject {

    // 文字数チェック
    class func length(str: String, min: Int, max: Int) -> Bool {
        if "\(str)".characters.count >= min && "\(str)".characters.count <= max {
            return true
        }
        return false
    }
}
