//
//  SettingThemeColorPickerViewController.swift
//  POPUP
//

import UIKit

class SettingThemeColorPickerViewController: UIViewController {
    var colorPickerView:HRColorPickerView!
    
    var type:CustomNavColorType!
    var colorStr:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dispWidth:CGFloat = 320
        let dispHeight:CGFloat = 480
        
        let footerHeight:CGFloat = 50
        
        let pickerWidth:CGFloat = dispWidth
        let pickerHeight:CGFloat = dispHeight - footerHeight
        
        let buttonWidth:CGFloat = 80
        let buttonHeight:CGFloat = 44
        
        let posX:CGFloat = (self.view.frame.size.width - dispWidth) / 2.0
        let posY:CGFloat = (self.view.frame.size.height - dispHeight) / 2.0
        
        let canvasView:UIView = UIView(frame: CGRectMake(posX, posY, dispWidth, dispHeight))
        canvasView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(canvasView)

        colorPickerView = HRColorPickerView(frame: CGRectMake(0, 0, pickerWidth, pickerHeight))

        colorPickerView.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
        canvasView.addSubview(colorPickerView)

        let btnMarginTop:CGFloat = (footerHeight - buttonHeight) / 2.0
        var btnPosX:CGFloat = (dispWidth - (buttonWidth * 2.0)) / 3.0
        let btnPosY:CGFloat = dispHeight - footerHeight + btnMarginTop
        
        let btnCancel:UIButton = UIButton(frame: CGRectMake(btnPosX, btnPosY, buttonWidth, buttonHeight))
        btnCancel.setTitle(NSLocalizedString("btn_cancel", comment: ""), forState: UIControlState.Normal)
        btnCancel.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        btnCancel.titleLabel?.font = UIFont.boldSystemFontOfSize(14.0)
        btnCancel.addTarget(self, action: "onCancelButton:", forControlEvents: .TouchUpInside)
        canvasView.addSubview(btnCancel)
        
        btnPosX = (btnPosX * 2) + buttonWidth
        let btnApply:UIButton = UIButton(frame: CGRectMake(btnPosX, btnPosY, buttonWidth, buttonHeight))
        btnApply.setTitle(NSLocalizedString("btn_apply", comment: ""), forState: UIControlState.Normal)
        btnApply.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        btnApply.titleLabel?.font = UIFont.boldSystemFontOfSize(14.0)
        btnApply.addTarget(self, action: "onApplyButton:", forControlEvents: .TouchUpInside)
        canvasView.addSubview(btnApply)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let color:UIColor = UIColor(hexString: colorStr, alpha: 1.0)
        colorPickerView.color = color
    }
    
    func changeValue(sender:HRColorPickerView) {
        let color:UIColor = sender.color
        colorStr = color.hexString
    }
    
    func onApplyButton(sender:UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameDismissPopup(),
            object: nil,
            userInfo: ["color_str": colorStr, "type_str": type.rawValue])
    }
    
    func onCancelButton(sender:UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameDismissPopup(), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}