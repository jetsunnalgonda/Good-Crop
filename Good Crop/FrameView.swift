//
//  FrameView.swift
//  Good Crop
//
//  Created by Haluk Isik on 7/25/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit

protocol FrameViewDelegate: class {
    var margin: CGFloat { get set }
    var spacing: Float { get set }
    var aspectRatio: CGFloat { get set }
    var aspectRatioText: String { get set }
    var frameType: Int { get set }
}

//@IBDesignable
class FrameView: UIView
{
    weak var delegate: FrameViewDelegate?
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var switchButton: UIButton!
    
    @IBOutlet weak var aspectFillButton: UIButton!
    @IBOutlet weak var aspectFitButton: UIButton!
    
    @IBOutlet weak var flipButton: UIButton!
    
    // MARK: - Aspect ratio slider
    
    @IBOutlet weak var sliderSize: JMMarkSlider! {
        didSet {
            sliderSize.markColor = UIColor(rgba: "#666")
            sliderSize.markPositions = [0.0, 8.49625, 20.7519, 29.2481, 50.0, 70.7519, 79.2481, 91.5038, 100.0]
            sliderSize.markWidth = 1.0
//            sliderSize.handlerColor = goodCropColor
            sliderSize.selectedBarColor = UIColor(rgba: "#111")
            sliderSize.unselectedBarColor = UIColor(rgba: "#111")
            sliderSize.setThumbImage(UIImage(named: "slider-thumb"), forState: UIControlState.Normal)
        }
    }
    @IBOutlet weak var labelSize: UILabel!
    
    // MARK: - Spacing slider

    @IBOutlet weak var sliderSpacing: UISlider! {
        didSet {
            sliderSpacing.setThumbImage(UIImage(named: "slider-thumb"), forState: UIControlState.Normal)
            sliderSpacing.minimumTrackTintColor = UIColor.blackColor()
            sliderSpacing.maximumTrackTintColor = UIColor.blackColor()

        }
    }
    
    // MARK: - Margin slider

    @IBOutlet weak var sliderMargin: UISlider! {
        didSet {
            sliderMargin.setThumbImage(UIImage(named: "slider-thumb"), forState: UIControlState.Normal)
            sliderMargin.minimumTrackTintColor = UIColor.blackColor()
            sliderMargin.maximumTrackTintColor = UIColor.blackColor()
        }
    }
    
    // MARK: - Slider methods and observed properties
    
    @IBAction func marginValueChanged(sender: UISlider) {
        margin = sender.value
    }
    
    @IBAction func sizeValueChanged(sender: UISlider) {
        size = sender.value
    }
    @IBAction func spacingValueChanged(sender: UISlider) {
        spacing = sender.value
    }
    
