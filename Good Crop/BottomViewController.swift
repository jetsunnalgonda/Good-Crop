//
//  BottomViewController.swift
//  Containers
//
//  Created by Haluk Isik on 7/29/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit
import Photos

class BottomViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate //, AlbumsTableViewControllerDelegate, TopViewControllerDelegate
{
    // MARK: - Outlets
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!    
    
    // MARK: - Properties
    var selectedCellLayer: CAShapeLayer!
    var emptyCellLayer: CAShapeLayer!
    
    private var imageViewContentMode = UIViewContentMode.ScaleAspectFit
    private var selectedImageView: UIImageView?
    var maximumSelectableImages: Int = 4
    
    private var allIndexPaths = [NSIndexPath]()
    private var _cellImages: [UIImage?] = []
    
    var cellImages: [UIImage?] {
        get {
            return _cellImages
        }
        set {
            _cellImages = newValue
        }
    }
    private var droppedCellImages: [UIImage?] = []
    
    /// assets to pass to the parent view controller
    var assets: [PHAsset?] = []
//    var collectedAssetsCount = 0
    
    private var _albumsTableViewController: AlbumsTableViewController?
    var albumsTableViewController: AlbumsTableViewController? {
        get {
            return _albumsTableViewController
        }
        set {
            _albumsTableViewController = newValue
        }
    }
    private var _topViewController: TopViewController?
    var topViewController: TopViewController? {
        get {
            return _topViewController
        }
        set {
            _topViewController = newValue
        }
    }

    var selectedImageDropRow = 0 {
        didSet {
            print("selectedImageDropRow did set")
            selectedImageDropRow = selectedImageDropRow % maximumSelectableImages
        }
    }
    var cellOrigins: [CGPoint] = []

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view did load")
        cellImages = [UIImage?](count: maximumSelectableImages, repeatedValue: nil)
        droppedCellImages = [UIImage?](count: maximumSelectableImages, repeatedValue: nil)
        assets = [PHAsset?](count: maximumSelectableImages, repeatedValue: nil)

        label.text = "Select Photos (Maximum \(maximumSelectableImages))"
        
        cellOrigins.removeAll()
        for i in 0..<maximumSelectableImages {
            cellOrigins.append(CGPointZero)
            allIndexPaths.append(NSIndexPath(forRow: i, inSection: 0))
        }
        updateCellCoordinates()
        print("cellOrigins= \(cellOrigins)")
        print("view.bounds.size.height = \(view.bounds.size.height)")
        print("view.frame.size.height = \(view.frame.size.height)")


    }
    // MARK: - Actions
    @IBAction func done() {
        print("done")
//        albumsTableViewController?.cellImages = cellImages
//        albumsTableViewController?.dismiss()
//        topViewController?.dismissViewControllerAnimated(true, completion: nil)
        dismiss()
    }
    // MARK: - Methods
    func updateCellCoordinates()
    {
        print("updateCellCoordinates")
        print("cellOrigins = \(cellOrigins)")
        if cellOrigins.count >= maximumSelectableImages {
            for i in 0..<maximumSelectableImages {
                let indexPath = NSIndexPath(forItem: i, inSection: 0)
//                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.SelectedPhotoCell, forIndexPath: indexPath) as! ContainersCollectionViewCell
//                let frame = collectionView.convertRect(cell.frame, toView: view)
                var frame = collectionView.layoutAttributesForItemAtIndexPath(indexPath)!.frame
                frame = collectionView.convertRect(frame, toView: view)
                cellOrigins[i] = frame.origin
            }
        }
    }
    
    // MARK: - Scroll View Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateCellCoordinates()
    }

    // MARK: - Collection View Data Source
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
//        println("(BottomViewController) maximumSelectableImages = \(maximumSelectableImages)")
        return maximumSelectableImages
    }
    
    private struct Cell {
        static let SelectedPhotoCell = "selected photo cell"
        static let EmptyPhotoCell = "empty photo cell"
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.SelectedPhotoCell, forIndexPath: indexPath) as! ContainersCollectionViewCell
        
//        setupCollectionViewCell(cell)
//        drawDashedBorderAroundView(cell)
        
        switch indexPath.row {
        case selectedImageDropRow:
            setUpEmptyLayer(cell.layer)
            drawDashedBorderAroundView(cell, selected: true)
//            cell.borderLayer.hidden = true
            if droppedCellImages[indexPath.item] != nil {
//                setUpLayer(cell.layer)
                cell.imageView.clipsToBounds = true
                cell.imageView.contentMode = imageViewContentMode
            }
        default:
//            cell.borderLayer.hidden = false

            cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.EmptyPhotoCell, forIndexPath: indexPath) as! ContainersCollectionViewCell
            
            setUpEmptyLayer(cell.layer)
            drawDashedBorderAroundView(cell)
            
            if droppedCellImages[indexPath.row] != nil {
                setUpLayer(cell.layer)
                cell.imageView.clipsToBounds = true
                cell.imageView.contentMode = imageViewContentMode
            }
            
        }
        
        cell.imageView.image = droppedCellImages[indexPath.row]
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("item no \(indexPath.row) selected")
        selectedImageDropRow = indexPath.row
        print("item no \(indexPath.row) origins = \(cellOrigins[indexPath.row])")
