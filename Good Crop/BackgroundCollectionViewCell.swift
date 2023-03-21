//
//  BackgroundCollectionViewCell.swift
//  Good Crop
//
//  Created by Haluk Isik on 8/18/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit

class BackgroundCollectionViewCell: UICollectionViewCell
{
    
//    @IBOutlet var backgroundCell: BackgroundCollectionViewCell!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            print("imageView did set")
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView?.image = newValue
        }
    }
    
    var something = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("awakeFromNib")
        applyRoundCorners(.AllCorners, radius: 10.0)
    }
    
    // MARK: - Instance from nib
    
    class func instanceFromNib() -> BackgroundCollectionViewCell {
        return UINib(nibName: "BackgroundCollectionViewCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! BackgroundCollectionViewCell
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
//        let view = NSBundle.mainBundle().loadNibNamed("BackgroundCollectionViewCell", owner: self, options: nil)[0] as! BackgroundCollectionViewCell
//        self.addSubview(view)    // adding the top level view to the view hierarchy
        
//        backgroundCell = NSBundle.mainBundle().loadNibNamed("BackgroundCollectionViewCell", owner: self, options: nil)[0] as! BackgroundCollectionViewCell
//        self.addSubview(backgroundCell)    // adding the top level view to the view hierarchy
        
//        self.addSubview(view)
    
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        let view = NSBundle.mainBundle().loadNibNamed("BackgroundCollectionViewCell", owner: self, options: nil)[0] as! BackgroundCollectionViewCell
//        self.addSubview(view)    // adding the top level view to the view hierarchy

    }
}
