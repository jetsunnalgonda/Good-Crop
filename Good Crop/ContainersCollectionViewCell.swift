//
//  ContainersCollectionViewCell.swift
//  Containers
//
//  Created by Haluk Isik on 7/29/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit

class ContainersCollectionViewCell: UICollectionViewCell
{
    // MARK: - Outlets
    
    // Photo cell
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    
    var maskLayer = CAShapeLayer()
    var dashedBorderLayer = CAShapeLayer()
    var borderLayer = CAShapeLayer()
    
    var cornerRadius: CGFloat = 10
    var isLayered = false

//    private var maskLayer = CAShapeLayer()
//    var dashedBorderLayer = CAShapeLayer()
//    var borderLayer = CAShapeLayer()
//    
//    @IBInspectable var cornerRadius: CGFloat = 10
    
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//        println("init(frame: CGRect)")
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        println("init(coder aDecoder: NSCoder)")
//        
//        setupView()
//    }
//    
//    // MARK: - Layout
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        println("layoutSubviews")
//        
//    }
    
//    // MARK: - Methods
//    
//    func setupView()
//    {
//        layoutSubviews()
//        println("cell frame = \(frame)")
//        println("cell bounds = \(bounds)")
//
//        // Set up the shape layer for the view
//        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .AllCorners, cornerRadii: CGSizeMake(cornerRadius, cornerRadius))
//        
//        let maskPath2 = UIBezierPath(roundedRect: CGRectInset(bounds, 2, 2), byRoundingCorners: .AllCorners, cornerRadii: CGSizeMake(cornerRadius, cornerRadius))
//        
//        
//        maskLayer.frame = bounds
//        maskLayer.path = maskPath.CGPath
//        maskLayer.masksToBounds = true
//        //        layer.mask = maskLayer
//        
//        //        clipsToBounds = true
//        
//        // Add shadow
//        let shadowLayer = CALayer()
//        shadowLayer.shadowPath = maskLayer.path
//        shadowLayer.frame = layer.bounds
//        shadowLayer.shadowOffset = CGSizeMake(1.0, 1.0)
//        shadowLayer.shadowRadius = 2.0
//        shadowLayer.shadowOpacity = 0.6
//        shadowLayer.shadowColor = UIColor.blackColor().CGColor
//        shadowLayer.masksToBounds = false
//        
//        // Add a stroke and set fill color
//        //        let strokeLayer = CAShapeLayer()
//        dashedBorderLayer.path = maskPath2.CGPath
//        dashedBorderLayer.frame = shadowLayer.bounds
//        dashedBorderLayer.strokeColor = UIColor.orangeColor().CGColor
//        dashedBorderLayer.fillColor = UIColor.clearColor().CGColor
//        dashedBorderLayer.lineWidth = 2.0
//        dashedBorderLayer.lineDashPattern = [8, 8]
//        dashedBorderLayer.lineCap = kCALineCapRound
//        dashedBorderLayer.lineJoin = kCALineJoinRound
//        dashedBorderLayer.masksToBounds = true
//        
//        // Add another stroke and set fill color
//        //        let strokeLayer2 = CAShapeLayer()
//        borderLayer.path = maskPath2.CGPath
//        borderLayer.frame = shadowLayer.bounds
//        borderLayer.strokeColor = UIColor.whiteColor().CGColor
//        borderLayer.fillColor = UIColor.clearColor().CGColor
//        borderLayer.lineWidth = 2.0
//        borderLayer.lineCap = kCALineCapRound
//        borderLayer.lineJoin = kCALineJoinRound
//        borderLayer.masksToBounds = true
//        
//        //        let containerLayer = CALayer()
//        
//        //        containerLayer.addSublayer(shadowLayer)
//        //        containerLayer.addSublayer(maskLayer)
//        
//        
//        shadowLayer.addSublayer(dashedBorderLayer)
//        shadowLayer.addSublayer(borderLayer)
//        layer.addSublayer(shadowLayer)
//        
//        //        strokeLayer2.hidden = true
//        //        strokeLayer.hidden = true
//        
//        //        setupAnchorView()
//        
//    }
    
}
