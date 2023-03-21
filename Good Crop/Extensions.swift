//
//  Extensions.swift
//  Good Crop
//
//  Created by Haluk Isik on 7/25/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import Foundation
import UIKit

extension UIColor
{
    convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = rgba.startIndex.advancedBy(1)
            let hex     = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (hex.characters.count) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8", terminator: "")
                }
            } else {
                print("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix", terminator: "")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}

extension UIView {
    
    func show(duration: NSTimeInterval = 0.6, delay: NSTimeInterval = 0.0, damping: CGFloat = 0.6, velocity: CGFloat = 1.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in })
    {
//        println("self = \(self)")
        
//        if let parent = self.parentViewOfType(UIView) {
//            println("parent = \(parent)")
//        }
        
//        println("self.superview = \(self.superview)")
        
        self.frame.size.width = superview!.frame.width
        self.frame.origin = CGPointMake(0, superview!.frame.height)
        
        self.frame.size.height = 200

        //self.frame = CGRectMake(origin.x, origin.y + height / 2, width, 0.0
        
        UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [], animations: { [unowned self] () -> Void in
            self.frame.origin = CGPointMake(0, self.superview!.frame.height - self.frame.height)
//            constraint3.constant = 0.0
            }, completion: nil )
        
    }
    
    func hide(duration: NSTimeInterval = 0.9, delay: NSTimeInterval = 0.0, damping: CGFloat = 0.9, velocity: CGFloat = 1.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in })
    {
        
        //self.frame = CGRectMake(origin.x, origin.y + height / 2, width, 0.0)
        
        UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [], animations:
            {
                self.frame.origin = CGPointMake(0, self.superview!.frame.height)
                
            }, completion: { (complete: Bool) in self.removeFromSuperview() } )
        
    }
    
    func snapBack(duration: NSTimeInterval = 0.6)
    {
        

        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: [], animations: {
            
            self.frame.origin = CGPointMake(0, self.superview!.frame.height - self.frame.height)
            //            constraint3.constant = 0.0
            }, completion: nil )
        
    }
    
    func changeHeight(height: CGFloat = 100)
    {
        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: [], animations: {
            
            self.frame.size.height = height
            }, completion: nil )
        
    }
    
    func parentViewOfType<T>(type: T.Type) -> T? {
        var currentView = self
        while currentView.superview != nil {
            if currentView is T {
                return currentView as? T
            }
            currentView = currentView.superview!
        }
        return nil
    }
    
    func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        
//        let previousContentMode = contentMode
        contentMode = .ScaleAspectFill
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        
        contentMode = .ScaleAspectFit
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    /// Applies rounded corners and returns a **CAShapeLayer**
    func applyRoundCorners(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer
    {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSizeMake(radius, radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.CGPath
        
        layer.mask = maskLayer
        
        return maskLayer
    }
    
    /**
    Applies rounded corners and returns a **CAShapeLayer** without a mask
    
    */
    func getRoundCorneredLayer(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer
    {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSizeMake(radius, radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.CGPath
        
        //        layer.masksToBounds = true
        
        return maskLayer
    }
}

extension CGFloat {
    var dbl: Double {
        get {
            return Double(self)
        }
    }
    var int: Int {
        return Int(self)
    }
}
extension Double {
    var fl: CGFloat {
        get {
            return CGFloat(self)
        }
    }
    mutating func snapToValues(valueArray: [Double], tolerance: Double = 0.05)
    {
        for value in valueArray {
            if ((self - tolerance) < value) && ((self + tolerance) >= value) {
                self = value
                break
            }
        }
    }
}
extension Int {
    var fl: CGFloat {
        get {
            return CGFloat(self)
        }
    }
    var f: Float {
        get {
            return Float(self)
        }
    }
    var rf: Float {
        get {
            return round(Float(self) * 100) / 100
        }
    }
}

extension Float
{
    var rf: Float {
        get {
            return round(self * 100) / 100
        }
    }
    /// changes the value to the snapped value
    mutating func snapToValues(valueArray: [Float], tolerance: Float = 0.07)
    {
        for value in valueArray {
            if ((self - tolerance) < value) && ((self + tolerance) >= value) {
                self = value
                break
            }
        }
    }
    /// returns the snapped value
    func getSnappedValue(valueArray: [Float], tolerance: Float = 0.05) -> Float
    {
        for value in valueArray {
            if ((self - tolerance) < value) && ((self + tolerance) >= value) {
                return value
            }
        }
        return self
    }

    mutating func snapToValues(nominators: [Int], denominators: [Int], tolerance: Float = 0.05)
    {
        if nominators.count == denominators.count {
            for (key, nominator) in nominators.enumerate() {
                let value: Float = Float(nominator) / Float(denominators[key])
                if ((self - tolerance) < value) && ((self + tolerance) >= value) {
                    print("found value is \(value)")
                    print("array order is \(key)")

                    self = value
                    break
                }
            }
        }
    }

}

extension UIImage
{
    func flippedOrientation() -> UIImageOrientation
    {
        switch imageOrientation {
        case .Down:
            return .DownMirrored
            
        case .DownMirrored:
            return .Down
        
        case .Left:
            return .LeftMirrored
            
        case .LeftMirrored:
            return .Left

        case .Right:
            return .RightMirrored
            
        case .RightMirrored:
            return .Right

        case .Up:
            return .UpMirrored
            
        case .UpMirrored:
            return .Up

//        default:
//            break
        }
        
    }
    func verticalFlippedOrientation() -> UIImageOrientation
    {
        switch imageOrientation {
        case .Down:
            return .DownMirrored
            
        case .DownMirrored:
            return .Down
            
        case .Left:
            return .RightMirrored
            
        case .LeftMirrored:
            return .Right
            
        case .Right:
            return .LeftMirrored
            
        case .RightMirrored:
            return .Left
            
        case .Up:
            return .UpMirrored
            
        case .UpMirrored:
            return .Up
            
//        default:
//            break
        }
        
    }
}
public func simplify(top:Int, bottom:Int) -> (newTop:Int, newBottom:Int) {
    
    var x = top
    var y = bottom
    while (y != 0) {
        let buffer = y
        y = x % y
        x = buffer
    }
    let hcfVal = x
    let newTopVal = top/hcfVal
    let newBottomVal = bottom/hcfVal
    return(newTopVal, newBottomVal)
}
//extension JMMarkSlider
//{
//    override public func trackRectForBounds(bounds: CGRect) -> CGRect {
//        //keeps original origin and width, changes height, you get the idea
//        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 50.0))
//        super.trackRectForBounds(customBounds)
//        return customBounds
//    }
//    
//    //while we are here, why not change the image here as well? (bonus material)
////    override public func awakeFromNib() {
////        self.setThumbImage(UIImage(named: "customThumb"), forState: .Normal)
////        super.awakeFromNib()
////    }
//}