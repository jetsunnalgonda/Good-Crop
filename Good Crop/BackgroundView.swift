//
//  BackgroundView.swift
//  Good Crop
//
//  Created by Haluk Isik on 7/25/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit
//import ColorSlider

protocol BackgroundViewDelegate: class {
    var borderColor: UIColor { get set }
    var backgroundPattern: BackgroundPattern? { get set }
    var backgroundPatterns: [BackgroundPattern] { get }
}

class BackgroundView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate
{
    // MARK: - Outlets and properties
    
    weak var delegate: BackgroundViewDelegate?

    @IBOutlet weak var selectedColorButton: CoolButton!
    @IBOutlet weak var colorSlider: ColorSlider! {
        didSet {
            colorSlider.addTarget(self, action: "willChangeColor:", forControlEvents: .TouchDown)
            colorSlider.addTarget(self, action: "isChangingColor:", forControlEvents: .ValueChanged)
            colorSlider.addTarget(self, action: "didChangeColor:", forControlEvents: .TouchUpOutside)
            colorSlider.addTarget(self, action: "didChangeColor:", forControlEvents: .TouchUpInside)
        }
    }
    
    var color = UIColor.whiteColor() {
        didSet {
            selectedColorButton.backgroundColor = color
            delegate?.borderColor = color
            print("color= \(color.toHexString())")
        }
    }
    var selectedBackgroundPattern: BackgroundPattern? {
        didSet {
            delegate?.backgroundPattern = selectedBackgroundPattern!
        }
    }
    
    var backgroundPatterns = [String:String]()
    
    @IBOutlet weak var surroundingView: UIView! {
        didSet {
            surroundingView.applyRoundCorners(.AllCorners, radius: 8.0)
        }
    }
    
    @IBOutlet weak var patternView: UICollectionView! {
        didSet {
            patternView.delegate = self
            patternView.dataSource = self
//            patternView.applyRoundCorners(.AllCorners, radius: 8.0)
        }
    }
    
    
    // MARK: - Color Slider
    @IBAction func willChangeColor(slider: ColorSlider) {
        color = slider.color
    }
    
    @IBAction func isChangingColor(slider: ColorSlider) {
        color = slider.color
    }
    
    @IBAction func didChangeColor(slider: ColorSlider) {
        color = slider.color
    }
    
    // MARK: - Instance from nib
    class func instanceFromNib() -> BackgroundView {
        let backgroundView = UINib(nibName: "BackgroundView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! BackgroundView
        
//        backgroundView.patternView?.registerClass(BackgroundCollectionViewCell.self, forCellWithReuseIdentifier: Cell.Background)
        return backgroundView
    }
    
    func showColorPicker(sender: CoolButton)
    {
        print("showColorPicker")
    }
    // MARK: - Awake from nib
    override func awakeFromNib() {
//        patternView?.registerClass(BackgroundCollectionViewCell.self, forCellWithReuseIdentifier: Cell.Background)
        
        patternView.registerNib(UINib(nibName: "BackgroundCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: Cell.Background)
        
        print("delegate?.backgroundPatterns = \(delegate?.backgroundPatterns)")
    }
    
    // MARK: - Collection View
    
    private struct Cell {
        static let Background = "background cell"
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.Background, forIndexPath: indexPath) as! BackgroundCollectionViewCell
        
//        cell.image = UIImage(named: "star")
        cell.image = delegate?.backgroundPatterns[indexPath.item].image

//        cell.imageView.image = UIImage(named: "star")
        cell.contentMode = UIViewContentMode.ScaleAspectFill
        
        let number = indexPath.row
        
        print("number = \(number)")
        cell.backgroundColor = number % 2 == 0 ? UIColor.blueColor() : UIColor.orangeColor()

        cell.something = "sdfsd"
        
        return cell
    }
    
//    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
//    {
//        println("collectionView willDisplayCell")
//        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.Background, forIndexPath: indexPath) as! BackgroundCollectionViewCell
//        
//        cell.backgroundColor = UIColor.whiteColor()
////        cell.imageView.image = UIImage(named: "star")
//        println("cell.image = \(cell.image)")
//        
//        let number = indexPath.row
//        
//        println("number = \(number)")
//        cell.backgroundColor = number % 2 == 0 ? UIColor.blueColor() : UIColor.orangeColor()
//
//        println("cell.backgroundColor = \(cell.backgroundColor)")
//    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collectionView numberOfItemsInSection")
        
        return delegate?.backgroundPatterns.count ?? 0
    }
    //    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    //        return 1
    //    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        print("collectionView numberOfSectionsInCollectionView")
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let itemNo = indexPath.item
        
        selectedBackgroundPattern = delegate?.backgroundPatterns[indexPath.item]
        print("item no \(itemNo) selected")
    }
}
