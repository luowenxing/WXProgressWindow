//
//  extensions.swift
//  WXProgressWindow
//
//  Created by Luo on 7/14/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

extension UIScreen {
    var compatibleBounds:CGRect{//iOS7 mainScreen bounds 不随设备旋转
        var rect = self.bounds
        if NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0 {
            let orientation = UIApplication.sharedApplication().statusBarOrientation
            if orientation.isLandscape{
                rect.size.width = self.bounds.height
                rect.size.height = self.bounds.width
            }
        }
        return rect
    }
}

extension UIColor {
    class func hexColor(hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