    private struct Constants {
//        static let DefaultValues = [1/2, 9/16, 2/3, 3/4, 1, 4/3, 3/2, 16/9, 2]
        static let DefaultLogValues: [Float] = [-1.0, -0.830074998557688, -0.584962500721156, -0.415037499278844, 0.0, 0.415037499278844, 0.584962500721156, 0.830074998557688, 1.0]
        static let DefaultValues: [Float] = [0.5, 0.5625, 0.6666666667, 0.75, 1, 1.3333333333334, 1.5, 1.7777777777778, 2]
        static let DefaultNominators = [1, 9, 2, 3, 1, 4, 3, 16, 2]
        static let DefaultDenominators = [2, 16, 3, 4, 1, 3, 2, 9, 1]
    }
    var size: Float = 1 {
        didSet {
            // Round off the slider value so that the increment can only happen in the defined steps below
            var adjustedSliderValue = size //round(size * 1000) / 1000
            
            // This is the value for the label text
            var result = simplify(Int(pow(2, size) * 100), bottom: 100)

            // Try to snap our rounded off slider value to our defined values
            var sizeToSnap = adjustedSliderValue
            sizeToSnap.snapToValues(Constants.DefaultLogValues)
            
            // Get current direction of the slider; true is positive, false is negative
            let sliderDirection = size - oldValue >= 0 ? true : false
            
            // Get proposed snap direction
            let snapDirection = sizeToSnap - oldValue >= 0 ? true : false
            
            // The tolerance value that the slider value can change before we make a decision for snapping
//            let tolerance: Float = 0.005
            
//            let sliderValueChangeAmount = abs(size - oldValue)
            
            // If the value is changed, and the amount is larger than tolerance, snap it
//            if (sizeToSnap != adjustedSliderValue) && (sliderValueChangeAmount > tolerance) {

            // If the value is changed, and the proposed snap direction is the same with the slider direction, snap it
            if (sizeToSnap != adjustedSliderValue) && (sliderDirection == snapDirection) {

                // A little tweak, since we lost some precision while using floats
                // and converting from log and power
                if round(sizeToSnap * 100) / 100 == 0.75 { sizeToSnap = 0.75 }
                
                // Calculate the new value for the label text using the least common multiples 
                // (multiplied LCM's for both nominators and denominators)
                // adjusted for our defined snap values
                result = simplify(Int(pow(2, sizeToSnap) * 96 * 18), bottom: 96 * 18)
                
//                labelSize.text = "\(result.newTop):\(result.newBottom)"
//                adjustedSliderValue = log(Float(result.newTop) / Float(result.newBottom)) / log(2.0)
                
            }
            // Change slider value to the adjusted value
            adjustedSliderValue = log(Float(result.newTop) / Float(result.newBottom)) / log(2.0)
            sliderSize.setValue(adjustedSliderValue, animated: false)
            
            // Change label text
            labelSize.text = "\(result.newTop):\(result.newBottom)"

            // Change the delegate values accordingly
            delegate?.aspectRatio = CGFloat(result.newTop) / CGFloat(result.newBottom)
            delegate?.aspectRatioText = labelSize.text!

        }
    }
//    var size: Float = 1 {
//        didSet {
//            var adjustedSliderValue = round(size * 100) / 100
//            var result = simplify(Int(pow(2, size) * 100), 100)
//            var sizeToSnap = adjustedSliderValue
//            
//            sizeToSnap.snapToValues(Constants.DefaultLogValues)
//            
//            if sizeToSnap != round(size * 100) / 100 {
//                // A little tweak, since we lost some precision while using floats
//                // and converting from log and power
//                if round(sizeToSnap * 100) / 100 == 0.75 { sizeToSnap = 0.75 }
//                
//                result = simplify(Int(pow(2, sizeToSnap) * 96 * 18), 96 * 18)
//                
//                labelSize.text = "\(result.newTop):\(result.newBottom)"
//                adjustedSliderValue = log(Float(result.newTop) / Float(result.newBottom)) / log(2.0)
//                
//                //                sliderSize.setValue(adjustedSliderValue, animated: false)
//            }
//            
//            //            sliderSize.setValue(adjustedSliderValue, animated: false)
//            
//            labelSize.text = "\(result.newTop):\(result.newBottom)"
//            adjustedSliderValue = log(Float(result.newTop) / Float(result.newBottom)) / log(2.0)
//            
//            sliderSize.setValue(adjustedSliderValue, animated: false)
//            delegate?.aspectRatio = CGFloat(result.newTop) / CGFloat(result.newBottom)
//            delegate?.aspectRatioText = labelSize.text!
//            
//        }
//    }
    var spacing: Float = 0 {
        didSet {
            let adjustedSliderValue = round(spacing)
//            let adjustedTextValue = round(spacing)
            sliderSpacing.setValue(adjustedSliderValue, animated: true)
//            labelSpacing.text = "\(adjustedTextValue)"
            spacing = adjustedSliderValue
            delegate?.spacing = adjustedSliderValue

        }
    }
    var margin: Float = 0 {
        didSet {
            let adjustedSliderValue = round(margin)
//            let adjustedTextValue = round(margin)
            sliderMargin.setValue(adjustedSliderValue, animated: true)
            //            labelSpacing.text = "\(adjustedTextValue)"
            margin = adjustedSliderValue
            delegate?.margin = CGFloat(adjustedSliderValue)
            
        }
    }
    
    // MARK: - Special Methods
    private func getConvertedNumberArray(startPos startPos: Double, endPos: Double, forMarkPoints: Bool, multiplier: Double = 2.0, logarithm: Bool = false) -> [Double]
    {
        var markPoint = [Double]()
        for (key, nominator) in Constants.DefaultNominators.enumerate()
        {
            let value: Double = Double(nominator) / Double(Constants.DefaultDenominators[key])
            let convertedNumber = logarithm ? value : log(value) / log(multiplier)
            
            if forMarkPoints {
                markPoint.append((convertedNumber - startPos) * 100 / endPos)
            } else {
                markPoint.append(convertedNumber)

            }
        }
        print("mark point = \(markPoint)")
        return markPoint
    }
    
    // MARK: - Frame type buttons
    
    @IBAction func frameTypeButtonPressed(sender: UIButton) {
        delegate?.frameType = sender.tag
    }

    // MARK: - Our custom view from the XIB file
    var view: UIView!
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        print("view.frame = \(view.frame)")
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "FrameView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
                
        return view
    }

    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
//        xibSetup()
    }
    
    class func instanceFromNib() -> FrameView {
        return UINib(nibName: "FrameView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! FrameView
    }

//    override func layoutSubviews() {
    
//        let constraint1 = NSLayoutConstraint(item: superview!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0)
//        let constraint2 = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: superview!, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0)
//        let constraint3 = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: superview!, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
        
//        self.addConstraint(constraint1)
//        self.addConstraint(constraint2)
//        self.addConstraint(constraint3)
//        
//        constraint3.constant = -self.frame.height
//    }

}
