//
//  Rokuyou.swift
//

import UIKit

class Rokuyou: NSObject {
    var list:NSDictionary?
    
    // 年ごとに予めリスト化している
    init(year:String) {
        let fileName:String = "Rokuyou_\(year)"
        if  let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType:"plist") {
            list = NSDictionary(contentsOfFile: filePath)
        }
    }
    
    // 2015/3/18と指定すると該当の六曜を返す
    func getRokuyou(dateStr: String) -> String {
        var rokuyou:String = ""
        if list != nil {
            rokuyou = list?.valueForKey(dateStr) as! String
        }
        return rokuyou
    }
}
