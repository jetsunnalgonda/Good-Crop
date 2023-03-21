//
//  Anchor.swift
//  Good Crop
//
//  Created by Haluk Isik on 9/10/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import Foundation

class Anchor
{
    private var anchorRadius: CGFloat = 10
    var anchorView: UIView!
    private var touchView: UIView!
    
    private var anchorViewShapeLayer = CAShapeLayer()
    var touchViewShapeLayer = CAShapeLayer()
    var anchorPointIsBeingDragged = false
    
    var anchorPoint = CGPointZero {
        didSet {
            let spacing = self.spacing ?? 0
            anchorPoint.x = max(min(bounds.width - spacing / 2, anchorPoint.x), spacing / 2)
            anchorPoint.y = max(min(bounds.height - spacing / 2, anchorPoint.y), spacing / 2)
            for wrapperView in wrapperViews {
                wrapperView.anchorPoint = anchorPoint
            }
            if anchorView != nil { updateAnchorView() }
        }
    }
    
    init()
    {
        
    }
}