//        selectedImageView = nil
//        let cell = self.collectionView.cellForItemAtIndexPath(indexPath)! as! ContainersCollectionViewCell
//        drawDashedBorderAroundView(cell, selected: true)
        collectionView.reloadData()
    }

    // MARK: - Collection View Cell
    
    // MARK: - Methods
    func setUpLayer(layer: CALayer)
    {
        layer.backgroundColor = UIColor.clearColor().CGColor
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.cornerRadius = 10.0
        
        //        layer.shadowOpacity = 0.7
        //        layer.shadowRadius = 10.0
        //        l.contents = UIImage(named: "star")?.CGImage
        layer.contentsGravity = kCAGravityCenter
        //        l.cornerRadius = margin
        layer.masksToBounds = true
        
    }
    func setUpEmptyLayer(layer: CALayer)
    {
        layer.backgroundColor = UIColor.clearColor().CGColor
        layer.borderWidth = 0.0
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.cornerRadius = 10.0
        
        //        layer.shadowOpacity = 0.7
        //        layer.shadowRadius = 10.0
        //        l.contents = UIImage(named: "star")?.CGImage
        layer.contentsGravity = kCAGravityCenter
        //        l.cornerRadius = margin
        layer.masksToBounds = true
        
    }
    func drawDashedBorderAroundView(v: UIView, selected: Bool = false)
    {
        //border definitions
        let cornerRadius: CGFloat = 10
        let borderWidth: CGFloat = 2
        let dashPattern1: NSInteger = 8
        let dashPattern2: NSInteger = 8
        let lineColor = selected ? UIColor.orangeColor() : UIColor.whiteColor()
        
        //drawing
        let frame = v.bounds
        
        let _shapeLayer: CAShapeLayer = CAShapeLayer(layer: v.layer)
        
        //creating a path
        let path = CGPathCreateMutable()
        
        //drawing a border around a view
        CGPathMoveToPoint(path, nil, 0, frame.size.height - cornerRadius)
        CGPathAddLineToPoint(path, nil, 0, cornerRadius)
        CGPathAddArc(path, nil, cornerRadius, cornerRadius, cornerRadius, CGFloat(M_PI), -CGFloat(M_PI_2), false)
        CGPathAddLineToPoint(path, nil, frame.size.width - cornerRadius, 0);
        CGPathAddArc(path, nil, frame.size.width - cornerRadius, cornerRadius, cornerRadius, CGFloat(-M_PI_2), 0, false)
        CGPathAddLineToPoint(path, nil, frame.size.width, frame.size.height - cornerRadius);
        CGPathAddArc(path, nil, frame.size.width - cornerRadius, frame.size.height - cornerRadius, cornerRadius, 0, CGFloat(M_PI_2), false)
        CGPathAddLineToPoint(path, nil, cornerRadius, frame.size.height)
        CGPathAddArc(path, nil, cornerRadius, frame.size.height - cornerRadius, cornerRadius, CGFloat(M_PI_2), CGFloat(M_PI), false)
        
        //path is set as the _shapeLayer object's path
        _shapeLayer.path = path
        
        _shapeLayer.backgroundColor = UIColor.clearColor().CGColor
        _shapeLayer.frame = frame
        _shapeLayer.masksToBounds = false
        _shapeLayer.setValue(NSNumber(bool: false), forKey: "isCircle")
        _shapeLayer.fillColor = UIColor.clearColor().CGColor
        _shapeLayer.strokeColor = lineColor.CGColor
        _shapeLayer.lineWidth = borderWidth
        _shapeLayer.lineDashPattern = [NSNumber(integer: dashPattern1), NSNumber(integer: dashPattern2)]
        _shapeLayer.lineCap = kCALineCapRound
        
        //_shapeLayer is added as a sublayer of the view, the border is visible
        v.layer.addSublayer(_shapeLayer)
        v.layer.cornerRadius = cornerRadius
        //        return _shapeLayer
    }

    func setupCollectionViewCell(cell: ContainersCollectionViewCell)
    {
        print("cell frame = \(cell.frame)")
        print("cell bounds = \(cell.bounds)")
        
//        if cell.isLayered { return }
        
        // Set up the shape layer for the view
        let maskPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: .AllCorners, cornerRadii: CGSizeMake(cell.cornerRadius, cell.cornerRadius))
        
        let maskPath2 = UIBezierPath(roundedRect: CGRectInset(view.bounds, 2, 2), byRoundingCorners: .AllCorners, cornerRadii: CGSizeMake(cell.cornerRadius, cell.cornerRadius))
        
        
        cell.maskLayer.frame = cell.bounds
        cell.maskLayer.path = maskPath.CGPath
        cell.maskLayer.masksToBounds = true
        //        layer.mask = maskLayer
        
        //        clipsToBounds = true
        
        // Add shadow
        let shadowLayer = CALayer()
        shadowLayer.shadowPath = cell.maskLayer.path
        shadowLayer.frame = view.layer.bounds
