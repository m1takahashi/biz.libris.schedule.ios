//
//  EulaViewController.swift
//  note:
//  EULA表示時に、Reminderの認証を行う
//  この時点で認証をしておかないと、Reminderに移動してアイテムの追加ができない
//

import UIKit
import EventKit

class EulaViewController: UIViewController {
    var eventStore:EKEventStore!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        
        let width:CGFloat = self.view.frame.width
        let height:CGFloat = self.view.frame.height
        
        let titleHeight:CGFloat         = 44.0
        let footerHeight:CGFloat        = 50.0
        let bodyHeight:CGFloat          = height - (statusBarHeight + titleHeight + footerHeight)
        
        let agreeButtonWidth:CGFloat    = 120.0
        let agreeButtonHeight:CGFloat   = 44.0

        var posX:CGFloat = 0.0
        var posY:CGFloat = statusBarHeight

        let label:UILabel = UILabel(frame: CGRectMake(posX, posY, width, titleHeight))
        label.text = NSLocalizedString("eula_title", comment: "")
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont.boldSystemFontOfSize(18.0)
        label.textAlignment = NSTextAlignment.Center
        self.view.addSubview(label)
        
        // Body
        var resourceName:String = "eula"
        if Environment.isLocaleJapanise() {
            resourceName = "eula_ja"
        }
        
        let path = NSBundle.mainBundle().pathForResource(resourceName, ofType: "txt")
        let eula = try? String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        
        posY = posY + titleHeight
        let textView:UITextView = UITextView(frame: CGRectMake(posX, posY, width, bodyHeight))
        textView.text = eula
        textView.editable = false // 編集不可
        self.view.addSubview(textView)
        
        // Agree Button
        posX = (width - agreeButtonWidth) / 2.0
        posY = height - footerHeight + ((footerHeight - agreeButtonHeight) / 2.0)
        let agreeButton:UIButton = UIButton(frame: CGRectMake(posX, posY, agreeButtonWidth, agreeButtonHeight))
        agreeButton.setTitle(NSLocalizedString("eula_agree_button", comment: ""), forState: UIControlState.Normal)
        agreeButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        agreeButton.addTarget(self, action: "onAgreeButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(agreeButton)
        
        // Reminder Auth
        eventStore = EventStoreReminder.sharedInstance
        allowAuthorization()
    }
    
    //-- Reminder Auth --//
    func getAuthorization_status() -> Bool {
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityType.Reminder)
        switch status {
        case EKAuthorizationStatus.NotDetermined:
            print("Reminder Auth(EULA) : NotDetermined")
            return false
            
        case EKAuthorizationStatus.Denied:
            print("Reminder Auth(EULA) : Denied")
            return false
            
        case EKAuthorizationStatus.Authorized:
            print("Reminder Auth(EULA) : Authorized")
            return true
            
        case EKAuthorizationStatus.Restricted:
            print("Reminder Auth(EULA) : Restricted")
            return false
        }
    }
    func allowAuthorization() {
        if getAuthorization_status() {
            return
        } else {
            eventStore.requestAccessToEntityType(EKEntityType.Reminder, completion: {
                (granted , error) -> Void in
                if granted {
                    return
                }
            })
        }
    }
    
    func onAgreeButton(sender:UIButton) {
        UDWrapper.setBool(UDWrapperKey.UDWrapperKeyEULA.rawValue, value: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
