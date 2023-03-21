//
//  ShapedScrollView.swift
//  Shape Views
//
//  Created by smnh on 3/29/14
//  Copyright (c) 2014 smnh. All rights reserved.
//

import UIKit


class ShapedScrollView: UIScrollView
{
    // MARK: - Properties
    
    /// Default true, If true, it sets the minimum zoom scale when the scroll view's bounds change according to the content mode chosen.
    var autoAdjustMinimumZoomScale = true
    
    /// default false, if true, fits the content to scrollView's bounds by changing zoomScale
    var fitOnSizeChange = false
    
    /// default true, fits the content to bounds only if they are bigger than content, ignored if fitOnSizeChange == true
    var upscaleToFitOnSizeChange = false
    
    /// default NO, sticks content bounds to scrollView edges instead of keeping center point in center, ignored if fitOnSizeChange == YES
    var stickToBounds = false
    
    /// default YES, centers scrollView content in the center of its bounds
    var centerZoomingView = false
    
    /// The view that was added by addViewForZooming: method
    var viewForZooming = UIView()
    
    // Double tap gesture recognizer that zooms in/out the content
    private var doubleTapGestureRecognizer = UITapGestureRecognizer()
    
    private var prevBoundsSize = CGSizeZero
    private var prevContentOffset = CGPointZero
    
