//
//  CollageView.swift
//  Shape Views
//
//  Created by Haluk Isik on 8/10/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit


protocol CollageViewDelegate: class {
    var compositionType: CompositionType { get set }
}

// MARK: - Types

enum CompositionType: Int, Printable {
    case One = 1, Two, Three, Four, Five, Six, Seven

    /// Maximum number of images that each composition type holds
    var maximumImageCount: Int {
        switch self {
        case .One:
            fallthrough
        case .Two:
            fallthrough
        case .Three:
            return 3
        case .Four:
            fallthrough
        case .Five:
            fallthrough
        case .Six:
            fallthrough
        case .Seven:
            return 4
        }
    }
    
    var description: String {
        let descriptionFirstPhrase = "Composition Type"
        return "\(descriptionFirstPhrase): \(rawValue)"
    }
}

enum Mode: Printable {
    case Remove(Int -> (Int, String?))
    case Switch([Int] -> (Int, String?))
    case None
    
    var description: String {
        switch self {
        case .Remove(_):
            return "Remove"
        case .Switch(_):
            return "Switch"
        case .None:
            return "None"
        }
    }
}

/**
    This view holds multiple scroll views. Each scroll view is wrapped inside a container view. These containers are masked so that the scroll views have custom shaped boundaries that are attached by an anchor point.

    :param: anchorPoint: This is the point where the scroll views (and their containers) intersect. `CollageView` is responsible for handling touch events to change the `anchorPoint`.

    :param: images: When this value is set, the images inside scroll views change.
*/
class CollageView: UIView, ShapedScrollContainerViewDelegate, UIScrollViewDelegate
{

    // MARK: - Properties
    
    weak var delegate: CollageViewDelegate?
    var compositionType: CompositionType? {
        didSet {
//            subviews.map() { $0.removeFromSuperview() }
            let anchorViewVisibility = anchorViews.first!.hidden
            let currentSpacing = spacing
            removeSubviews()
            addSubviews()
            setupView()
            setupAnchorView()
            
            layoutSubviews()
            
            for anchorView in anchorViews {
                anchorView.hidden = anchorViewVisibility
            }
            spacing = currentSpacing
        }
    }
    
    var wrapperViews = [ShapedScrollContainerView]()

    private var anchorRadius: CGFloat = 10
    var anchorViews = [UIView]()
    private var touchViews = [UIView]()

    private var anchorViewShapeLayers = [CAShapeLayer]()
    private var touchViewShapeLayers = [CAShapeLayer]()
    private var anchorPointIsBeingDragged = [false, false]
    
    var anchorPoints = [CGPoint]() {
        didSet {
            let spacing = self.spacing ?? 0
            for (var anchorPoint) in anchorPoints {
                anchorPoint.x = max(min(bounds.width - spacing / 2, anchorPoint.x), spacing / 2)
                anchorPoint.y = max(min(bounds.height - spacing / 2, anchorPoint.y), spacing / 2)
            }
            for wrapperView in wrapperViews {
                wrapperView.anchorPoints = anchorPoints
            }
//            if anchorView != nil { updateAnchorView() }
            if anchorViews.count == anchorPoints.count {
                updateAnchorView()

            }
        }
    }
    /// Holds the relative values of the anchor point with respect to the width and height of the view.
    /// This value is used to keep the relative position of the anchor point same between size changes.
    /// Superview sets the value before it causes a layout change.
    var anchorPointRelative = [CGPoint]() {
        didSet {
            keepAnchorRatio = true
        }
    }
    private var keepAnchorRatio = false
    
    var spacing: CGFloat? {
        didSet {
            let anchor = anchorPoints
            anchorPoints = anchor
            for wrapperView in wrapperViews {
                wrapperView.spacing = spacing
            }
        }
    }

//    var compositionType = CompositionType.One
    
    var images = [UIImage?]() {
        didSet {
            if images.count >= wrapperViews.count {
                for (key, wrapperView) in enumerate(wrapperViews) {
                    wrapperView.image = images[key]
                    wrapperView.layoutSubviews()
                    
                }
            }
        }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupView()
        setupAnchorView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
        setupView()
        setupAnchorView()
    }
    
