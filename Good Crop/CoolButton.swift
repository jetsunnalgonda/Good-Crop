//
//  CoolView.swift
//  Good Crop
//
//  Created by Haluk Isik on 7/27/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit

/// A really cool button
@IBDesignable class CoolButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    @IBInspectable var cornerRadius: CGFloat = 0.8
    @IBInspectable var borderColor: UIColor = UIColor.lightGrayColor()
    @IBInspectable var borderWidth: CGFloat = 0.5
    @IBInspectable var shadowColor: UIColor = UIColor.grayColor()
    @IBInspectable var shadowRadius: CGFloat = 10
    @IBInspectable var shadowOpacity: Float = 0.7
    @IBInspectable var shadowOffset: CGSize = CGSizeMake(0, 0)
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.CGColor
        layer.borderWidth = borderWidth
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowColor = shadowColor.CGColor
        layer.shadowOffset = shadowOffset
    }
}
