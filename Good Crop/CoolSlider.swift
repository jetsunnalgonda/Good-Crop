//
//  CoolSlider.swift
//  Good Crop
//
//  Created by Haluk Isik on 8/7/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit

class CoolSlider: UISlider
{
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        print("trackRectForBounds")
        //keeps original origin and width, changes height, you get the idea
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 50.0))
        super.trackRectForBounds(customBounds)
        return customBounds
    }
    
    //while we are here, why not change the image here as well? (bonus material)
    override func awakeFromNib() {
        setupSlider()
        super.awakeFromNib()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSlider()
    }

    func setupSlider()
    {
        setThumbImage(UIImage(named: "slider-thumb"), forState: .Normal)
        minimumTrackTintColor = UIColor.blackColor()
        maximumTrackTintColor = UIColor.blackColor()

    }
}