    // MARK: - Layout
    
//    override func layoutIfNeeded() {
//        println("(layoutIfNeeded) frame = \(frame)")
//        println("(layoutIfNeeded) bounds = \(bounds)")
//
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // Make sure anchor point stays within the borders
        // and also update frames
        let anchor = anchorPoints
        anchorPoints = anchor

        // Keep the relative position of the anchor point same
        // between size changes
        if keepAnchorRatio {
            keepAnchorRatio = false
            for (key, _) in enumerate(anchorPoints) {
                let x = anchorPointRelative[key].x * bounds.width
                let y = anchorPointRelative[key].y * bounds.height
                let newAnchorPoint = CGPointMake(x, y)
                
                println("anchorPointRelative set in layoutSubviews x, y = \(x, y)")

                anchorPoints[key] = newAnchorPoint
            }
        }
//        let x = anchorPointRelative.x * bounds.width
//        let y = anchorPointRelative.y * bounds.height
//        anchorPoint = CGPointMake(x, y)
        
        println("(collageView layoutSubviews) bounds = \(bounds)")
        
    }

    // MARK: - Methods
    
    func addSubviews()
    {
//        let compositionType = delegate?.compositionType ?? CompositionType.One

//        var numberOfViews = 0
//        switch compositionType {
//        case .One:
//            numberOfViews = 3
//        case .Two:
//            fallthrough
//        case .Three:
//            numberOfViews = 4
//            
//        }
        
        println("(addSubviews) wrapperViews = \(wrapperViews)")
        let compositionType = self.compositionType ?? .One
        
        // Create subviews according to the composition type that was selected
        for i in 0..<compositionType.maximumImageCount {
            wrapperViews.append(ShapedScrollContainerView(frame: self.bounds))
            wrapperViews[i].tag = i
            wrapperViews[i].shapedScrollContainerViewDelegate = self
            wrapperViews[i].compositionType = compositionType
        }
        
        // Add wrapper views to our main view and set them up
        for wrapperView in wrapperViews {
            self.addSubview(wrapperView)
        }
        
    }
    func removeSubviews()
    {
        
        // Remove all the subviews
//        for i in 0..<compositionType!.maximumImageCount {
//            wrapperViews[i].tag = i
//            wrapperViews[i].shapedScrollContainerViewDelegate = self
//        }

        for wrapperView in wrapperViews {
            wrapperView.removeFromSuperview()
        }
        wrapperViews.removeAll()
        for (key, _) in enumerate(anchorViews) {
            anchorViews[key].removeFromSuperview()
            touchViews[key].removeFromSuperview()

        }
        
        println("removed all wrapperViews - count = \(wrapperViews.count)")
        println("wrapperViews = \(wrapperViews)")
        
    }
    func setupView()
    {
        // Let's have 4 UIImage's
        for i in 0...3 {
            images.append(nil)
        }
        
        // Make the background transparent
        backgroundColor = UIColor.clearColor()
        
        // Choose a default anchor point
        anchorPoints.removeAll()
        anchorPoints.append(CGPoint(x: bounds.width / 2, y: bounds.height / 2))
        
        // Choose a default spacing
        spacing = 10

    }
    
    func setupAnchorView()
    {
//        backgroundColor = UIColor.greenColor()

        for i in 0...1 {
            // Set up anchor views
            let anchorView = UIView(frame: CGRectMake(0, 0, anchorRadius * 2, anchorRadius * 2))
            let anchorViewShapeLayer = anchorView.getRoundCorneredLayer(.AllCorners, radius: anchorRadius)
            
            anchorViews.append(anchorView)
            
            // Create a little bigger view on top, so that we can better touch
            let touchView = UIView(frame: CGRectMake(0, 0, anchorRadius * 6, anchorRadius * 6))
            let touchViewShapeLayer = touchView.applyRoundCorners(.AllCorners, radius: anchorRadius * 3)
            touchViewShapeLayer.fillColor = UIColor.redColor().CGColor
            addSubview(touchView)

            touchViews.append(anchorView)
            touchViewShapeLayers.append(touchViewShapeLayer)
            
            // Add shadow
            let containerLayer = CALayer()
            containerLayer.shadowPath = anchorViewShapeLayer.path
            containerLayer.shadowOffset = CGSizeMake(1.0, 1.0)
            containerLayer.shadowRadius = 4.0
            containerLayer.shadowOpacity = 0.6
            containerLayer.shadowColor = UIColor.blackColor().CGColor
            
            // Add a stroke and set fill color
            let strokeLayer = CAShapeLayer()
            strokeLayer.path = anchorViewShapeLayer.path
            strokeLayer.strokeColor = UIColor.whiteColor().CGColor
            strokeLayer.fillColor = UIColor.orangeColor().CGColor
            strokeLayer.lineWidth = 2.0
            
            containerLayer.addSublayer(strokeLayer)
            
            //        anchorView.layer.addSublayer(strokeLayer)
            anchorView.layer.addSublayer(containerLayer)
            
            // Now add it to the view hierarchy
            println("addSubview(anchorView)")
            addSubview(anchorView)
        }

        // Update its origin
        updateAnchorView()
        
//        touchView.hidden = true
        for anchorView in anchorViews {
            anchorView.hidden = true
        }
    }
    func updateAnchorView() {
        println("anchorViews = \(anchorViews)")
        println("anchorPoints = \(anchorPoints)")
        for (key, anchorPoint) in enumerate(anchorPoints) {
//            if anchorViews[key] != nil {
                anchorViews[key].center = anchorPoint
                touchViews[key].center = anchorPoint

//            }
        }
    }
    func adjustAnchorPoint()
    {
        let spacing = self.spacing ?? 0
        for (var anchorPoint) in anchorPoints {
            anchorPoint.x = max(min(bounds.width - spacing / 2, anchorPoint.x), spacing / 2)
            anchorPoint.y = max(min(bounds.height - spacing / 2, anchorPoint.y), spacing / 2)
        }
    }
    
    // MARK: - Gesture recognizers
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        println("gestureRecognizer = \(gestureRecognizer)")
        println("gestureRecognizer.locationInView(self) = \(gestureRecognizer.locationInView(self))")
        return true
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
//        let touchSensitivity: CGFloat = 50
//        let anchorRect = CGRectMake(anchorPoint.x - touchSensitivity / 2, anchorPoint.y - touchSensitivity / 2, touchSensitivity,  touchSensitivity)