//        shadowLayer.shadowOffset = CGSizeMake(1.0, 1.0)
//        shadowLayer.shadowRadius = 2.0
//        shadowLayer.shadowOpacity = 0.6
//        shadowLayer.shadowColor = UIColor.blackColor().CGColor
        shadowLayer.masksToBounds = false
        
        // Add a stroke and set fill color
        //        let strokeLayer = CAShapeLayer()
        cell.dashedBorderLayer.path = maskPath2.CGPath
        cell.dashedBorderLayer.frame = shadowLayer.bounds
        cell.dashedBorderLayer.strokeColor = UIColor.orangeColor().CGColor
        cell.dashedBorderLayer.fillColor = UIColor.clearColor().CGColor
        cell.dashedBorderLayer.lineWidth = 2.0
        cell.dashedBorderLayer.lineDashPattern = [8, 8]
        cell.dashedBorderLayer.lineCap = kCALineCapRound
        cell.dashedBorderLayer.lineJoin = kCALineJoinRound
        cell.dashedBorderLayer.masksToBounds = true
        
        // Add another stroke and set fill color
        //        let strokeLayer2 = CAShapeLayer()
        cell.borderLayer.path = maskPath2.CGPath
        cell.borderLayer.frame = shadowLayer.bounds
        cell.borderLayer.strokeColor = UIColor.whiteColor().CGColor
        cell.borderLayer.fillColor = UIColor.clearColor().CGColor
        cell.borderLayer.lineWidth = 2.0
        cell.borderLayer.lineCap = kCALineCapRound
        cell.borderLayer.lineJoin = kCALineJoinRound
        cell.borderLayer.masksToBounds = true
        
        //        let containerLayer = CALayer()
        
        //        containerLayer.addSublayer(shadowLayer)
        //        containerLayer.addSublayer(maskLayer)
        
        
        shadowLayer.addSublayer(cell.dashedBorderLayer)
        shadowLayer.addSublayer(cell.borderLayer)
        cell.layer.addSublayer(shadowLayer)
        
        cell.isLayered = true
        
        //        strokeLayer2.hidden = true
        //        strokeLayer.hidden = true
        
        //        setupAnchorView()
        
    }
    
    // MARK: - Image drop animation
    func animateImageDrop(imageView: UIImageView, position: CGPoint, dropRow: Int)
    {
        view.addSubview(imageView)
        
        imageView.frame.origin = position
//        let imageDropRow = (selectedImageDropRow + maximumSelectableImages - 1) % maximumSelectableImages
//
//        println("imageDropRow = \(imageDropRow)")
        UIImageView.animateWithDuration(0.3, animations: { () -> Void in
            imageView.frame.origin = self.cellOrigins[dropRow]
            imageView.frame.size = CGSizeMake(100, 100)
        }) { (Bool) -> Void in
//            self.selectedImageView = imageView
            let indexPath = NSIndexPath(forItem: dropRow, inSection: 0)

            let cell = self.collectionView.cellForItemAtIndexPath(indexPath)! as! ContainersCollectionViewCell
            cell.imageView.image = nil
//            if let shapeLayer = cell.layer.sublayers.first as? CAShapeLayer {
//                shapeLayer.hidden = true
//            }
//            self.cellImages[self.selectedImageDropRow] = imageView.image
            self.droppedCellImages[dropRow] = self.cellImages[dropRow]
            print("self.collectionView.reloadData()")
            self.collectionView.layoutIfNeeded()
            self.collectionView.reloadItemsAtIndexPaths(self.allIndexPaths)
            
            imageView.removeFromSuperview()

//            self.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: self.selectedImageDropRow, inSection: 0)])
            
            // Scroll to the dropped cell
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: [.Top, .Left], animated: false)

        }
        print("cellOrigins[self.selectedImageDropRow] = \(cellOrigins[self.selectedImageDropRow])")

        print("selectedImageDropRow = \(selectedImageDropRow)")
    }

    // MARK: - Navigation
    private struct Segue {
        static let Top = "Top"
        static let Bottom = "Bottom"
        static let Album = "Album"
        static let Unwind = "Unwind Photo Gallery"
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        var destination: AnyObject = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
        if let identifier = segue.identifier {
            switch identifier {

            case Segue.Unwind:
                print("(bottom) unwinding")
                if let vc = destination as? ViewController {
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("vc.assets.count = \(vc.assets.count)")
                    print("assets that we got in BottomViewController: \(assets)")
//                    vc.assets.removeAll()
//                    for (key, asset) in enumerate(assets) {
//                        vc.assets.append(asset)
//                        println("asset = \(asset)")
//                    }
                    vc.assets = self.assets
//                    vc.collectedAssetsCount = self.collectedAssetsCount
//                    })
                }
                dismissViewControllerAnimated(true, completion: { () -> Void in
                    print("dismissed")

                })
            default: break
            }
        }
        
    }
    
    func dismiss() {
        performSegueWithIdentifier(Segue.Unwind, sender: self)
    }
}
