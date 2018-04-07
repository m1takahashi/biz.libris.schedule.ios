//
//  CalView.swift
//  基底クラス
//

import UIKit
import EventKit

class CalView: UIView {
    let cleanupTergetTag:Int = 99

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    func cleanup() {
        let subViews:[UIView] = self.subviews 
        for view in subViews {
            if view.tag == cleanupTergetTag {
                view.removeFromSuperview()
            }
        }
    }
}
