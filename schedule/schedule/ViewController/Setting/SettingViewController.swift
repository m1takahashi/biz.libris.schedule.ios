//
//  SettingViewController.swift
//  設定基底クラス
//

import UIKit

class SettingViewController: UIViewController {
    
    var statusBarHeight:CGFloat!
    var navBarHeight:CGFloat!
    let adBannerHeight:CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        navBarHeight = self.navigationController!.navigationBar.frame.size.height
    }
    
    func initLeftBarButton() {
        let image:UIImage = UIImage(named: "Icon_Menu")!
        let imageView:UIImageView = UIImageView(image: image)
        imageView.userInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "toggleMenu")
        imageView.addGestureRecognizer(tap)
        let leftButton:UIBarButtonItem = UIBarButtonItem(customView: imageView)
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    func toggleMenu() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.drawerController.toggleLeftDrawerSideAnimated(true, completion: nil)
    }
    
    // Google Analytics
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
