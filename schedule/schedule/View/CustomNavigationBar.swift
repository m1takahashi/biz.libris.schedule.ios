//
//  CustomNavigationBar.swift
//

import UIKit

class CustomNavigationBar: UIView {
    
    var titleLabel:UILabel!

    class var defaultHeight:CGFloat {
        return 44.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        initTitle()
    }
    
    func initTitle() {
        let width:CGFloat   = 200.0
        let height:CGFloat  = 44.0
        let posX:CGFloat    = (self.frame.size.width - width) / 2
        let posY:CGFloat    = 0.0
        titleLabel = UILabel(frame: CGRectMake(posX, posY, width, height))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont.boldSystemFontOfSize(20.0)
        self.addSubview(titleLabel)
    }

    // 文字設定
    func setTitleText(title: String) {
        titleLabel.text = title
    }
    
    // 文字色設定
    func setTitleColor(color: UIColor) {
        titleLabel.textColor = color
    }
    
    // 背景色設定
    func setBgColor(color: UIColor) {
        self.backgroundColor = color
    }
}
