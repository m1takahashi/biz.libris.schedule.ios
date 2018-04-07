import UIKit
import EventKit

class ReminderListEditViewController : ReminderViewController, UITextFieldDelegate {
    var calendar:EKCalendar!
    var textField:UITextField!
    
    let textFeildWidth:CGFloat  = 200.0
    let textFeildHeight:CGFloat = 30.0
    
    let minLength:Int = 1
    let maxLength:Int = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = NSLocalizedString("reminder_calendar_add", comment: "")
        
        let rightButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done,
            target:self,
            action: "onSaveButton:")
        self.navigationItem.rightBarButtonItem = rightButton
        
        let x:CGFloat = (self.view.frame.size.width - textFeildWidth) / 2
        let y:CGFloat = 80.0
        
        textField = UITextField(frame: CGRectMake(x, y, textFeildWidth, textFeildHeight))
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.returnKeyType = .Done;
        textField.delegate = self
        self.view.addSubview(textField)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if calendar != nil {
            textField.text = calendar.title
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        calendar = nil
        super.viewWillDisappear(animated)
    }
    
    func onSaveButton(sender: UIBarButtonItem) {
        if !save() {
            return
        }
        textField.resignFirstResponder()
        popViewControllerWithAlart()
    }
    
    //-- TextFeild Delegate --//
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if !save() {
            return false
        }
        textField.resignFirstResponder()
        popViewControllerWithAlart()
        return true
    }
    
    // 保存処理
    func save() -> Bool {
        let title:String = textField.text!
        
        // 入力チェック
        if !TextValidation.length(title, min: minLength, max: maxLength) {
            self.view.makeToast(NSLocalizedString("msg_reminder_length", comment: ""),
                duration: (NSTimeInterval)(2.0),
                position: CSToastPositionCenter)
            return false
        }
        
        if (calendar != nil) {
            // Edit
            calendar.title = title

        } else {
            // Add New
            calendar = EKCalendar(forEntityType: EKEntityType.Reminder, eventStore: eventStore)
            calendar.title = title
            
            var theSource:EKSource!
            for source in eventStore.sources {
                if (source.sourceType.rawValue == EKSourceType.Local.rawValue) {
                    theSource = source 
                    break;
                }
            }
            calendar.source = theSource
            
            print("New Calendar ID : \(calendar.calendarIdentifier)")
            ReminderSeq.addSortData(calendar.calendarIdentifier)
        }
        var writeError: NSError?
        do {
            try eventStore.saveCalendar(calendar, commit: true)
        } catch let error1 as NSError {
            writeError = error1
            if let error = writeError {
                print("Error, Reminder write failure: \(error.localizedDescription)")
            }
        }
        
        return true
    }
    
    // 画面を閉じる（ListViewのリロード不安定対策）
    func popViewControllerWithAlart() {
        let alertController = UIAlertController(title: "",
            message: NSLocalizedString("msg_reminder_list_saved" , comment: ""),
            preferredStyle: .Alert)
        
        let positiveAction = UIAlertAction(title: NSLocalizedString("reminder_button_positive", comment: ""), style: .Default) {
            action in
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        alertController.addAction(positiveAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
