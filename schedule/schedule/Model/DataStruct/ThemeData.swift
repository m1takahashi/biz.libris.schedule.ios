//
//  ThemeData.swift
//
import UIKit

enum ThemeType {
    case ThemeTypeImage
    case ThemeTypeColor
    case ThemeTypeCustom
}

// テーマのデータ構造
struct ThemeData {
    var id: String!
    var name: String!
    var navBg: String!
    var navText: String!
    var tabSegctr: String!
    var type: ThemeType
}

class ThemeDataUtil {
    class func setThemeData(dic:Dictionary<String, AnyObject>, type:ThemeType) -> ThemeData {
        let data:ThemeData = ThemeData(id: dic["id"] as! String,
            name: dic["name"] as! String,
            navBg: dic["nav_bg"] as! String,
            navText: dic["nav_text"] as! String,
            tabSegctr: dic["tab_segctr"] as! String,
            type: type)
        return data
    }
    
    class func getCustomData() -> ThemeData {
        let registerdTheme:String = UDWrapper.getString(UDWrapperKey.UDWrapperKeyTheme.rawValue, defaultValue: "Custom_01")!
        let registerdCustomNavBarColor:String = UDWrapper.getString(UDWrapperKey.UDWrapperKeyCustomNavBarColor.rawValue, defaultValue: "333333")!
        let registerdCustomNavTextColor:String = UDWrapper.getString(UDWrapperKey.UDWrapperKeyCustomNavTextColor.rawValue, defaultValue: "FFFFFF")!
        print("Reg Theme      : \(registerdTheme)")
        print("Reg Custom Bar : \(registerdCustomNavBarColor)")
        print("Reg Custom Bar : \(registerdCustomNavTextColor)")
        let data:ThemeData = ThemeData(id: registerdTheme,
            name: registerdTheme,
            navBg: registerdCustomNavBarColor,
            navText: registerdCustomNavTextColor,
            tabSegctr: registerdCustomNavBarColor,
            type: ThemeType.ThemeTypeCustom)
        return data
    }

    // ナビゲーション背景をUIColorに統一して返す
    class func getNavigationColor(param:ThemeData) -> UIColor {
        var color:UIColor!
        switch param.type {
        case .ThemeTypeColor:
            color = UIColor(hexString: param.navBg, alpha: 1.0)
        case .ThemeTypeImage:
            let diagonal:DisplayDiagonal = DeviceManager.getDisplayDiagonal()
            let imageNavName: String = param.id + "_" + (diagonal.rawValue as String) + "_Nav"
            print("Name : \(imageNavName)")
            let imageNav:UIImage = UIImage(named: imageNavName)!
            color = UIColor(patternImage: imageNav)
        case .ThemeTypeCustom:
            color = UIColor(hexString: param.navBg, alpha: 1.0)
        }
        return color
    }
    
    // ドローワー背景をUIColorに統一して返す
    class func getDrawerColor(param:ThemeData) -> UIColor {
        var color:UIColor!
        switch param.type {
        case .ThemeTypeImage:
            let diagonal:DisplayDiagonal = DeviceManager.getDisplayDiagonal()
            let imageName: NSString = param.id + "_" + (diagonal.rawValue as String) + "_Drawer"
            let image:UIImage = UIImage(named: imageName as String)!
            color = UIColor(patternImage: image)
            break;
        case ThemeType.ThemeTypeColor:
            color = UIColor.whiteColor()
            break;
        case .ThemeTypeCustom:
            color = UIColor.whiteColor()
            break;
        }
        return color
    }
    
    // カラーテーマ一覧取得
    class func getColorList() -> [ThemeData] {
        var list:[ThemeData] = []
        let filePath:NSString = NSBundle.mainBundle().pathForResource("ThemeColor", ofType:"plist")!
        var tmp:[Dictionary<String, AnyObject>] = NSArray(contentsOfFile: filePath as String) as! [Dictionary<String, AnyObject>]
        for (var i = 0; i < tmp.count; i++) {
            let dic:Dictionary = tmp[i]
            let data:ThemeData = ThemeDataUtil.setThemeData(dic, type: ThemeType.ThemeTypeColor)
            list.append(data)
        }
        return list;
    }

    // 画像テーマ一覧取得
    class func getImageList() -> [ThemeData] {
        var list:[ThemeData] = []
        let filePath:NSString  = NSBundle.mainBundle().pathForResource("ThemeImage", ofType:"plist")!
        var tmp:[Dictionary<String, AnyObject>] = NSArray(contentsOfFile: filePath as String) as! [Dictionary<String, AnyObject>]
        for (var i = 0; i < tmp.count; i++) {
            let dic:Dictionary = tmp[i]
            let data:ThemeData = ThemeDataUtil.setThemeData(dic, type: ThemeType.ThemeTypeImage)
            list.append(data)
        }
        return list
    }

    // デフォルトテーマ取得（とりあえず、画像の一番目）
    class func getDefaultTheme() -> ThemeData {
        var list:[ThemeData] = ThemeDataUtil.getImageList()
        return list[0]
    }
    
    // テーマ取得
    class func getThemeById(id:String) -> ThemeData {
        var list:[ThemeData] = []
        // Theme_01, Color_01
        var prefix:[String] = id.componentsSeparatedByString("_")
        if prefix[0] == "Theme"  {
            list = ThemeDataUtil.getImageList()
        } else if prefix[0] == "Color" {
            list = ThemeDataUtil.getColorList()
        }
        // 検索
        for (var i = 0; i < list.count; i++) {
            let tmp:ThemeData = list[i]
            if (tmp.id == id) {
                return list[i]
            }
        }
        return ThemeDataUtil.getDefaultTheme()
    }    
}