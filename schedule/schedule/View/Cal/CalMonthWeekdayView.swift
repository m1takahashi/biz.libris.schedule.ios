//
//  CalMonthWeekday.swift
//

import UIKit

class CalMonthWeekdayView: UIView {
    let fontSize:CGFloat = 12.0
    var dayOfWeek:[String]!
    
    var colWidth:CGFloat!
    var colHeight:CGFloat!
    
    class var defaultHeight:CGFloat {
        return 20.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)

        let image:UIImage = UIImage(named: "Border_Week")!
        self.backgroundColor = UIColor(patternImage: image)
        
        dayOfWeek = CalendarUtil.getWeekLabel()
        colWidth = frame.size.width / 7
        colHeight = CalMonthWeekdayView.defaultHeight
    }
    
    func changeStartWeek(startWeek:Int) {
        // Cleanup
        let subViews:[UIView] = self.subviews 
        for view in subViews {
            view.removeFromSuperview()
        }
        
        var index:Int = startWeek - 1
        for (var i = 0; i < 7; i++ ) {
            let posX:CGFloat = colWidth * CGFloat(i)
            let label:UILabel = UILabel(frame:  CGRectMake(posX, 0, colWidth, colHeight))
            label.text = dayOfWeek[index]
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont.systemFontOfSize(fontSize)
            self.addSubview(label)
            
            // 循環
            if (index >= 6) {
                index = 0
            } else {
                index++
            }
            
            
        }
    }
}
