//
//  DeviceManager.swift
//

import UIKit

// 対角インチ
enum DisplayDiagonal : NSString {
    case Diagonal55 = "55"
    case Diagonal47 = "47"
    case Diagonal40 = "40"
    case Diagonal35 = "35"
}

// ピクセル解像度（幅）論理サイズ
enum PixelResolutionWidth : NSString {
    case ResolutionWidth414 = "414" // iPhone6plus(@3x)
    case ResolutionWidth375 = "375" // iPhone6
    case ResolutionWidth320 = "320" // iPhone4s, 5, 5s
}

// ピクセル解像度（高さ）論理サイズ
enum PixelResolutionHeight : NSString {
    case PixelResolutionHeight736 = "736" // iPhone6plus(@3x)
    case PixelResolutionHeight667 = "667" // iPhone6
    case PixelResolutionHeight568 = "568" // iPhone5, 5s
    case PixelResolutionHeight480 = "480" // iPhone4s
}

class DeviceManager: NSObject {
    
    // ピクセル解像度（幅）取得
    class func getPixelResolutionWidth() -> PixelResolutionWidth {
        let size: CGSize = UIScreen.mainScreen().bounds.size
        let width = size.width
        if width == 414 {
            return .ResolutionWidth414
        } else if width == 375 {
            return .ResolutionWidth375
        } else {
            return .ResolutionWidth320
        }
    }
    
    class func getPixelResolutionHeight() -> PixelResolutionHeight {
        let size: CGSize = UIScreen.mainScreen().bounds.size
        let height = size.height
        if height == 736 {
            return .PixelResolutionHeight736
        } else if height == 667 {
            return .PixelResolutionHeight667
        } else if height == 568 {
            return .PixelResolutionHeight568
        } else {
            return .PixelResolutionHeight480
        }
    }
    
    /**
     * 対角インチ取得
     * note:
     * iPad miniとiPad mini 2のように対角インチが同様でも、ピクセル解像度が異なるものがある
     */
    class func getDisplayDiagonal()-> DisplayDiagonal {
        let size: CGSize = UIScreen.mainScreen().bounds.size
        let width = size.width
        let height = size.height
        if width == 414 && height == 736 {
            return .Diagonal55
        } else if width == 375 && height == 667 {
            return .Diagonal47
        } else if width == 320 && height == 568 {
            return .Diagonal40
        } else {
            return .Diagonal35
        }
    }
}