    override var zoomScale: CGFloat {
        willSet {
            contentSize = CGSizeMake(floor(contentSize.width), floor(contentSize.height))
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set the prevBoundsSize to the initial bounds, so the first time layoutSubviews
        // is called we won't do any contentOffset adjustments
        prevBoundsSize = bounds.size
        prevContentOffset = contentOffset
//        fitOnSizeChange = false
//        upscaleToFitOnSizeChange = true
//        stickToBounds = false
//        centerZoomingView = true
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "_doubleTapped:")
//        addGestureRecognizer(doubleTapGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    // MARK: - Methods
    
    /// Finds the minimum zoom scale for a scroll view according to its contentMode property.
    /// It checks for two modes: **.ScaleAspectFill** and **.ScaleAspectFit**
    ///
    /// If the contentMode is .ScaleAspectFit, it will add edge insets and center the content view.
    ///
    /// If the contentMode is .ScaleAspectFill, the scroll view will be given no edge insets and
    /// one side of the view will be adjusted to fit one edge while the other side will be left as it is and
    /// if that side is larger than that of the scroll view's, the content will overflow the edge, otherwise it will
    /// just be a perfect fit.
    func findMinimumZoomScale() -> CGFloat
    {
        if let _ = delegate?.respondsToSelector("viewForZoomingInScrollView:") {
            let zoomView = delegate!.viewForZoomingInScrollView!(self)!
            print("zoomView.frame.size = \(zoomView.frame.size)")
            print("zoomView.bounds.size = \(zoomView.bounds.size)")
            print("contentSize = \(contentSize)")
            
            //            let contentAspectRatio = contentSize.width / contentSize.height
            let contentAspectRatio = zoomView.bounds.width / zoomView.bounds.height
            
            // These two variables are the bounds of the scrollview that we are finding the minimum zoom scale against.
            // However to avoid funny zoom scales, for cases when the frame bounds are very small,
            // we define a certain limit and ignore any change in the frame size, therefore not let minimum zoom scale get any smaller
            // even if someone reduces the frame size beyond this limit
            let boundsWidth = max(bounds.width, 50)
            let boundsHeight = max(bounds.height, 50)
            
            print("bounds.width = \(bounds.width)")
            print("bounds.height = \(bounds.height)")
            
            let maxWidth = boundsWidth
            let maxHeight = maxWidth / contentAspectRatio
            var _minimumZoomScale = maxWidth / zoomView.bounds.width
            
            print("maxWidth = \(maxWidth)")
            print("maxHeight = \(maxHeight)")
            
            let heightToBoundsHeightRatio = maxHeight / boundsHeight
            let newMaxWidth = maxWidth / heightToBoundsHeightRatio
//            let newMaxHeight = maxHeight / heightToBoundsHeightRatio

            if maxHeight < boundsHeight {
                //                println("maxHeight < bounds.height")
                
                if contentMode == .ScaleAspectFill {
                    contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
                    _minimumZoomScale = newMaxWidth / zoomView.bounds.width
                } else {
                    let inset = (boundsHeight - maxHeight) / 2
                    contentInset = UIEdgeInsets(top: inset, left: 0.0, bottom: inset, right: 0.0)
                    _minimumZoomScale = maxWidth / zoomView.bounds.width
                }
            } else {
                if contentMode == .ScaleAspectFill {
                    contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
                    _minimumZoomScale = maxWidth / zoomView.bounds.width
                } else {
                    let inset = (boundsWidth - newMaxWidth) / 2
                    contentInset = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
                    _minimumZoomScale = newMaxWidth / zoomView.bounds.width
                }
            }
            print("_minimumZoomScale = \(_minimumZoomScale)")
            return _minimumZoomScale
        } else {
            return 1.0
        }
        
        
    }
    /// Old function with less capability.
    /// This one doesn't check against contentMode
    /// See **findMinimumZoomScale**
    func findMinimumZoomScale_() -> CGFloat
    {
        if let _ = delegate?.respondsToSelector("viewForZoomingInScrollView:") {
            let zoomView = delegate!.viewForZoomingInScrollView!(self)!
            print("zoomView.frame.size = \(zoomView.frame.size)")
            print("zoomView.bounds.size = \(zoomView.bounds.size)")
            print("contentSize = \(contentSize)")
            
//            let contentAspectRatio = contentSize.width / contentSize.height
            let contentAspectRatio = zoomView.bounds.width / zoomView.bounds.height
            
            // These two variables are the bounds of the scrollview that we are finding the minimum zoom scale against.
            // However to avoid funny zoom scales, for cases when the frame bounds are very small,
            // we define a certain limit and ignore any change in the frame size, therefore not let minimum zoom scale get any smaller
            // even if someone reduces the frame size beyond this limit
            let boundsWidth = max(bounds.width, 50)
            let boundsHeight = max(bounds.height, 50)
            
            print("bounds.width = \(bounds.width)")
            print("bounds.height = \(bounds.height)")
            
            var maxWidth = boundsWidth
            let maxHeight = maxWidth / contentAspectRatio
            var _minimumZoomScale = maxWidth / zoomView.bounds.width
            
            print("maxWidth = \(maxWidth)")
            print("maxHeight = \(maxHeight)")
            
            if maxHeight < boundsHeight {
//                println("maxHeight < bounds.height")
                let heightToBoundsHeightRatio = maxHeight / boundsHeight
                maxWidth = maxWidth / heightToBoundsHeightRatio
//                maxHeight = maxHeight / heightToBoundsHeightRatio
                _minimumZoomScale = maxWidth / zoomView.bounds.width
            }
            print("_minimumZoomScale = \(_minimumZoomScale)")
            return _minimumZoomScale
        } else {
            return 1.0
        }


    }
    
    func scaleToFit()
    {
        if let _ = delegate?.respondsToSelector("viewForZoomingInScrollView:") {
            _setMinimumZoomScaleToFit()
            zoomScale = minimumZoomScale
        }
    }
    
    func addViewForZooming(view: UIView)
    {
        if viewForZooming.isDescendantOfView(self) {
            viewForZooming.removeFromSuperview()
        }
        viewForZooming = view
        addSubview(viewForZooming)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !CGSizeEqualToSize(prevBoundsSize, bounds.size) {
            if fitOnSizeChange {
                scaleToFit()
            } else {
                _adjustContentOffset()
            }
            if autoAdjustMinimumZoomScale {
                minimumZoomScale = findMinimumZoomScale()
                if zoomScale < minimumZoomScale {
                    zoomScale = minimumZoomScale
                }
            }
            prevBoundsSize = bounds.size
        }

        prevContentOffset = contentOffset
    }
    
    func _centerScrollViewContent() {
        if let _ = delegate?.respondsToSelector("viewForZoomingInScrollView:") {
            if centerZoomingView {
                if let zoomView = delegate!.viewForZoomingInScrollView!(self) {
                
                    var frame = zoomView.frame
                    if contentSize.width < bounds.size.width {
                        frame.origin.x = round((bounds.size.width - contentSize.width) / 2)
                    } else {
                        frame.origin.x = 0
                    }
                    if contentSize.height < self.bounds.size.height {
                        frame.origin.y = round((bounds.size.height - contentSize.height) / 2)
                    } else {
                        frame.origin.y = 0
                    }
                    zoomView.frame = frame
                }
            }
        }
    }
    
    func _adjustContentOffset() {
        if let _ = delegate?.respondsToSelector("viewForZoomingInScrollView:") {
            let zoomView = delegate!.viewForZoomingInScrollView!(self)!
            
            // Using contentOffset and bounds values before the bounds were changed (e.g.: interface orientation change),
            // find the visible center point in the unscaled coordinate space of the zooming view.
            var prevCenterPoint = CGPoint()
            prevCenterPoint.x = (prevContentOffset.x + round(prevBoundsSize.width / 2) - zoomView.frame.origin.x) / zoomScale
            prevCenterPoint.y = (prevContentOffset.y + round(prevBoundsSize.height / 2) - zoomView.frame.origin.y) / zoomScale

            if stickToBounds {
                if contentSize.width > prevBoundsSize.width {
                    if prevContentOffset.x == 0 {
                        prevCenterPoint.x = 0
                    } else if prevContentOffset.x + prevBoundsSize.width == round(self.contentSize.width) {
                        prevCenterPoint.x = zoomView.bounds.size.width
                    }
                }
                if contentSize.height > self.prevBoundsSize.height {
                    if prevContentOffset.y == 0 {
                        prevCenterPoint.y = 0
                    } else if prevContentOffset.y + self.prevBoundsSize.height == round(contentSize.height) {
                        prevCenterPoint.y = zoomView.bounds.size.height
                    }
                }
            }
            
            // If the size of the scrollView was changed such that the minimumZoomScale is increased
            if upscaleToFitOnSizeChange {
                _increaseScaleIfNeeded()
            }
            
            // Calculate new contentOffset using the previously calculated center point and the new contentOffset and bounds values.
            var contentOffset = CGPointMake(0.0, 0.0)
            var frame = zoomView.frame
            if contentSize.width > bounds.size.width {
                frame.origin.x = 0
                contentOffset.x = prevCenterPoint.x * zoomScale - round(bounds.size.width / 2)
                if contentOffset.x < 0 {
                    contentOffset.x = 0
                } else if contentOffset.x > contentSize.width - bounds.size.width {
                    contentOffset.x = contentSize.width - bounds.size.width
                }
            }
                
            if contentSize.height > bounds.size.height {
                frame.origin.y = 0
                contentOffset.y = prevCenterPoint.y * zoomScale - round(bounds.size.height / 2)
                if contentOffset.y < 0 {
                    contentOffset.y = 0
                } else if contentOffset.y > contentSize.height - bounds.size.height {
                    contentOffset.y = contentSize.height - bounds.size.height
                }
            }
            zoomView.frame = frame
            self.contentOffset = contentOffset
        }
    }
    
    func _increaseScaleIfNeeded() {
        _setMinimumZoomScaleToFit()
        if zoomScale < minimumZoomScale {
            zoomScale = self.minimumZoomScale
        }
    }
    
    func _setMinimumZoomScaleToFit() {
        let zoomView = delegate!.viewForZoomingInScrollView!(self)!
        let scrollViewSize = bounds.size
        let zoomViewSize = zoomView.bounds.size
        
        var scaleToFit = fmin(scrollViewSize.width / zoomViewSize.width, scrollViewSize.height / zoomViewSize.height)
        if scaleToFit > 1.0 {
            scaleToFit = 1.0
        }
        minimumZoomScale = scaleToFit
    }
    
    func _doubleTapped(gestureRecognizer: UIGestureRecognizer) {
        if let _ = delegate?.respondsToSelector("viewForZoomingInScrollView:") {
            let zoomView = delegate!.viewForZoomingInScrollView!(self)!
            
            if zoomScale == minimumZoomScale {
                // When user double-taps on the scrollView while it is zoomed out, zoom-in
                let newScale = maximumZoomScale;
                let centerPoint = gestureRecognizer.locationInView(zoomView)
                let zoomRect = _zoomRectInView(self, forScale: newScale, withCenter: centerPoint)
                zoomToRect(zoomRect, animated: true)
            } else {
                // When user double-taps on the scrollView while it is zoomed, zoom-out
                setZoomScale(minimumZoomScale, animated: true)
            }
        }
    }
    
    func _zoomRectInView(view: UIView, forScale scale: CGFloat, withCenter center: CGPoint) -> CGRect
    {
        var zoomRect = CGRectZero
        
        // The zoom rect is in the content view's coordinates.
        // At a zoom scale of 1.0, it would be the size of the scrollView's bounds.
        // As the zoom scale decreases, so more content is visible, the size of the rect grows.
        zoomRect.size.height = view.bounds.size.height / scale
        zoomRect.size.width = view.bounds.size.width / scale
        
        // choose an origin so as to get the right center.
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
}

