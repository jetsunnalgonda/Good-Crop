//
//  TopViewController.swift
//  Containers
//
//  Created by Haluk Isik on 7/29/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit
import Photos

///// With this delegate, BottomViewController can send selected images to TopViewController
///// and dismiss the controller.
///// TopViewController will pass these images to parent view controller in the segue
//protocol TopViewControllerDelegate: class {
//    var topViewController: TopViewController? { get set }
//}

@available(iOS 8.0, *)
class TopViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BottomViewControllerDelegate, UIScrollViewDelegate
{
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
//    weak var delegate: TopViewControllerDelegate?
    
    var assets = [PHAssetCollection]()
    private var imageManager = PHCachingImageManager()
    var fetchResult: PHFetchResult!
    var imageViewContentMode = UIViewContentMode.ScaleAspectFill
    private var _bottomViewController: BottomViewController?
    var bottomViewController: BottomViewController? {
        get {
            return _bottomViewController
        }
        set {
            _bottomViewController = newValue
//            delegate = bottomViewController
//            delegate?.topViewController = self
        }
    }
    private var cellOrigins: [CGPoint] = []
    private var index: [Int] = []
    private var selectedImageRow = 0
    var scrolledToBottom = false

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "album-rightbarbutton"), style: .Plain, target: self, action: "changeImageViewContentMode")
        
        cellOrigins.removeAll()
        for _ in 0..<fetchResult.count {
            cellOrigins.append(CGPointZero)
        }
//        scrollToBottom()
//        updateCellOrigins()
//        cellOrigins.removeAll()
//        makeCellOrigins()
//        println("(TopViewController) cellOrigins= \(cellOrigins)")
    }
    override func viewDidAppear(animated: Bool)
    {
//        scrollToBottom()
    }
    override func viewDidLayoutSubviews()
    {
        // Scroll to bottom only once
        if !scrolledToBottom {
            scrollToBottom()
            scrolledToBottom = true
        }
    }
    
    /// Scrolls to the bottom of the collection view
    func scrollToBottom()
    {
        let section = collectionView.numberOfSections() - 1
        let item = collectionView.numberOfItemsInSection(section) - 1
        let indexPath = NSIndexPath(forItem: item, inSection: section)
        
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: false)
    }
    func updateCellOrigins()
    {
        print("view.frame.size = \(view.frame.size)")
        if cellOrigins.count >= fetchResult.count {

            let indexPathRows = collectionView.indexPathsForVisibleItems().map({ $0.item })
            
            let startIndex = indexPathRows.reduce(Int.max, combine: { min($0, $1) })
            let endIndex = indexPathRows.reduce(Int.min, combine: { max($0, $1) })
            
            print("startIndex = \(startIndex)")
            print("endIndex = \(endIndex)")
            print("collectionView.indexPathsForVisibleItems() = \(collectionView.indexPathsForVisibleItems())")
            print("collectionView.indexPathsForVisibleItems().count = \(collectionView.indexPathsForVisibleItems().count)")
            
            if startIndex <= endIndex {
                for i in startIndex...endIndex {
                    let indexPath = NSIndexPath(forItem: i, inSection: 0)
                    var frame = collectionView.layoutAttributesForItemAtIndexPath(indexPath)!.frame
                    frame = collectionView.convertRect(frame, toView: view)

                    cellOrigins[i] = frame.origin
                    print("cellOrigins[\(i)] = \(cellOrigins[i])")
                }
            }
        }

    }
    // MARK: - Scroll View Delegate
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        updateCellOrigins()
//    }
    
    // MARK: - Collection View Data Source
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let width = view.bounds.size.width
        var numberOfItemsPerRow: CGFloat = 4
        let spacing: CGFloat = 5
        
        switch imageViewContentMode {
        case .ScaleAspectFill:
            numberOfItemsPerRow = 4
        case .ScaleAspectFit:
            numberOfItemsPerRow = 3
        default: break

        }
        
        let itemLength = (width - (numberOfItemsPerRow - 1) * spacing) / numberOfItemsPerRow
        
        return CGSizeMake(itemLength, itemLength)
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return fetchResult.count
    }
    
    private struct Cell {
        static let Photo = "photo"
    }
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
    {
        print("willDisplayCell")

    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.Photo, forIndexPath: indexPath) as! ContainersCollectionViewCell
        
        if cellOrigins.count >= fetchResult.count {
            index.removeAll()
            index.append(indexPath.item)
            let frame = collectionView.convertRect(cell.frame, toView: view)
            cellOrigins[indexPath.item] = frame.origin
        }
        
        cell.imageView.clipsToBounds = true
        cell.imageView.contentMode = imageViewContentMode
        
        let frame = collectionView.convertRect(cell.frame, toView: view)
        print("cell.frame = \(cell.frame)")
        print("(new) frame = \(frame)")
        

        // Increment the cell's tag
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        
        let asset = fetchResult[indexPath.item] as? PHAsset
        imageManager.requestImageForAsset(asset!,
            targetSize: CGSizeMake(cell.bounds.size.width * 2, cell.bounds.size.height * 2),
            contentMode: PHImageContentMode.AspectFill,
            options: nil) {
                result, info in
                
                // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                if cell.tag == currentTag {
//                    cell.thumbnailImage = result
                    cell.imageView.image = result
                }
        }

        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("item no \(indexPath.row) selected")
        print("indexPath.item = \(indexPath.item)")
        
