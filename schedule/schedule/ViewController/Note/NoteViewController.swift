//
//  NoteViewController.swift
//  ノート基底
//

import UIKit

class NoteViewController: UIViewController {
    var theme:ThemeData!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Theme
        let themeId:String = UDWrapper.getString(UDWrapperKey.UDWrapperKeyTheme.rawValue, defaultValue:"")!
        if (themeId.hasPrefix("Custom")) {
            theme = ThemeDataUtil.getCustomData()
        } else {
            theme = ThemeDataUtil.getThemeById(themeId)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
