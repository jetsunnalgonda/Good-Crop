//
//  ShapedScrollContainerView.swift
//  Shape Views
//
//  Created by Haluk Isik on 8/9/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit

protocol ShapedScrollContainerViewDelegate: class {
    var anchorPoints: [CGPoint] { get set }
}

class ShapedScrollContainerView: UIView, UIScrollViewDelegate
{
    // MARK: - Constants
    let CGFloatZero: CGFloat = 0.0
    
    // MARK: - Types
    
//    enum CompositionType {
//        case One  // Choose a better name!
//    }
    
    // MARK: - Properties
    
    weak var shapedScrollContainerViewDelegate: ShapedScrollContainerViewDelegate?
    
    var anchorPoints = [CGPoint]() {
        didSet {
            println("anchorPoint did set (ShapedScrollContainerView)")
            println("anchorPoint = \(anchorPoints)")
            setNeedsLayout()
        }
    }
    var spacing: CGFloat?
    
    var imageContentMode = UIViewContentMode.ScaleAspectFill {
        didSet {
            scrollView.contentMode = imageContentMode
            scrollView.minimumZoomScale = scrollView.findMinimumZoomScale()
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
    }

    var scrollView: ShapedScrollView!
    
    private let shapeLayer = CAShapeLayer()
    private let strokeLayer = CAShapeLayer()
    
    var compositionType: CompositionType = .One {
        didSet { setNeedsLayout() }
    }
    
    var imageView = UIImageView()
    
    var image: UIImage? {
        didSet {
            if image != oldValue {
                imageView.image = image
                imageView.frame = bounds
                imageView.sizeToFit()
                imageView.frame.origin = CGPointZero
                scrollView.contentSize = imageView.bounds.size
                println("scrollView.contentSize = \(scrollView.contentSize)")
                
                println("imageView.frame.size = \(imageView.frame.size)")
                scrollView.contentMode = imageContentMode
                scrollView.minimumZoomScale = scrollView.findMinimumZoomScale()
                scrollView.zoomScale = scrollView.minimumZoomScale
                println("scrollView.minimumZoomScale = \(scrollView.minimumZoomScale)")

            }
        }
    }

    // MARK: - Initializers
    
    init(frame: CGRect, compositionType: CompositionType = .One) {
        self.compositionType = compositionType
        super.init(frame: frame)
        self.layer.addSublayer(strokeLayer)
//        self.layer.addSublayer(shapeLayer)
        scrollView = ShapedScrollView() //frame: self.bounds)
//        self.scrollView = scrollView
//        scrollView.frame = self.bounds
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.addSubview(scrollView)
        
//        scrollView.contentMode = UIViewContentMode.ScaleAspectFill
        
        imageView.frame = self.bounds
        imageView.sizeToFit()
        scrollView.addSubview(imageView)
        println("scroll view added")
        println("imageView.frame = \(imageView.frame)")
//        println("bounds = \(bounds)")
//        println("frame = \(frame)")
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShape()
    }
    
    // MARK: - Updating the Shape
    
    private func updateShape() {
        
        // Disable core animation actions to prevent changes to the shape layer animating implicitly
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        shapeLayer.path = pathForShape()
        
        // Second one is for iteration
        // We calculate frame size which is also defined by the path drawn
        // therefore we need this ugly code for now
        shapeLayer.path = pathForShape()

        scrollView.frame = bounds
        shapeLayer.frame = bounds
//        layer.borderWidth = 2.0
//        layer.borderColor = UIColor.blueColor().CGColor
        
        // Draw our nice little dashed lines around the frame
        // If there is not an image for a certain view,
        // we will see dashed lines outlining the frame borders;
        // if there is an image, however, then the lines will be obscured,
        // but we will be able to peek at them if we scroll past the boundaries. Neat!
        strokeLayer.frame = bounds
        strokeLayer.path = shapeLayer.path
        strokeLayer.strokeColor = UIColor.orangeColor().CGColor
        strokeLayer.fillColor = UIColor.clearColor().CGColor
        strokeLayer.lineWidth = 3.0
        strokeLayer.lineDashPattern = [3, 3]
        strokeLayer.lineCap = kCALineCapButt
        strokeLayer.lineJoin = kCALineJoinRound
        
//        imageView.sizeToFit()

//        println("imageView.frame = \(imageView.frame)")
//        
//        println("bounds = \(bounds)")
//        println("shapeLayer.frame = \(shapeLayer.frame)")

        layer.mask = shapeLayer
        
        CATransaction.commit()
    }
    
    private func pathForShape() -> CGPath
    {
        var path = [CGMutablePathRef]()
        var path2 = UIBezierPath()
        path2.lineJoinStyle = kCGLineJoinRound
        
        for i in 0...3 {
            path.append(CGPathCreateMutable())
        }
        
        // Get anchorPoint
        var anchorPoint = CGPointZero
        var anchorPoint2 = CGPointZero
        if self.anchorPoints.count == 1 {
            anchorPoint = self.anchorPoints[0]
        } else if self.anchorPoints.count == 2 {
            anchorPoint2 = self.anchorPoints[1]
        }
//        let anchorPoint = self.anchorPoint.first ?? CGPointZero
        
        // Get borderWidth, which is the spacing between the views
        let _spacing = self.spacing ?? 0.0
        let spacing = Double(_spacing)
        
        //define frame constants
        let x = bounds.width
        let y = bounds.height
        let X = superview!.bounds.width
        let Y = superview!.bounds.height
        
        switch compositionType {
            // MARK: Composition Type 1
        case .One:
            // Variables related with Composition Type 1
            // These are going to be used in offset calculations,
            // which are required to create frames for the views when
            // a spacing value is set.
            let dx = spacing / 2
            var angle: Double = atan((anchorPoint.x.dbl - dx) / (anchorPoint.y.dbl - dx))
//            println("anchorPoint = \(anchorPoint)")
            if angle.isNaN { angle = 0.0 }
//            println("spacing = \(spacing)")
            
            let tan_a = min(tan(angle), 1)
            let tan_a_2 = min(tan(angle / 2), 1)
//            println("tan_a = \(tan_a)")

            /// Top right view, bottom left corner vertical offset
            let offset1 = min(dx * tan((M_PI / 2 - angle) / 2), Double(Y))
            /// Top left view, top right corner vertical offset
            let offset2 = dx * tan(angle / 2)
            /// Top left view, top left corner vertical offset
            let offset3 = dx / tan(angle) + dx / sin(angle) - dx
            /// Top right view, top left corner horizontal offset
            let offset4 = dx * tan(angle) + dx / cos(angle)
            
//            println("angle = \(angle)")
            
            // Top left view for Composition Type 1
            
            // Convert anchor point to frame coordinates
            // For y coordinate, we go up with an offset of spacing/2,
            // because of the way we calculate the top right offset for this view
            var point0 = CGPoint()
            point0.x = max(anchorPoint.x.dbl - spacing, 0.0).fl
            point0.y = min(max(anchorPoint.y.dbl - offset3 - dx, 0.0), y.dbl + spacing).fl
            
//            println("point0 = \(point0)")
            // Prevents negative stroking for top left view
            var dyy = max(point0.y.dbl + offset2 - dx - y.dbl, 0.0)
            var dxx = (x.dbl * dyy) / (dyy - y.dbl)
            if dxx.isNaN { dxx = 0.0 }

//            println("point0.y.dbl + offset2 - dx - y.dbl = \(point0.y.dbl + offset2 - dx - y.dbl)")
//            println("dyy = \(dyy)")

            
            CGPathMoveToPoint(path[0], nil, 0, 0)
            CGPathAddLineToPoint(path[0], nil, 0, y)
            CGPathAddLineToPoint(path[0], nil, max(point0.x.dbl - dx, 0.0).fl, y)
            CGPathAddLineToPoint(path[0], nil, max(point0.x.dbl - dx + dxx, 0.0).fl, max(point0.y.dbl + offset2 - dx - dyy, 0.0).fl)
            CGPathCloseSubpath(path[0])
            
//            println("point-2: \(0, y)")
//            println("point-3: \(point0.x - dx.fl, y)")
//            println("point-4: \(point0.x - dx.fl, point0.y + offset2.fl - dx.fl)")
//            println("dxx = \(dxx)")
//            println("dyy = \(dyy)")


            // Bottom right view for Composition Type 1
            CGPathMoveToPoint(path[1], nil, 0, 0)
            CGPathAddLineToPoint(path[1], nil, 0, y)
            CGPathAddLineToPoint(path[1], nil, x, y)
            CGPathAddLineToPoint(path[1], nil, x, 0)
            CGPathCloseSubpath(path[1])
            
            // Top right view for Composition Type 1
            // Convert anchor point to frame coordinates
            // For x coordinate, we go left with an additional offset of spacing/2,
            // because of the way we calculate the bottom left offset for this view
            point0.x = min(max(anchorPoint.x.dbl - offset4, 0.0), x.dbl + dx * 2).fl
            point0.y = min(max(anchorPoint.y.dbl - spacing, 0.0), y.dbl - dx * 2).fl
            
            // Prevents negative stroking for top right view
            dxx = max(point0.x.dbl + offset1 - dx - x.dbl, 0.0)
            dyy = (y.dbl * dxx) / x.dbl
            if dyy.isNaN || dyy.isInfinite { dyy = 0.0 }
//            println("dxx = \(dxx)")
//            println("dyy = \(dyy)")

            CGPathMoveToPoint(path[2], nil, 0, 0)
            CGPathAddLineToPoint(path[2], nil, max(point0.x.dbl + offset1 - dx - dxx, 0.0).fl, y - dyy.fl)
            CGPathAddLineToPoint(path[2], nil, x, y)
            CGPathAddLineToPoint(path[2], nil, x, 0)
            CGPathCloseSubpath(path[2])
            
//            println("offset1 = \(offset1)")
//            println("offset2 = \(offset2)")
//            println("offset3 = \(offset3)")
//            println("offset4 = \(offset4)")

            
//            let tag2 = 2
            // Update view frame for Composition Type 1
            switch tag {
            case 0: // Top left
//                println("tag = \(tag)")
//                frame = CGRectMake(borderWidth, offset1, anchorPoint.x - borderWidth, Y)
                frame = CGRectMake(_spacing, max(offset3 + spacing, spacing).fl, max(anchorPoint.x.dbl - spacing - dx, 0.0).fl, max(Y.dbl - offset3 - dx * 4, 0.0).fl)
//                println("frame = \(frame)")
            case 1: // Bottom right
//                println("tag = \(tag)")
                frame = CGRectMake(max(anchorPoint.x.dbl + dx, dx).fl, max(anchorPoint.y.dbl + dx, 0.0).fl, max(X.dbl - anchorPoint.x.dbl - dx * 3, 0.0).fl, max(Y.dbl - anchorPoint.y.dbl - dx * 3, 0.0).fl)
            case 2: // Top right
//                println("tag = \(tag)")
                frame = CGRectMake(max(offset4 + dx, dx).fl, spacing.fl, max(X.dbl - dx * 3 -  offset4, 0.0).fl, max(anchorPoint.y.dbl - dx * 3, 0.0).fl)
//                println("offset3 = \(offset3)")

            default:
//                println("tag = \(tag)")
//                frame = bounds
                break
            }
            // MARK: Composition Type 2
        case .Two:
            // Variables related with Composition Type 2
            // These are going to be used in offset calculations,
            // which are required to create frames for the views when
            // a spacing value is set.
            let dx = spacing / 2
            var angle: Double = atan((X.dbl - anchorPoint.x.dbl - dx) / (anchorPoint.y.dbl - dx))
            //            println("anchorPoint = \(anchorPoint)")
            if angle.isNaN { angle = 0.0 }
            //            println("spacing = \(spacing)")
            
            let tan_a = min(tan(angle), 1)
            let tan_a_2 = min(tan(angle / 2), 1)
            //            println("tan_a = \(tan_a)")
            
            /// Top left view, bottom right corner horizontal offset
            let offset1 = min(dx * tan((M_PI / 2 - angle) / 2), Y.dbl)
            /// Top right view, top left corner vertical offset
            let offset2 = dx * tan(angle / 2)
//            let offset2 = dx - (dx - dx * sin((M_PI / 2 - angle) / 2)) / tan(angle)

            /// Top right view, top right corner vertical offset
            let offset3 = dx / tan(angle) + dx / sin(angle) - dx
            /// Top left view, top right corner horizontal offset
            let offset4 = dx * tan(angle) + dx / cos(angle)
            
            
            // Top left view for Composition Type 2
            // Convert anchor point to frame coordinates
            // For x coordinate, we go left with an offset of spacing/2,
            // because of the way we calculate the bottom left offset for this view
            var point0 = CGPoint()
            point0.x = anchorPoint.x - spacing.fl //min(max(anchorPoint.x.dbl - spacing, -20.0), x.dbl + dx * 4).fl
            point0.y = anchorPoint.y - spacing.fl - dx.fl //min(max(anchorPoint.y.dbl - spacing, -20.0), y.dbl + dx * 4).fl
            
            // Prevents negative stroking for top left view
            // When the anchor point goes past a certain point,
            // this dxx becomes negative.
            // the offset1 portion is neccessary, because normally the bottom right corner has always a certain offset
            // But we only allow this offset to be 0 if we move the anchor point to a position so that that side of our rectangle should be zero, making our shape a triangle.
            var dxx = min(point0.x.dbl - offset1, 0.0)
            var dyy = (y.dbl * dxx) / (x.dbl - dx)
            if dyy.isNaN || dyy.isInfinite { dyy = 0.0 }
//                        println("dxx = \(dxx)")
//                        println("dyy = \(dyy)")
            
            
//            println("point0 = \(point0)")
            
            CGPathMoveToPoint(path[0], nil, 0, 0)
            CGPathAddLineToPoint(path[0], nil, 0, y)
            CGPathAddLineToPoint(path[0], nil, point0.x - offset1.fl - dxx.fl, y + dyy.fl)
            CGPathAddLineToPoint(path[0], nil, x, 0)
            CGPathCloseSubpath(path[0])
            
            // Bottom left view for Composition Type 2
            CGPathMoveToPoint(path[1], nil, 0, 0)
            CGPathAddLineToPoint(path[1], nil, 0, y)
            CGPathAddLineToPoint(path[1], nil, x, y)
            CGPathAddLineToPoint(path[1], nil, x, 0)
            CGPathCloseSubpath(path[1])
            
            // Top right view for Composition Type 2
            
            // Convert anchor point to frame coordinates
            // For y coordinate, we go up with an additional offset of spacing/2,
            // because of the way we calculate the top right offset for this view
            point0.x = anchorPoint.x - spacing.fl * 2 //max(anchorPoint.x.dbl - spacing, -20.0).fl
//            point0.y = anchorPoint.y - spacing.fl * 2 - dx.fl - offset2.fl //min(max(anchorPoint.y.dbl - offset2 - dx, -20.0), y.dbl + spacing).fl
            point0.y = min(max(anchorPoint.y.dbl - offset3 - dx, 0.0), y.dbl + spacing).fl

            
            //            println("point0 = \(point0)")
            // Prevents negative stroking for top right view
            // (offset2 - dx) is the amount we allow to be zero,
            // that way the shape can be a triangle, otherwise it would always be a rectangle, except a point where we are calculating
            // In other words, if we go past that point, we make the sucker always be a triangle
            dyy = max(point0.y.dbl - y.dbl + offset2 - dx, 0.0)
            // find dxx using similar triangles theorem
            dxx = (x.dbl * dyy) / (dyy - y.dbl)
            if dxx.isNaN { dxx = 0.0 }
            
//            if tag == 2 {
//                println("")
//                println("tag = \(tag)")
//                println("")
//                println("offset1 = \(offset1)")
//                println("offset2 = \(offset2)")
//                println("offset3 = \(offset3)")
//                println("offset4 = \(offset4)")
//                println("")
//                println("dxx = \(dxx)")
//                println("dyy = \(dyy)")
//                println("")
//                println("point0 = \(point0)")
//                println("anchorPoint.y = \(anchorPoint.y)")
//                println("y = \(y)")
//                println("point0.y - y = \(point0.y - y)")
//                println("anchorPoint.y - Y - spacing.fl = \(anchorPoint.y - Y - spacing.fl)")
//                println("")
//                println("(offset3 - spacing) = \((offset3 - spacing))")
//                println("")
//
//            }
            
            CGPathMoveToPoint(path[2], nil, -dxx.fl, point0.y - dx.fl + offset2.fl - dyy.fl)
            CGPathAddLineToPoint(path[2], nil, 0, y)
            CGPathAddLineToPoint(path[2], nil, x, y)
            CGPathAddLineToPoint(path[2], nil, x, 0)
            CGPathCloseSubpath(path[2])

//            println("offset1 = \(offset1)")
//            println("offset2 = \(offset2)")
//            println("offset3 = \(offset3)")
//            println("offset4 = \(offset4)")
            
            
//            CGPathMoveToPoint(path[0], nil, 0, 0)
//            CGPathAddLineToPoint(path[0], nil, 0, y)
//            CGPathAddLineToPoint(path[0], nil, max(point0.x.dbl - dx, 0.0).fl, y)
//            CGPathAddLineToPoint(path[0], nil, max(point0.x.dbl - dx + dxx, 0.0).fl, max(point0.y.dbl + offset2 - dx - dyy, 0.0).fl)
//            CGPathCloseSubpath(path[0])
            
            
            // Update view frame for Composition Type 2
            switch tag {
            case 0: // Top left

                frame = CGRectMake(
                    _spacing,
                    _spacing,
                    max(X.dbl - dx * 3 - offset4, 0.0).fl,
                    max(anchorPoint.y.dbl - dx * 3, 0.0).fl)
                

            case 1: // Bottom left

                frame = CGRectMake(
                    _spacing,
                    max(anchorPoint.y.dbl + dx, 0.0).fl,
                    max(anchorPoint.x.dbl - dx * 3, 0.0).fl,
                    max(Y.dbl - anchorPoint.y.dbl - dx * 3, 0.0).fl)

            case 2: // Top right

                frame = CGRectMake(
                    max(anchorPoint.x.dbl + dx, 0.0).fl,
                    max(offset3 + spacing, spacing).fl,
                    max(X.dbl - anchorPoint.x.dbl - spacing - dx, 0.0).fl,
                    max(Y.dbl - offset3 - dx * 4, 0.0).fl)
                
            default:

                break
            }
            // MARK: Composition Type 3
        case .Three:
            // Variables related with Composition Type 3
            // These are going to be used in offset calculations,
            // which are required to create frames for the views when
            // a spacing value is set.
            let dx = spacing / 2
            var angle: Double = atan((X.dbl - anchorPoint.x.dbl - dx) / (Y.dbl - anchorPoint.y.dbl - dx))
            //            println("anchorPoint = \(anchorPoint)")
            if angle.isNaN { angle = 0.0 }
            //            println("spacing = \(spacing)")
            
            let tan_a = min(tan(angle), 1)
            let tan_a_2 = min(tan(angle / 2), 1)
            //            println("tan_a = \(tan_a)")
            
            /// Bottom left view, top right corner horizontal offset
            let offset1 = min(dx * tan((M_PI / 2 - angle) / 2), Y.dbl)
            /// Top right view, bottom left corner vertical offset
            let offset2 = dx * tan(angle / 2)
            //            let offset2 = dx - (dx - dx * sin((M_PI / 2 - angle) / 2)) / tan(angle)
            
            /// Top right view, bottom right corner vertical offset
            let offset3 = dx / tan(angle) + dx / sin(angle) - dx
            /// Bottom left view, bottom right corner horizontal offset
            let offset4 = dx * tan(angle) + dx / cos(angle)
            
            
            // Top left view for Composition Type 2
            CGPathMoveToPoint(path[0], nil, 0, 0)
            CGPathAddLineToPoint(path[0], nil, 0, y)
            CGPathAddLineToPoint(path[0], nil, x, y)
            CGPathAddLineToPoint(path[0], nil, x, 0)
            CGPathCloseSubpath(path[0])
            
            // Bottom left view for Composition Type 3
            // Convert anchor point to frame coordinates
            // For x coordinate, we go left with an offset of spacing/2,
            // because of the way we calculate the bottom left offset for this view
            var point0 = CGPoint()
            point0.x = anchorPoint.x - spacing.fl //min(max(anchorPoint.x.dbl - spacing, -20.0), x.dbl + dx * 4).fl
            point0.y = anchorPoint.y - spacing.fl - dx.fl //min(max(anchorPoint.y.dbl - spacing, -20.0), y.dbl + dx * 4).fl
            
            // Prevents negative stroking for top left view
            // When the anchor point goes past a certain point,
            // this dxx becomes negative.
            // the offset1 portion is neccessary, because normally the bottom right corner has always a certain offset
            // But we only allow this offset to be 0 if we move the anchor point to a position so that that side of our rectangle should be zero, making our shape a triangle.
            var dxx = max(-point0.x.dbl + offset1, 0.0)
            var dyy = (y.dbl * dxx) / (x.dbl)
            if dyy.isNaN || dyy.isInfinite { dyy = 0.0 }
            //                        println("dxx = \(dxx)")
            //                        println("dyy = \(dyy)")
            
            
            //            println("point0 = \(point0)")
            
            CGPathMoveToPoint(path[1], nil, 0, 0)
            CGPathAddLineToPoint(path[1], nil, 0, y)
            CGPathAddLineToPoint(path[1], nil, x, y)
            CGPathAddLineToPoint(path[1], nil, point0.x - offset1.fl + dxx.fl, dyy.fl)
            CGPathCloseSubpath(path[1])
            
            // Top right view for Composition Type 2
            
            // Convert anchor point to frame coordinates
            // For y coordinate, we go up with an additional offset of spacing/2,
            // because of the way we calculate the top right offset for this view
            point0.x = anchorPoint.x - spacing.fl * 2 //max(anchorPoint.x.dbl - spacing, -20.0).fl
            //            point0.y = anchorPoint.y - spacing.fl * 2 - dx.fl - offset2.fl //min(max(anchorPoint.y.dbl - offset2 - dx, -20.0), y.dbl + spacing).fl
            point0.y = anchorPoint.y - spacing.fl
            
            
            //            println("point0 = \(point0)")
            // Prevents negative stroking for top right view
            // (-offset2) is the amount we allow to be zero,
            // that way the shape can be a triangle, otherwise it would always be a rectangle, except a point where we are calculating
            // In other words, if we go past that point, we make the sucker always be a triangle
            dyy = min(point0.y.dbl - offset2, 0.0)
            // find dxx using similar triangles theorem
            dxx = (x.dbl * dyy) / (y.dbl)
            if dxx.isNaN || dxx.isInfinite { dxx = 0.0 }
            
            CGPathMoveToPoint(path[2], nil, 0, 0)
            CGPathAddLineToPoint(path[2], nil, -dxx.fl, point0.y - offset2.fl - dyy.fl)
            CGPathAddLineToPoint(path[2], nil, x, y)
            CGPathAddLineToPoint(path[2], nil, x, 0)
            CGPathCloseSubpath(path[2])
            
            
            if tag == 2 {
                println("")
                println("tag = \(tag)")
                println("")
                println("offset1 = \(offset1)")
                println("offset2 = \(offset2)")
                println("offset3 = \(offset3)")
                println("offset4 = \(offset4)")
                println("")
                println("dxx = \(dxx)")
                println("dyy = \(dyy)")
                println("")
                println("point0 = \(point0)")
                println("anchorPoint.y = \(anchorPoint.y)")
                println("y = \(y)")
                println("point0.y - y = \(point0.y - y)")
                println("anchorPoint.y - Y - spacing.fl = \(anchorPoint.y - Y - spacing.fl)")
                println("")
                println("(offset3 - spacing) = \((offset3 - spacing))")
                println("")
                
            }
            
            
            // Update view frame for Composition Type 3
            switch tag {
            case 0: // Top left
                
                frame = CGRectMake(
                    _spacing,
                    _spacing,
                    max(anchorPoint.x.dbl - dx * 3, 0.0).fl,
                    max(anchorPoint.y.dbl - dx * 3, 0.0).fl)
                
            case 1: // Bottom left
                
                frame = CGRectMake(
                    _spacing,
                    max(anchorPoint.y.dbl + dx, 0.0).fl,
                    max(X.dbl - dx * 3 - offset4, 0.0).fl,
                    max(Y.dbl - anchorPoint.y.dbl - dx * 3, 0.0).fl)

            case 2: // Top right
                
                frame = CGRectMake(
                    max(anchorPoint.x.dbl + dx, 0.0).fl,
                    _spacing,
                    max(X.dbl - anchorPoint.x.dbl - spacing - dx, 0.0).fl,
                    max(Y.dbl - offset3 - dx * 4, 0.0).fl)
                
            default:
                
                break
            }
            // MARK: Composition Type 4
        case .Four:
            // Variables related with Composition Type 4
            // These are going to be used in offset calculations,
            // which are required to create frames for the views when
            // a spacing value is set.
            let dx = spacing / 2
            
            // Four views for Composition Type 4
            for i in 0...3 {
                CGPathMoveToPoint(path[i], nil, 0, 0)
                CGPathAddLineToPoint(path[i], nil, 0, y)
                CGPathAddLineToPoint(path[i], nil, x, y)
                CGPathAddLineToPoint(path[i], nil, x, 0)
                CGPathCloseSubpath(path[i])
            }
            
            
            // Update view frame for Composition Type 4
            switch tag {
            case 0: // Top left
                
                frame = CGRectMake(
                    _spacing,
                    _spacing,
                    max(anchorPoint.x.dbl - dx * 3, 0.0).fl,
                    max(anchorPoint.y.dbl - dx * 3, 0.0).fl)
                
            case 1: // Bottom left
                
                frame = CGRectMake(
                    _spacing,
                    max(anchorPoint.y.dbl + dx, 0.0).fl,
                    max(anchorPoint.x.dbl - dx * 3, 0.0).fl,
                    max(Y.dbl - anchorPoint.y.dbl - dx * 3, 0.0).fl)
                
            case 2: // Bottom right
                
                frame = CGRectMake(
                    max(anchorPoint.x.dbl + dx, 0.0).fl,
                    max(anchorPoint.y.dbl + dx, 0.0).fl,
                    max(X.dbl - anchorPoint.x.dbl - dx * 3, 0.0).fl,
                    max(Y.dbl - anchorPoint.y.dbl - dx * 3, 0.0).fl)
                
            case 3: // Top right
                
                frame = CGRectMake(
                    max(anchorPoint.x.dbl + dx, 0.0).fl,
                    _spacing,
                    max(X.dbl - anchorPoint.x.dbl - dx * 3, 0.0).fl,
                    max(anchorPoint.y.dbl - dx * 3, 0.0).fl)
                
            default:
                
                break
            }
            
        case .Five:
            // Variables related with Composition Type 5
            // These are going to be used in offset calculations,
            // which are required to create frames for the views when
            // a spacing value is set.
            let dx = spacing / 2
            
            // Angles
            /// Top left, left angle
            var angle1 = atan((anchorPoint.x.dbl - dx) / (anchorPoint.y.dbl - dx))
//            if angle1.isNaN || angle1.isInfinite { angle1 = 0.0 }
            /// Bottom left, left angle
            var angle2 = atan((anchorPoint.x.dbl - dx) / (Y.dbl - anchorPoint.y.dbl - dx))
//            if angle2.isNaN || angle2.isInfinite { angle2 = 0.0 }
            /// Top right, right angle
            var angle3 = atan((X.dbl - anchorPoint.x.dbl - dx) / (Y.dbl - anchorPoint.y.dbl - dx))
//            if angle3.isNaN || angle3.isInfinite { angle3 = 0.0 }
            /// Bottom right, right angle
            var angle4 = atan((X.dbl - anchorPoint.x.dbl - dx) / (anchorPoint.y.dbl - dx))
//            if angle4.isNaN || angle4.isInfinite { angle4 = 0.0 }

            // Offsets
            //
            // These are actually extra offsets measured after the spacing from the edges of the main rectangle
            //
            // What letters and numbers after the word 'offset' in the variable names indicate:
            // L: Left, B: Bottom, R: Right, T: Top (View)
            // V: Vertical, H: Horizontal (Direction)
            // 1, 2, 3: Corners starting from top left, counting counter-clockwise direction
            // Offset in the middle is calculated differently. It is a CGPoint.
            var offsetLV1 = findCornerOffset(angle: angle1, dx: dx)
            var offsetLV2 = findCornerOffset(angle: angle2, dx: dx)
//            var offsetLV3 = dx * tan(angle1 / 2) - dx * tan(angle2 / 2)
//            var offsetLH3 = (dx * tan(angle1 / 2) + dx * tan(angle2 / 2)) / (tan(M_PI / 2 - angle1) * tan(M_PI / 2 - angle2))
            var offsetL3 = findOffset(angle1: M_PI/2 - angle2, angle2: M_PI/2 - angle1, dx: dx)
            
            var offsetBH1 = findCornerOffset(angle: M_PI/2 - angle2, dx: dx) //dx * tan(angle2) + dx / cos(angle2) - dx
            var offsetBH2 = findCornerOffset(angle: M_PI/2 - angle3, dx: dx) // dx * tan(angle3) + dx / cos(angle3) - dx
//            var offsetBH3 = dx * tan((M_PI / 2 - angle2) / 2) - dx * tan((M_PI / 2 - angle3) / 2)
//            var offsetBV3 = (dx * tan((M_PI / 2 - angle2) / 2) - dx * tan((M_PI / 2 - angle3) / 2)) / (tan(angle2) * tan(angle3))
            var offsetB3 = findOffset(angle1: angle3, angle2: angle2, dx: dx)
            
            var offsetRV2 = findCornerOffset(angle: angle3, dx: dx) // dx / tan(angle3) + dx / sin(angle3) - dx
            var offsetRV3 = findCornerOffset(angle: angle4, dx: dx) // dx / tan(angle4) + dx / sin(angle4) - dx
            var offsetR1 = findOffset(angle1: M_PI/2 - angle4, angle2: M_PI/2 - angle3, dx: dx)
            
            var offsetUH1 = findCornerOffset(angle: M_PI/2 - angle1, dx: dx) //dx * tan(angle1) + dx / cos(angle1) - dx
            var offsetUH3 = findCornerOffset(angle: M_PI/2 - angle4, dx: dx) //dx * tan(angle1 / 2) - dx * tan(angle4 / 2)
            var offsetU2 = findOffset(angle1: angle1, angle2: angle4, dx: dx) // dx * tan(angle4) + dx / cos(angle4) - dx
//            var offsetUV2 = (dx * tan(angle1 / 2) - dx * tan(angle4 / 2)) * tan(angle1)
//            var offsetU3 = findOffset(angle1: angle1, angle2: angle4, dx: dx)

            
//            if offsetLV1.isNaN { offsetLV1 = 0 }
//            if offsetLV2.isNaN { offsetLV2 = 0 }
//            if offsetLV3.isNaN { offsetLV3 = 0 }
//            if offsetLH3.isNaN { offsetLH3 = 0 }
//            if offsetBH1.isNaN { offsetBH1 = 0 }
//            if offsetBH3.isNaN { offsetBH3 = 0 }

            
            
//            /// Top right view, bottom left corner vertical offset
//            let offset1 = min(dx * tan((M_PI / 2 - angle) / 2), Double(Y))
//            /// Top left view, top right corner vertical offset
//            let offset2 = dx * tan(angle / 2)
//            /// Top left view, top left corner vertical offset
//            let offset3 = dx / tan(angle) + dx / sin(angle) - dx
//            /// Top right view, top left corner horizontal offset
//            let offset4 = dx * tan(angle) + dx / cos(angle)
            
            // Left view for Composition Type 5
            // Convert anchor point to frame coordinates
            var point0 = CGPoint()
            point0.x = anchorPoint.x - spacing.fl
            point0.y = anchorPoint.y - spacing.fl - offsetLV1

            CGPathMoveToPoint(path[0], nil, 0, 0)
            CGPathAddLineToPoint(path[0], nil, 0, y)
            CGPathAddLineToPoint(path[0], nil, x, point0.y - offsetL3.x)
            CGPathCloseSubpath(path[0])

            // Bottom view for Composition Type 5
            // Convert anchor point to frame coordinates
            point0.x = anchorPoint.x - spacing.fl - offsetBH1 - offsetB3.x
            point0.y = Y - anchorPoint.y - offsetB3.y
            
            CGPathMoveToPoint(path[1], nil, 0, y)
            CGPathAddLineToPoint(path[1], nil, x, y)
            CGPathAddLineToPoint(path[1], nil, point0.x, 0)
            CGPathCloseSubpath(path[1])

            // Right view for Composition Type 5
            // Convert anchor point to frame coordinates
            point0.x = anchorPoint.x + offsetR1.y
            point0.y = anchorPoint.y - spacing.fl - offsetRV3
            
            CGPathMoveToPoint(path[2], nil, 0, point0.y + offsetR1.x)
            CGPathAddLineToPoint(path[2], nil, x, y)
            CGPathAddLineToPoint(path[2], nil, x, 0)
            CGPathCloseSubpath(path[2])
            
            // Top view for Composition Type 5
            // Convert anchor point to frame coordinates
            point0.x = anchorPoint.x - spacing.fl - offsetUH1 + offsetU2.x
            point0.y = anchorPoint.y - spacing.fl - offsetU2.y
            
            CGPathMoveToPoint(path[3], nil, 0, 0)
            CGPathAddLineToPoint(path[3], nil, max(point0.x, 0), max(point0.y, 0))
            CGPathAddLineToPoint(path[3], nil, x, 0)
            CGPathCloseSubpath(path[3])
            
            // Update view frame for Composition Type 5
            switch tag {
            case 0: // Left
                
                frame = CGRectMake(
                    _spacing,
                    _spacing + offsetLV1,
                    max(anchorPoint.x.dbl - dx * 2 - offsetL3.y.dbl, 0.0).fl,
                    max(Y.dbl - dx * 4 - offsetLV1.dbl - offsetLV2.dbl, 0.0).fl)
                
            case 1: // Bottom
                
                frame = CGRectMake(
                    _spacing + offsetBH1,
                    max(anchorPoint.y.dbl + offsetB3.y.dbl, 0.0).fl,
                    max(X.dbl - dx * 4 - offsetBH1.dbl - offsetBH2.dbl, 0.0).fl,
                    max(Y.dbl - anchorPoint.y.dbl - dx * 2 - offsetB3.y.dbl, 0.0).fl)
                
            case 2: // Right
                
                frame = CGRectMake(
                    max(anchorPoint.x.dbl + offsetR1.y.dbl, 0.0).fl,
                    max(spacing + offsetRV3.dbl, 0.0).fl,
                    max(X.dbl - anchorPoint.x.dbl - dx * 2 - offsetR1.y.dbl, 0.0).fl,
                    max(Y.dbl - dx * 4 - offsetRV2.dbl - offsetRV3.dbl, 0.0).fl)
                
            case 3: // Top
                
                frame = CGRectMake(
                    max(spacing + offsetUH1.dbl, 0.0).fl,
                    _spacing,
                    max(X.dbl - dx * 4 - offsetUH1.dbl - offsetUH3.dbl, 0.0).fl,
                    max(anchorPoint.y.dbl - dx * 2 - offsetU2.y.dbl, 0.0).fl)
//                println("offsetU2 = \(offsetU2)")

            default:
                
                break
            }
        case .Six:
            // Variables related with Composition Type 6
            // These are going to be used in offset calculations,
            // which are required to create frames for the views when
            // a spacing value is set.
            let dx = spacing / 2
            
            // Three views for Composition Type 6
            for i in 0...2 {
                CGPathMoveToPoint(path[i], nil, 0, 0)
                CGPathAddLineToPoint(path[i], nil, 0, y)
                CGPathAddLineToPoint(path[i], nil, x, y)
                CGPathAddLineToPoint(path[i], nil, x, 0)
                CGPathCloseSubpath(path[i])
            }
            
            
            // Update view frame for Composition Type 6
            switch tag {
            case 0: // Left
                
                frame = CGRectMake(
                    _spacing,
                    _spacing,
                    max(anchorPoint.x.dbl - dx * 3, 0.0).fl,
                    max(Y.dbl - dx * 4, 0.0).fl)
                
            case 1: // Bottom right
                
                frame = CGRectMake(
                    max(anchorPoint.x.dbl + dx, 0.0).fl,
                    max(anchorPoint.y.dbl + dx, 0.0).fl,
                    max(X.dbl - anchorPoint.x.dbl - dx * 3, 0.0).fl,
                    max(Y.dbl - anchorPoint2.y.dbl - dx * 3, 0.0).fl)
                
                // Update anchor point 1
                anchorPoints[0].y = anchorPoint2.y + dx.fl + y / 2
                
                // Update anchor point 2
                anchorPoints[1].x = anchorPoint.x + dx.fl + x / 2
                
            case 2: // Top right
                
                frame = CGRectMake(
                    max(anchorPoint.x.dbl + dx, 0.0).fl,
                    _spacing,
                    max(X.dbl - anchorPoint.x.dbl - dx * 3, 0.0).fl,
                    max(anchorPoint2.y.dbl - dx * 3, 0.0).fl)
                
            default:
                
                break
            }

        case .Seven:
            // Variables related with Composition Type 7
            // These are going to be used in offset calculations,
            // which are required to create frames for the views when
            // a spacing value is set.
            let dx = spacing / 2
            
            // Top left view for Composition Type 7
            CGPathMoveToPoint(path[0], nil, x, 0)
            CGPathAddCurveToPoint(path[0], nil, x, 0, 0, 0, 0, y)
            
            
            //            CGPathAddArc(path, NULL, 0, 15, 15, M_PI_2, -M_PI_2, true)
            
            //            CGPathAddArcToPoint(path[0], nil, 0, 0, 0, 0, 0)
            //            CGPathAddArc(path[0], nil, x, y, 10, CGFloat(M_PI), CGFloat(M_PI), false)
            
            CGPathAddLineToPoint(path[0], nil, x, y)
            CGPathCloseSubpath(path[0])
            
            // Bottom left view for Composition Type 7
            CGPathMoveToPoint(path[1], nil, 0, 0)
            CGPathAddCurveToPoint(path[1], nil, 0, 0, 0, y, x, y)
            CGPathAddLineToPoint(path[1], nil, x, 0)
            CGPathCloseSubpath(path[1])
            
            // Bottom right view for Composition Type 7
            CGPathMoveToPoint(path[2], nil, x, 0)
            CGPathAddCurveToPoint(path[2], nil, x, 0, x, y, 0, y)
            CGPathAddLineToPoint(path[2], nil, 0, 0)
            CGPathCloseSubpath(path[2])
            
            // Top right view for Composition Type 7
            CGPathMoveToPoint(path[3], nil, 0, 0)
            CGPathAddCurveToPoint(path[3], nil, x, 0, x, y, x, y)
            CGPathAddLineToPoint(path[3], nil, 0, y)
            CGPathCloseSubpath(path[3])
            
            
            // Update view frame for Composition Type 7
            switch tag {
            case 0: // Top left
                
                frame = CGRectMake(
                    _spacing,
                    _spacing,
                    max(anchorPoint.x.dbl - dx * 3, 0.0).fl,
                    max(anchorPoint.y.dbl - dx * 3, 0.0).fl)
                
            case 1: // Bottom left
                
                frame = CGRectMake(
                    _spacing,
                    max(anchorPoint.y.dbl + dx, 0.0).fl,
                    max(anchorPoint.x.dbl - dx * 3, 0.0).fl,
                    max(Y.dbl - anchorPoint.y.dbl - dx * 3, 0.0).fl)
                
            case 2: // Bottom right
                
                frame = CGRectMake(
                    max(anchorPoint.x.dbl + dx, 0.0).fl,
                    max(anchorPoint.y.dbl + dx, 0.0).fl,
                    max(X.dbl - anchorPoint.x.dbl - dx * 3, 0.0).fl,
                    max(Y.dbl - anchorPoint.y.dbl - dx * 3, 0.0).fl)
                
            case 3: // Top right
                
                frame = CGRectMake(
                    max(anchorPoint.x.dbl + dx, 0.0).fl,
                    _spacing,
                    max(X.dbl - anchorPoint.x.dbl - dx * 3, 0.0).fl,
                    max(anchorPoint.y.dbl - dx * 3, 0.0).fl)
                
            default:
                
                break
            }
            
        default:
            break
            
        }
        
        return path[tag]
    }
    
    private func findOffset(#angle1: Double, angle2: Double, dx: Double) -> CGPoint
    {
        let beta1 = M_PI/2 - angle1
        let beta2 = M_PI/2 - angle2
        let smallSide = dx * tan(beta2 / 2)
        let hypotenuse = dx * tan((beta1 + beta2) / 2) - smallSide
        
        var offsetX = hypotenuse * cos(beta2) - smallSide
        var offsetY = hypotenuse * sin(beta2)
        
        if offsetX.isNaN || offsetX.isInfinite { offsetX = 0 }
        if offsetY.isNaN || offsetY.isInfinite { offsetY = 0 }
        
        return CGPointMake(offsetX.fl, offsetY.fl + dx.fl)
    }
    private func findCornerOffset(#angle: Double, dx: Double) -> CGFloat
    {
        var offset = dx / tan(angle) + dx / sin(angle) - dx
        
        if offset.isNaN || offset.isInfinite { offset = 0 }
        
        return offset.fl
    }
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return CGPathContainsPoint(shapeLayer.path, nil, layer.convertPoint(point, toLayer: shapeLayer), false)
    }

    // MARK: - Scroll view delegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