//        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height

        selectedImageRow = indexPath.row
        updateCellOrigins()
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)! as! ContainersCollectionViewCell
        let departureFrameOrigin = cellOrigins[indexPath.item]
//        let departureFrameOrigin = collectionView.convertRect(cell.frame, toView: view).origin

//        let departureFrameOrigin = cell.convertRect(cell.frame, toView: view).origin
        
        print("departureFrameOrigin = \(departureFrameOrigin)")
        
        let frame = collectionView.layoutAttributesForItemAtIndexPath(indexPath)!.frame
//        cell.imageView.contentMode = UIViewContentMode.ScaleAspectFill
//        var frame = cell.imageView.frame
        
//        frame = collectionView.convertRect(frame, toView: view)
        
        print("cell.frame = \(cell.frame)")
        print("frame = \(frame)")
        print("cell.bounds = \(cell.bounds)")
        
        let contentMode = cell.imageView.contentMode
        cell.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        let snapShotImage = cell.takeSnapshot()

//        let snapShotImage = cell.imageView.image
        
        let animatedView = UIImageView(frame: CGRectMake(departureFrameOrigin.x, departureFrameOrigin.y, cell.bounds.size.width, cell.bounds.size.height))
        animatedView.image = snapShotImage

        let offsetX = departureFrameOrigin.x
        let offsetY = departureFrameOrigin.y - view.bounds.size.height
        let position = CGPointMake(offsetX, offsetY)
        
        print("view.bounds.size.height = \(view.bounds.size.height)")
        print("view.frame.size.height = \(view.frame.size.height)")
        print("bottomViewController!.view.bounds.size.height = \(bottomViewController!.view.bounds.size.height)")
        print("bottomViewController!.view.frame.size.height = \(bottomViewController!.view.frame.size.height)")
        print("position = \(position)")
        
        let snapShotImage2 = cell.takeSnapshot()
        let animatedView2 = UIImageView(frame: frame)
        animatedView2.image = snapShotImage2

        cell.imageView.contentMode = contentMode

        let destinationIndexPath = NSIndexPath(forItem: bottomViewController!.selectedImageDropRow, inSection: 0)
        let destinationFrameOrigin = bottomViewController!.cellOrigins[destinationIndexPath.row]
        
        print("destinationIndexPath.row = \(destinationIndexPath.row)")
        print("destinationFrameOrigin = \(destinationFrameOrigin)")
        
        let offsetX2 = destinationFrameOrigin.x
        let offsetY2 = destinationFrameOrigin.y + view.bounds.size.height
        let destination = CGPointMake(offsetX2, offsetY2)

        print("destinationFrameOrigin = \(destinationFrameOrigin)")
        print("destination = \(destination)")
        
        let dropRow = bottomViewController!.selectedImageDropRow
        
        bottomViewController?.animateImageDrop(animatedView, position: position, dropRow: dropRow)
        animateImageDrop(animatedView2, destination: destination)
        
        // Send the asset to BottomViewController
        // who will then send it to our main crop view
//        bottomViewController?.collectedAssetsCount++
//        dispatch_async(dispatch_get_main_queue()) {
        let asset = self.fetchResult[indexPath.item] as? PHAsset
        self.bottomViewController?.assets[destinationIndexPath.row] = asset
        print("asset i am sending to BottomViewController: \(asset)")
        print("this is the asset order: \(destinationIndexPath.row)")
        
        
        // Set the bottomViewController's cellImages right here so that the bottomViewController
        // can handle the order of images and selectedImageDropRow when we are dropping
        // images really fast
        bottomViewController!.cellImages[dropRow] = animatedView2.image
        bottomViewController!.selectedImageDropRow++
        
//        }

    }
    // MARK: - Methods
    
    func changeImageViewContentMode()
    {
        imageViewContentMode = imageViewContentMode == .ScaleAspectFill ? .ScaleAspectFit : .ScaleAspectFill

        let indexPathRows = collectionView.indexPathsForVisibleItems().map({ $0.item })
        let topLeftItemIndex = indexPathRows.reduce(Int.max, combine: { min($0, $1) })
        let indexPath = NSIndexPath(forItem: topLeftItemIndex, inSection: 0)

        
        print("topLeftItemIndex = \(topLeftItemIndex)")
        collectionView.reloadData()
        // Keep the top left image same after transitions
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: [.Top, .Left], animated: false)
//        self.updateCellOrigins()
        
//        collectionView.performBatchUpdates({ () -> Void in
//            self.collectionView.reloadData()
//
////            self.collectionView.setNeedsLayout()
//        }, completion: { (boolValue) -> Void in
////            self.updateCellOrigins()
//            self.collectionView.setNeedsDisplay()
//            self.collectionView.collectionViewLayout.invalidateLayout()
//            self.collectionView.reloadData()
//            
//            // Keep the top left image same after transitions
//            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: false)
//
//        })
        
    }
    
    // MARK: - Image drop animation
    func animateImageDrop(imageView: UIImageView, destination: CGPoint)
    {
//        let indexPath = NSIndexPath(forItem: selectedImageRow, inSection: 0)
//        var origin = collectionView.layoutAttributesForItemAtIndexPath(indexPath)!.frame.origin

        view.addSubview(imageView)
        imageView.frame.origin = cellOrigins[self.selectedImageRow]
//        imageView.frame.origin = origin
        
        UIImageView.animateWithDuration(0.3, animations: { () -> Void in
            imageView.backgroundColor = UIColor.redColor()
            imageView.frame.origin = destination
            imageView.frame.size = CGSizeMake(100, 100)
        })
    }
}