//        println("anchorRect = \(anchorRect)")
        
        for touch in touches {
            if let touch = touch as? UITouch {
                let location = touch.locationInView(self)
//                println("touchViewShapeLayer.path = \(touchViewShapeLayer.path)")

                for (key, _) in enumerate(anchorPoints) {
                    if CGPathContainsPoint(touchViewShapeLayers[key].path, nil, layer.convertPoint(location, toLayer: touchViewShapeLayers[key]), false) {
                        println("dragging the point")
                        println("anchorPoint = \(anchorPoints)")
                        println("location = \(location)")
                        
                        //                    anchorPoint = location
                        if !anchorViews[key].hidden { anchorPointIsBeingDragged[key] = true }
                    } else {
                        println("touch is outside the anchorRect")
                        println("location = \(location)")
                        nextResponder()?.touchesBegan(touches, withEvent: event)
                    }

                }
            }
        }
        
//        for wrapperView in wrapperViews {
//            wrapperView.scrollView.touchesMoved(touches, withEvent: event)
//        }
        
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches {
            if let touch = touch as? UITouch {
                let location = touch.locationInView(self)
                for (key, var anchorPoint) in enumerate(anchorPoints) {
                    if anchorPointIsBeingDragged[key] {
                        anchorPoint = location
                    }

                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        println("touchesEnded")
        for touch in touches {
            if let touch = touch as? UITouch {
                let location = touch.locationInView(self)
                for (key, _) in enumerate(anchorPoints) {
                    if CGPathContainsPoint(touchViewShapeLayers[key].path, nil, layer.convertPoint(location, toLayer: touchViewShapeLayers[key]), false) {
                        anchorPointIsBeingDragged[key] = false
                    }
                }
            }
        }
//        anchorPointIsBeingDragged = false
    }
    
    
    // MARK: - Updating anchorView
//    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
//        return CGPathContainsPoint(anchorViewShapeLayer.path, nil, layer.convertPoint(point, toLayer: anchorViewShapeLayer), false)
//    }
}
