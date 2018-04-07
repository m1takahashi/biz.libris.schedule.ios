//
//  CustomTabBar.swift
//

import UIKit

enum CustomTabBarType : Int {
    case Month  = 0
    case Week   = 1
    case Day    = 2
}

class CustomTabBar: UIView {
    var segmentedList:[String]!
    
    var segmentedCtr:UISegmentedControl!
    let segCtrWidth:CGFloat = 300.0
    let segCtrHeight:CGFloat = 28.0
    
    var type:CustomTabBarType!
    
    class var defaultHeight:CGFloat {
        return 44.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame:CGRect, type:CustomTabBarType) {
        super.init(frame:frame)
        
        self.type = type

        let image:UIImage = UIImage(named: "Border_Tab")!
        self.backgroundColor = UIColor(patternImage: image)
        
        segmentedList = [NSLocalizedString("month", comment: ""),
            NSLocalizedString("week", comment: ""),
            NSLocalizedString("day", comment: "")]
        if type == .Month {
            segmentedList.append(NSLocalizedString("this_month", comment: ""))
        } else if type == .Week {
            segmentedList.append(NSLocalizedString("this_week", comment: ""))
        } else if type == .Day {
            segmentedList.append(NSLocalizedString("today", comment: ""))
        }
        
        segmentedCtr = UISegmentedControl(items: segmentedList)
        let posX = (self.frame.size.width - segCtrWidth) / 2
        let posY = (self.frame.size.height - segCtrHeight) / 2
        segmentedCtr.frame = CGRectMake(posX, posY, segCtrWidth, segCtrHeight)
        segmentedCtr.addTarget(self, action: "segconChanged:", forControlEvents: UIControlEvents.ValueChanged)
        segmentedCtr.selectedSegmentIndex = 0
        self.addSubview(segmentedCtr)
    }
    
    func segconChanged(segcon: UISegmentedControl){
        let index:Int = segcon.selectedSegmentIndex
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if index == 0 {
            appDelegate.switchCenterView(CenterViewType.CenterViewTypeCalMonth, param: nil)
        } else if index == 1 {
            appDelegate.switchCenterView(CenterViewType.CenterViewTypeCalWeek, param: nil)
        } else if index == 2 {
            appDelegate.switchCenterView(CenterViewType.CenterViewTypeCalDay, param: nil)
        } else {
            segmentedCtr.selectedSegmentIndex = type.rawValue
            if type == .Month {
                NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameThisMonth(), object: nil)
            } else if type == .Week {
                NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameThisWeek(), object: nil)
            } else if type == .Day {
                NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameToday(), object: nil)
            }
        }
    }
    
    func setSelected(selected:CustomTabBarType) {
        segmentedCtr.selectedSegmentIndex = selected.rawValue
    }
    
    /*
    func setSelectedIndex(index:Int) {
        segmentedCtr.selectedSegmentIndex = index
    }*/
    
    func setSegctrColor(color: UIColor) {
        segmentedCtr.tintColor = color
    }
}
