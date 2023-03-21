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

@IBDesignable class FrameView: UIView
{
    weak var delegate: FrameViewDelegate?
    
    @IBOutlet weak var cropButton: UIButton!
    
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
//            var markPoint = [Double]()
//            for (key, nominator) in enumerate(Constants.DefaultNominators) {
//                let value: Double = Double(nominator) / Double(Constants.DefaultDenominators[key])
//                
////                markPoint.append(( (log(value)/log(2)) + 1) * 100 / 2)
//                markPoint.append(( (log(value)/log(2)) ) )
//
//            }
//            println("mark point = \(markPoint)")
            
            println("size = \(size)")

            var adjustedSliderValue = round(size * 100) / 100
//            var sizeToSnap = pow(2, size)
            var sizeToSnap = adjustedSliderValue
            var result = simplify(Int(pow(2, size) * 100), 100)
            
            println("adjustedSliderValue = \(adjustedSliderValue)")
            
            labelSize.text = "\(result.newTop):\(result.newBottom)"
            adjustedSliderValue = log(Float(result.newTop) / Float(result.newBottom)) / log(2.0)
            sliderSize.setValue(adjustedSliderValue, animated: true)
            
//            println("")
//            println("sizeToSnap, before = \(sizeToSnap)")
//            sizeToSnap.snapToValues(Constants.DefaultLogValues)
//            println("sizeToSnap.getSnappedValue, before = \(sizeToSnap.getSnappedValue(Constants.DefaultLogValues))")
//            println("adjustedSliderValue, before = \(adjustedSliderValue)")
//            println("")
//            println("sizeToSnap, after = \(sizeToSnap)")
//            println("sizeToSnap.getSnappedValue, after = \(sizeToSnap.getSnappedValue(Constants.DefaultLogValues))")
//            println("adjustedSliderValue, after = \(adjustedSliderValue)")
//            println("")

            if sizeToSnap != adjustedSliderValue {
//                adjustedSliderValue = size
//                sizeToSnap.snapToValues(Constants.DefaultLogValues)
                // A little tweak, since we lost some precision while using floats
                // and converting from log and power
                if round(sizeToSnap * 100) / 100 == 0.75 { sizeToSnap = 0.75 }
//
                result = simplify(Int(pow(2, sizeToSnap) * 96 * 18), 96 * 18)
//                result = simplify(Int(pow(2, sizeToSnap) * 100), 100)

                labelSize.text = "\(result.newTop):\(result.newBottom)"
//                labelSize.text = "sizeToSnap = \(sizeToSnap), size = \(size)"
                adjustedSliderValue = log(Float(result.newTop) / Float(result.newBottom)) / log(2.0)
//                labelSize.text = "\(Float(result.newTop) / Float(result.newBottom))"
                
                // Some tweaks
//                if round(adjustedSliderValue * 100) / 100 == 1.78 {
//                    delegate?.aspectRatio = 1.775
//                    delegate?.aspectRatioText = labelSize.text!
//                    return
//                }
//                if size == 0.5625 {
//                    delegate?.aspectRatio = 0.563
//                    delegate?.aspectRatioText = labelSize.text!
//                    return
//                }

                
                sliderSize.setValue(adjustedSliderValue, animated: true)


            }
            
//            sliderSize.setValue(adjustedSliderValue, animated: true)
//            labelSize.text = "\(result.newTop):\(result.newBottom)"

            delegate?.aspectRatio = CGFloat(result.newTop) / CGFloat(result.newBottom)
            delegate?.aspectRatioText = labelSize.text!

//            size = adjustedSliderValue
            println("size slider value = \(adjustedSliderValue)")

        }
    }
    var spacing: Float = 0 {
        didSet {
            let adjustedSliderValue = round(spacing)
            let adjustedTextValue = round(spacing)
            sliderSpacing.setValue(adjustedSliderValue, animated: true)
//            labelSpacing.text = "\(adjustedTextValue)"
            spacing = adjustedSliderValue
            delegate?.spacing = adjustedSliderValue

        }
    }
    var margin: Float = 0 {
        didSet {
            let adjustedSliderValue = round(margin)
            let adjustedTextValue = round(margin)
            sliderMargin.setValue(adjustedSliderValue, animated: true)
            //            labelSpacing.text = "\(adjustedTextValue)"
            margin = adjustedSliderValue
            delegate?.margin = CGFloat(adjustedSliderValue)
            
        }
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
        println("view.frame = \(view.frame)")
        
        // Make the view stretch with containing view
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
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
    
    required init(coder aDecoder: NSCoder) {
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
