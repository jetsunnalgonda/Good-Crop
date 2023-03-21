//
//  ViewController.swift
//  Good Crop
//
//  Created by Haluk Isik on 7/20/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit
import Photos
import iAd

class ViewController: UIViewController, SwiftColorPickerDelegate, UIPopoverPresentationControllerDelegate, FrameViewDelegate, BackgroundViewDelegate, CollageViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, ADBannerViewDelegate
{
    // MARK: - Outlets
    
    @IBOutlet weak var collageView: CollageView! {
        didSet {

            addGestureRecognizersForWrapperViews()
        }
    }
    
    @IBOutlet weak var hiddenView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: "hideBottomViews")
            tap.numberOfTapsRequired = 1
            tap.cancelsTouchesInView = true
            hiddenView.addGestureRecognizer(tap)
        }
    }
    

    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var adBannerView: ADBannerView!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewWidth: NSLayoutConstraint!
    @IBOutlet weak var centerY: NSLayoutConstraint!

    @IBOutlet var marginConstraints: [NSLayoutConstraint]!

    @IBOutlet weak var informationLabel: UILabel! {
        didSet {
            informationLabel.text = ""
            informationLabel.alpha = 0.0
            informationLabel.applyRoundCorners(.TopLeft | .BottomRight, radius: 8.0)
        }
    }
    @IBOutlet weak var mainView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: "hideBottomViews")
            tap.numberOfTapsRequired = 1
            tap.cancelsTouchesInView = true
            mainView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var selectFrameView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: "selectFrame")
            tap.numberOfTapsRequired = 1
            tap.cancelsTouchesInView = false
            selectFrameView?.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var selectBackgroundView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: "selectBackground")
            tap.numberOfTapsRequired = 1
            tap.cancelsTouchesInView = false
            selectBackgroundView?.addGestureRecognizer(tap)
        }
    }
    
//    @IBOutlet weak var scrollView: UIScrollView! {
//        didSet {
//            scrollView.contentSize = imageView.frame.size // critical to set this!
//            scrollView.delegate = self                    // required for zooming
//            scrollView.minimumZoomScale = minimumZoomScale            // required for zooming
//            scrollView.maximumZoomScale = 1.0             // required for zooming
//            scrollView.bouncesZoom = false
//            
//            
//            let press = UILongPressGestureRecognizer(target: self, action: "loadPhotoGallery")
////            press.cancelsTouchesInView = false
//            scrollView.addGestureRecognizer(press)
//            
//            let doubleTap = UITapGestureRecognizer(target: self, action: "loadPhotoGallery")
//            doubleTap.numberOfTapsRequired = 2
//            doubleTap.cancelsTouchesInView = true
//            scrollView.addGestureRecognizer(doubleTap)
//            
//        }
//    }
    
    // MARK: - Properties
    private var imageManager = PHCachingImageManager()
    var assetCollection = PHAssetCollection()
//    var collectedAssetsCount = 0

    var selectedViewTag = 0
    var selectedViewTags = [Int]()
    
    var mode: Mode = .None {
        didSet {
            switch mode {
            case .Remove(_):
                frameView.switchButton.selected = false
                frameView.removeButton.selected = true
                
                blinkingInformation = "Select the image to remove"
                
            case .Switch(_):
                println("Switch mode")
                frameView.removeButton.selected = false
                frameView.switchButton.selected = true
                
                blinkingInformation = "Select the first image"
                
            case .None:
                println("mode is none")
                for view in collageView.wrapperViews {
                    view.alpha = 1.0
                }
                selectedViewTags.removeAll()
                
                blinkingInformation = nil
                frameView.removeButton.selected = false
                frameView.switchButton.selected = false
                
            }
        }
    }
    
    var removeImage: Mode!
    var switchImages: Mode!

    var frameView = FrameView.instanceFromNib()
    var backgroundView = BackgroundView.instanceFromNib()
    
    // CollageViewDelegate property
    var compositionType = CompositionType.One
        
//        {
//        didSet {
//            for wrapperView in collageView.wrapperViews {
//                println("compo = \(compositionType)")
//                wrapperView.compositionType = compositionType
//            }
//        }
//    }
    
    var images = [UIImage?]() {
        didSet {
            collageView.images = images
            blinkingInformation = "Tap on the frames to load a photo"
            for image in images {
                if let newImage = image { blinkingInformation = nil }
            }

        }
    }
    
//    var images: [UIImage?] = []
    var assets: [PHAsset?] = []
    
    var controller = UIActivityViewController(activityItems: [], applicationActivities: nil)
    
    var information: String? {
        didSet {
            if information == nil {
                println("information is nil")
                UILabel.animateWithDuration(3.0, animations: { () -> Void in
                    self.informationLabel.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        if let info = self.blinkingInformation {
                            self.blinkingInformation = info
                        }
                    }
                })

            } else {
                println("information is not nil")
                self.informationLabel.text = self.information
                self.informationLabel.alpha = 0.8

            }
        }
    }
    
    var blinkingInformation: String? {
        didSet {
            if blinkingInformation == nil {
                informationLabel.layer.removeAllAnimations()
                informationLabel.text = ""
                informationLabel.alpha = 0.0
            } else {
                informationLabel.text = blinkingInformation
                informationLabel.alpha = 0.8
                UIView.animateKeyframesWithDuration(0.6, delay: 0.3, options: .Repeat | .Autoreverse, animations: { () -> Void in
                    self.informationLabel.alpha = 0.5
                }, completion: { (Bool) -> Void in
                    
                })
            }
        }
    }
    
    /// Our container view will be obscured by frameView or backgroundView
    /// Therefore we move the view up this amount every time the user slides
    /// up one of these views
    var clippedHeight: CGFloat? {
        didSet {
            let saveZoomScale = clippedHeight == 0 ? true : false
            adjustSize()
        }
    }

    // Properties that adjusts scroll view size for image view
//    var minimumZoomScale: CGFloat = 1.0 {
//        didSet {
//            scrollView?.minimumZoomScale = minimumZoomScale
//            if scrollView?.zoomScale < minimumZoomScale {
//                scrollView?.zoomScale = minimumZoomScale
//            }
//            println("scrollView?.zoomScale = \(scrollView?.zoomScale)")
//            println("scrollView?.minimumZoomScale = \(scrollView?.minimumZoomScale)")
//            println("scrollView?.contentSize = \(scrollView?.contentSize)")
//            println("scrollView.frame = \(scrollView.frame)")
//
//        }
//    }

    var contentOffsetX: CGFloat = 0.0 {
        didSet {
            println("contentOffsetX = \(contentOffsetX)")
        }
    }
    var contentOffsetY: CGFloat = 0.0 {
        didSet {
            println("contentOffsetY = \(contentOffsetY)")
        }
    }
    
    // MARK: Frame View Properties
    var margin: CGFloat {
        get {
            return _margin
        }
        set {
            println("margin = \(newValue)")
            information = "Margin: \(newValue)"
            information = nil
            _margin = newValue
            
//            l.borderWidth = newValue
            for marginConstraint in marginConstraints {
                marginConstraint.constant = newValue
            }
            
            adjustSize()
        }
    }
    private var _margin: CGFloat = 0
    
    var spacing: Float {
        get {
            return _spacing
        }
        set {
            information = "Spacing: \(newValue)"
            information = nil
            _spacing = newValue
            collageView.spacing = CGFloat(newValue)
        }
    }
    private var _spacing: Float = 0
    
    var aspectRatio: CGFloat {
        get {
            return _aspectRatio
        }
        set {
            println("aspectRatio setter = \(newValue)")
            _aspectRatio = newValue
            
            println("(aspectRatio setter) newValue = \(newValue)")
            println("(aspectRatio setter) aspectRatio = \(aspectRatio)")
            
            adjustSize()
        }
    }
    private var _aspectRatio: CGFloat = 1
    
    var aspectRatioText: String {
        get {
            return _aspectRatioText
        }
        set {
            information = "Aspect ratio: \(newValue)"
            information = nil
            _aspectRatioText = newValue
            
        }
    }
    private var _aspectRatioText: String = ""
    
    
    var frameType: Int {
        get {
            return _frameType
        }
        set {
            if let selectedCompositionType = CompositionType(rawValue: newValue) {
                compositionType = selectedCompositionType
                collageView.compositionType = selectedCompositionType
                
                println("compositionType = \(compositionType)")
                
                addGestureRecognizersForWrapperViews()
                
                information = "\(compositionType)"
                information = nil
                _frameType = newValue
            }
        }
    }
    private var _frameType = 1
    
    // MARK: Background view properties
    var borderColor: UIColor {
        get {
            return _borderColor
        }
        set {
            information = "Color: \(newValue.toHexString())"
            information = nil
            _borderColor = newValue
            
            mainView.backgroundColor = borderColor
            
//            backgroundPattern = nil
//            l.backgroundColor = borderColor.CGColor
//            l.borderColor = borderColor.CGColor
        }
    }
    private var _borderColor = UIColor.whiteColor()
    
    var backgroundPattern: BackgroundPattern? {
        get {
            return _backgroundPattern
        }
        set {
            _backgroundPattern = newValue
            let artworkName = _backgroundPattern?.artworkName ?? ""
            let artistName = _backgroundPattern?.artistName ?? ""
            information = "\(artworkName) by \(artistName)"
            information = nil
            
            if let image = newValue {
                mainView.backgroundColor = UIColor(patternImage: newValue!.image)
            }
        }
    }
    private var _backgroundPattern: BackgroundPattern?
    
    /// A dictionary that holds the background pattern file names, and their numbers
    /// and the description of the images: the name of the artwork and the artist who drew it.
//    var backgroundPatternNames = [Int: [String: String]]()
    
//    var backgroundPatterns = [UIImage]()
    var backgroundPatterns: [BackgroundPattern] {
        return BackgroundPattern.getDefaultPatterns()
    }
    // MARK: - Methods
    
    func setUpMainView()
    {
        // Add shadow
//        let shadowPath = UIBezierPath(rect: mainView.bounds)
        mainView.layer.masksToBounds = false
//        mainView.layer.shadowPath = shadowPath.CGPath
        mainView.layer.shadowOffset = CGSizeMake(2.0, 2.0)
        mainView.layer.shadowRadius = 4.0
        mainView.layer.shadowOpacity = 0.6
        mainView.layer.shadowColor = UIColor.blackColor().CGColor
        
    }
    func addGestureRecognizersForWrapperViews()
    {
        for wrapperView in collageView.wrapperViews {
            let press = UILongPressGestureRecognizer(target: self, action: "loadPhotoGallery:")
            let singleTap = UITapGestureRecognizer(target: self, action: "selectFrame:")
            //                let doubleTap = UITapGestureRecognizer(target: self, action: "loadPhotoGallery:")
            
            //                singleTap.requireGestureRecognizerToFail(doubleTap)
            //                doubleTap.numberOfTapsRequired = 2
            //                doubleTap.cancelsTouchesInView = true
            
            println("gesture recognizers added")
            wrapperView.addGestureRecognizer(press)
            wrapperView.addGestureRecognizer(singleTap)
            //                wrapperView.addGestureRecognizer(doubleTap)
        }
    }
    func cropIt()
    {
        println("crop it")
    }
    

    func adjustSize()
    {
        // TODO: instead of collageView.bounds.width
        // maybe collageView.bounds.width - spacing / 2 ?
        collageView.anchorPointRelative.removeAll()
        for (key, _) in enumerate(collageView.anchorPoints) {
            collageView.anchorPointRelative.append(CGPointMake(collageView.anchorPoints[key].x / collageView.bounds.width, collageView.anchorPoints[key].y / collageView.bounds.height))

        }
        
        // Setup container
        var containerMargins: CGFloat = 10.0
        var containerBottomFrameHeight: CGFloat = clippedHeight! == 0 ? 100 : clippedHeight!
        let containerWidth = view.bounds.size.width - containerMargins * 2
        let containerHeight = view.bounds.size.height - containerMargins * 2 - containerBottomFrameHeight - topLayoutGuide.length
        
        
        let currentAspectRatio = viewWidth.constant / viewHeight.constant
        let aspectRatioMultiplier = aspectRatio / currentAspectRatio
        
        var newWidth = viewWidth.constant * aspectRatioMultiplier
        var newHeight = viewHeight.constant

        let widthToBoundsWidthRatio = newWidth / containerWidth
        newWidth = newWidth / widthToBoundsWidthRatio
        newHeight = newHeight / widthToBoundsWidthRatio
        
        if newHeight > containerHeight {
            let heightToBoundsHeightRatio = newHeight / containerHeight
            newWidth = newWidth / heightToBoundsHeightRatio
            newHeight = newHeight / heightToBoundsHeightRatio
        }
        
        UIView.animateWithDuration(0.0, animations: { () -> Void in
            self.viewHeight.constant = newHeight
            self.viewWidth.constant = newWidth
            self.centerY.constant = self.clippedHeight > 0 ? (self.clippedHeight! - 50) / 2 : 30
            self.mainView.layoutIfNeeded()
            self.collageView.layoutIfNeeded()

//            if self.image != nil { self.adjustImageSize(saveZoomScale: saveZoomScale) }

        })
        
        
        println("2 collageView.anchorPointRelative = \(collageView.anchorPointRelative)")

    }
    
    // MARK: Handling tap gesture

    func selectFrame(gesture: UIGestureRecognizer)
    {
        let view: ShapedScrollContainerView = gesture.view as! ShapedScrollContainerView
        selectedViewTag = view.tag
        println("selectedViewTag = \(selectedViewTag)")

        view.alpha = 0.3
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            view.alpha = 1.0
        })

        switch mode {
        case .Remove(let removeIt):
            let (errorCode, errorMessage) = removeIt(view.tag)
            
            mode = .None
            information = errorMessage!
            information = nil
            
        case .Switch(let switchIt):
            selectedViewTags.append(view.tag)
            println("selectedViewTags = \(selectedViewTags)")
            view.alpha = 0.3
            
            let (errorCode, errorMessage) = switchIt(selectedViewTags)
            
            if errorCode < 2 {
                mode = .None
                information = errorMessage!
                information = nil
                
            } else if errorCode == 2 {
                blinkingInformation = errorMessage!
            } else if errorCode == 3 {
                mode = .None
            }
            
        case .None:
            if !frameView.isDescendantOfView(self.view) {
                loadPhotoGallery(gesture)
            }
            
        }
        
    }
    
    func removeButtonPressed()
    {
        switch mode {
        case .Remove(_):
            mode = .None
        default:
            mode = removeImage
        }
    }
    func switchButtonPressed()
    {
        switch mode {
        case .Switch(_):
            mode = .None
        default:
            mode = switchImages
        }
    }
    func aspectFillButtonPressed()
    {
        collageView.wrapperViews[selectedViewTag].imageContentMode = .ScaleAspectFill
        information = "Content mode for Frame \(selectedViewTag + 1) is changed to Aspect Fill"
        information = nil
    }
    func aspectFitButtonPressed()
    {
        collageView.wrapperViews[selectedViewTag].imageContentMode = .ScaleAspectFit
        information = "Content mode for Frame \(selectedViewTag + 1) is changed to Aspect Fit"
        information = nil
    }
    func flipButtonPressed()
    {
        if let image = images[selectedViewTag] {
//            let copiedImage = CGImageCreateCopy(image)
            
            var or = ""
            switch image.imageOrientation {
            case .Up:
                or = "Up"
            case .Down:
                or = "Down"
            case .Left:
                or = "Left"
            case .Right:
                or = "Right"
            case .UpMirrored:
                or = "Up Mirrored"
            case .DownMirrored:
                or = "Down Mirrored"
            case .LeftMirrored:
                or = "Left Mirrored"
            case .RightMirrored:
                or = "Right Mirrored"
            default:
                or = "Unknown"
            }


            let flippedImage = UIImage(CGImage: image.CGImage, scale: UIScreen.mainScreen().scale, orientation: image.verticalFlippedOrientation())
            images[selectedViewTag] = flippedImage
            
            println("image orientation is \(or)")
        }
//        println("image scale is \(images[selectedViewTag]!.scale)")
//        println("image orientation is \(images[selectedViewTag]!.imageOrientation)")
        
    }
    
    // MARK: Photo Gallery related methods
    private struct Album {
        static let FolderName = "Good Crop"
    }
    func createAlbum() {
        var albumFound = false
//        var assetCollection = PHAssetCollection()
        var assetCollectionPlaceholder: PHObjectPlaceholder!
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", Album.FolderName)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if let first_obj: AnyObject = collection.firstObject {
            albumFound = true
            assetCollection = collection.firstObject as! PHAssetCollection
        } else {
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                var createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(Album.FolderName)
                assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: { success, error in
                    albumFound = (success ? true: false)
                    
                    if (success) {
                        var collectionFetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([assetCollectionPlaceholder.localIdentifier], options: nil)
                        print(collectionFetchResult)
                        self.assetCollection = collectionFetchResult?.firstObject as! PHAssetCollection
                    }
            })
        }
    }
    func saveToAlbum(imageToSave: UIImage?)
    {
        var assets : PHFetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)

        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(imageToSave)
            let assetPlaceholder = assetRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection, assets: assets)
            albumChangeRequest.addAssets([assetPlaceholder])
            }, completionHandler: { success, error in
                print("added image to album")
                print(error)
                
                self.showImages()
        })
    }
    func showImages() {
        var assets : PHFetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
        print(assets)

        let imageManager = PHCachingImageManager()
        
        assets.enumerateObjectsUsingBlock{(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            
            if object is PHAsset {
                let asset = object as! PHAsset
                print(asset)
                
                let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .FastFormat
                
                imageManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: .AspectFill, options: options, resultHandler: {(image: UIImage!,
                    info: [NSObject : AnyObject]!) in
                    print(info)
                    print(image)
                })
            }
            
        }
        
    }
    
    func loadPhotoGallery(gesture: UIGestureRecognizer)
    {
        let view: ShapedScrollContainerView = gesture.view as! ShapedScrollContainerView
        selectedViewTag = view.tag
        println("selectedViewTag = \(selectedViewTag)")
        
        // Add a dark overlay to the frame to indicate it is selected
//        let darkOverlay = CAShapeLayer()
//        darkOverlay.strokeColor = UIColor.whiteColor().CGColor
//        darkOverlay.fillColor = UIColor.orangeColor().CGColor
//        darkOverlay.lineWidth = 2.0
//        
//        view.layer.addSublayer(darkOverlay)
        
        
        let backgroundColor = view.backgroundColor
        view.backgroundColor = UIColor(rgba: "#11223355")
        view.alpha = 0.3
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            view.backgroundColor = backgroundColor
            view.alpha = 1.0
//            darkOverlay.removeFromSuperlayer()
            })
            
        dispatch_async(dispatch_get_main_queue()) {
            // update some UI
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.allowsEditing = false
//            imagePicker.sourceType = .PhotoLibrary

//            self.presentViewController(imagePicker, animated: true, completion: nil)
            self.performSegueWithIdentifier(Segue.PhotoGallery, sender: self)

        }

//        performSegueWithIdentifier("load image", sender: self)
    }
    
    /// Loads the images to the layers on the main screen
    private func loadImage()
    {
        let scale = UIScreen.mainScreen().scale
        let targetSize = CGSizeMake(CGRectGetWidth(collageView.wrapperViews[selectedViewTag].bounds) * scale, CGRectGetHeight(collageView.wrapperViews[selectedViewTag].bounds) * scale)
        
        let options = PHImageRequestOptions()
        options.synchronous = true
        options.version = .Current
        options.deliveryMode = .HighQualityFormat
        options.resizeMode = .Exact

        dispatch_async(dispatch_get_main_queue()) {

            for i in 0..<self.assets.count {
                let itemNo = (self.selectedViewTag + i) % self.compositionType.maximumImageCount
                println("loading itemNo: \(itemNo)")
                PHImageManager.defaultManager().requestImageForAsset(self.assets[i], targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: options) {result, info in
                    if result != nil {
                        self.images[itemNo] = result
                    }
                }
            }
            self.assets.removeAll()

        }

    }
    
    private struct Defaults {
        static let ShorterSideLengthSmall: CGFloat = 640
        static let ShorterSideLengthMedium: CGFloat = 1080
        static let ShorterSideLengthLarge: CGFloat = 2160
    }
    /**
    This method presents an action sheet to choose the desired image size and share it.
    
    */
    func selectSize()
    {
        hideBottomViews()

        let width = mainView.bounds.width
        let height = mainView.bounds.height
        
        let shorterSide = width < height ? width : height
        var aspectRatio = shorterSide == width ? self.aspectRatio : 1 / self.aspectRatio
        
        // Some tweaks
        if round(aspectRatio * 100) / 100 == 1.78 { aspectRatio = 1.775 }

        let scaleFactorLarge = floor((Defaults.ShorterSideLengthLarge / shorterSide) * 10000) / 10000
        let scaleFactorMedium = floor((Defaults.ShorterSideLengthMedium / shorterSide) * 100000) / 100000
        let scaleFactorSmall = floor((Defaults.ShorterSideLengthSmall / shorterSide) * 500) / 500
        
        let large = "(\(ceil(width * scaleFactorLarge).int)x\(ceil(height * scaleFactorLarge).int))"
        let medium = "(\(ceil(width * scaleFactorMedium).int)x\(ceil(height * scaleFactorMedium).int))"
        let small = "(\(ceil(width * scaleFactorSmall).int)x\(ceil(height * scaleFactorSmall).int))"
        
        var selectSize = UIAlertController(title: "Select size", message: "Select a size to share your image.", preferredStyle: .ActionSheet)

        selectSize.addAction(UIAlertAction(title: "Large \(large)", style: .Default, handler: { (action: UIAlertAction!) -> Void in
            self.share(scaleFactor: scaleFactorLarge)
        } ))
        selectSize.addAction(UIAlertAction(title: "Medium \(medium)", style: .Default, handler: { (action: UIAlertAction!) -> Void in
            self.share(scaleFactor: scaleFactorMedium)
        } ))
        selectSize.addAction(UIAlertAction(title: "Small \(small)", style: .Default, handler: { (action: UIAlertAction!) -> Void in
            self.share(scaleFactor: scaleFactorSmall)
        }))
        selectSize.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) -> Void in
            return
        }))
        
        
        // This line is for iPad
        selectSize.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
//        selectSize.popoverPresentationController!.sourceRect = self.navigationItem.rightBarButtonItem.
        
        presentViewController(selectSize, animated: true, completion: {
            //            self.activityLabel.hidden = false
        } )
        
    }
    /**
    Share the image using any of the methods available
    
    :param: scaleFactor: Variable used to adjust the quality and also the size of the image to be shared. Default value is 4.0
    
    */
    func share(scaleFactor: CGFloat = 4.0)
    {
        activityLabel.hidden = false
        spinner.startAnimating()

        let anchorViewVisibility = collageView.anchorViews.first!.hidden
        for anchorView in collageView.anchorViews {
            anchorView.hidden = true
        }
        for wrapperView in collageView.wrapperViews {
            if let strokeLayer = wrapperView.layer.sublayers.first as? CAShapeLayer {
                strokeLayer.hidden = true
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
//            if var backgroundImage = self.backgroundPattern?.image {
//                UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, scaleFactor)
//                backgroundImage.drawInRect(CGRectMake(0, 0, backgroundImage.size.width / scaleFactor, backgroundImage.size.height / scaleFactor), blendMode: kCGBlendModeNormal, alpha: 1.0)
//                backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
//                
//                self.mainView.backgroundColor = UIColor(patternImage: backgroundImage)
//                UIGraphicsEndImageContext()
//
//            }
            
            
            UIGraphicsBeginImageContextWithOptions(self.mainView.bounds.size, false, scaleFactor)
            self.mainView.layer.renderInContext(UIGraphicsGetCurrentContext())
            let imageToShare = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if imageToShare != nil {
                self.controller = UIActivityViewController(activityItems: [imageToShare!], applicationActivities: nil)
                
                self.controller.completionWithItemsHandler = {
                    activityType, completed, returnedItems, activityError in
                    
//                    if let backgroundImage = self.backgroundPattern?.image {
//                        self.mainView.backgroundColor = UIColor(patternImage: backgroundImage)
//                    }
                    
                    self.collageView.anchorViews.first!.hidden = anchorViewVisibility
                    for wrapperView in self.collageView.wrapperViews {
                        if let strokeLayer = wrapperView.layer.sublayers.first as? CAShapeLayer {
                            strokeLayer.hidden = false
                        }
                    }

                    self.activityLabel.hidden = true
                    self.spinner.stopAnimating()

//                    switch activityType {
//                    case UIActivityTypeSaveToCameraRoll:
//                        println("Saving image")
//                        self.createAlbum()
//                        self.saveToAlbum(imageToShare)
//                        self.controller.dismissViewControllerAnimated(true, completion: { () -> Void in
//                            self.information = "Saving image"
//                            self.information = nil
//
//                        })
//                    default:
//                        break
//                    }
                    
                    if completed {
                        switch activityType {
                        case UIActivityTypeSaveToCameraRoll:
                            println("image saved")
                            self.information = "Image Saved"
                            self.information = nil
                        default:
                            break
                        }
                        println("completed")
                        
                    }
                    
                }
                // This line is for iPad
                self.controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

                self.presentViewController(self.controller, animated: true, completion: nil)
                
                
            }
        }
        
        
        
        
    }
    
    // MARK: Initialize modes
    
    func initializeModes()
    {
        removeImage = Mode.Remove { viewTag in
            var errorMessage: String?
            var errorCode = 0
            if self.images[viewTag] != nil {
                self.images[viewTag] = nil
                self.collageView.layoutSubviews()

                errorMessage = "Image removed"
                errorCode = 0
            } else {
                errorMessage = "No image to remove"
                errorCode = 1
            }
            return (errorCode, errorMessage)
            
        }
        
        switchImages = Mode.Switch { viewTags in
            var errorMessage: String?
            var errorCode = 0
            if viewTags.count == 2 {
                let firstTag = viewTags.first!
                let secondTag = viewTags.last!
                var nilCount = 0
                for image in [self.images[firstTag], self.images[secondTag]] {
                    if image == nil { nilCount++ }
                }
                if nilCount == 2 {
                    errorMessage = "No images to switch"
                    errorCode = 1
                } else {
                    if firstTag != secondTag {
                        let tempImage = self.images[firstTag]
                        
                        println("self.images = \(self.images)")
                        self.images[firstTag] = self.images[secondTag]
                        self.images[secondTag] = tempImage
                        self.collageView.layoutSubviews()
                        errorMessage = "Images switched"
                    } else {
                        errorCode = 3
                        errorMessage = nil
                    }
                }
            } else if viewTags.count == 1 {
                errorMessage = "Select second image"
                errorCode = 2
            }
            return (errorCode, errorMessage)
            
        }
    }
    
    // MARK: Background pattern methods
    
//    func initializeBackgroundPatterns()
//    {
//        backgroundPatterns = BackgroundPattern.getDefaultPatterns()
//    }
//    func patternDescription(imageNo: Int) -> String
//    {
//        let dictionary = backgroundPatternNames[imageNo] ?? ["":""]
//        
////        let imageDescription: String = Array(dictionary.values)[0]
//        // Maybe the one below doesn't copy the values array?
//        // See: http://stackoverflow.com/questions/24640990/how-do-i-get-the-key-at-a-specific-index-from-a-dictionary-in-swift
//        let imageDescription: String = Array(dictionary)[0].1
//        
//        return imageDescription
//    }

    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        adBannerView.delegate = self
        collageView.delegate = self
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        // Add share button
        let rightBarButtonItem1 = UIBarButtonItem(image: UIImage(named: "Share"), style: .Plain, target: self, action: "selectSize")
//        let rightBarButtonItem2 = self.editButtonItem()
//        self.navigationItem.rightBarButtonItems = [rightBarButtonItem2, rightBarButtonItem1]
        self.navigationItem.rightBarButtonItem = rightBarButtonItem1
        
        
//        scrollView.addSubview(imageView)
        
//        imageView.clipsToBounds = true
        mainView.clipsToBounds = true
                
        // Let's have 4 UIImage's
        for i in 0...3 {
            images.append(nil)
        }
        
        setUpMainView()

        initializeModes()
//        initializeBackgroundPatterns()

        clippedHeight = 0
        adjustSize()
        
        // Add gesture recognizer to the navigation bar to hide the bottom views
        let tap = UITapGestureRecognizer(target: self, action: "hideBottomViews")
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = true
        navigationController?.navigationBar.addGestureRecognizer(tap)
        
    }
    
    // MARK: - Banner Ad life cycle
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        adBannerView.hidden = false
        
    }
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        adBannerView.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Gestures
//    @IBAction func tap(sender: UITapGestureRecognizer) {
////        mainView.layer.shadowOpacity = l.shadowOpacity == 0.7 ? 0.0 : 0.7
//        println("tap gesture")
//        let slider = frameView.sliderMargin
//        if sender.view == slider {
//            println("sliding margin")
//        }
//    }

    
//    @IBAction func pinch(sender: UIPinchGestureRecognizer) {
//        let offset: CGFloat = sender.scale < 1 ? 5.0 : -5.0
//        let oldFrame = l.frame
//        let oldOrigin = oldFrame.origin
//        let newOrigin = CGPoint(x: oldOrigin.x + offset, y: oldOrigin.y + offset)
//        let newSize = CGSize(width: oldFrame.width + (offset * -2.0), height: oldFrame.height + (offset * -2.0))
//        let newFrame = CGRect(origin: newOrigin, size: newSize)
//        if newFrame.width >= 100.0 && newFrame.width <= 300.0 {
//            l.borderWidth -= offset
//            l.cornerRadius += (offset / 2.0)
//            l.frame = newFrame
//        }
//    }
    
    // MARK: - Bottom Views
    
    func selectFrame()
    {
        println("Frame selected")
        if !frameView.isDescendantOfView(view) {
            selectFrameView.hidden = true
            selectBackgroundView.hidden = true
//            frameView.setTranslatesAutoresizingMaskIntoConstraints(false)

            for anchorView in collageView.anchorViews {
                anchorView.hidden = false
            }
//            for wrapperView in collageView.wrapperViews {
//                singleTap = UITapGestureRecognizer(target: self, action: "selectFrame:")
//                wrapperView.addGestureRecognizer(singleTap)
//            }
            
            view.addSubview(frameView)
            println("frameView.frame = \(frameView.frame)")
            frameView.frame.size.height = 200
            
            frameView.show()
            clippedHeight = frameView.frame.size.height
            println("frameView.frame = \(frameView.frame)")

//            viewForLayer.changeHeight(height: viewForLayer.frame.height - 200)
            let pan = UIPanGestureRecognizer(target: self, action: "slideDown:")
            frameView.addGestureRecognizer(pan)
//            println("frameView.cropButton = \(frameView.cropButton)")
//            frameView.cropButton = UIButton()
            frameView.removeButton?.addTarget(self, action: "removeButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
            frameView.switchButton?.addTarget(self, action: "switchButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
            frameView.aspectFillButton?.addTarget(self, action: "aspectFillButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
            frameView.aspectFitButton?.addTarget(self, action: "aspectFitButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
            frameView.flipButton?.addTarget(self, action: "flipButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
            
            frameView.delegate = self
                        
        }
    }
    
    func selectBackground()
    {
        println("Background selected")
        println("Frame selected")
        if !backgroundView.isDescendantOfView(view) {
            selectFrameView.hidden = true
            selectBackgroundView.hidden = true
//            backgroundView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            view.addSubview(backgroundView)
            println("backgroundView.frame = \(backgroundView.frame)")

            
            backgroundView.show()
            clippedHeight = backgroundView.frame.size.height
            println("backgroundView.frame = \(backgroundView.frame)")

            //            viewForLayer.changeHeight(height: viewForLayer.frame.height - 200)
            let pan = UIPanGestureRecognizer(target: self, action: "slideDown:")
            pan.cancelsTouchesInView = false
            backgroundView.addGestureRecognizer(pan)
                        
            backgroundView.selectedColorButton.addTarget(self, action: "showColorPicker:", forControlEvents: UIControlEvents.TouchUpInside)
            
            backgroundView.delegate = self
        }
    }
    
    func slideDown(gesture: UIPanGestureRecognizer)
    {
        println("panning")
        let panView = frameView.isDescendantOfView(view) ? frameView : backgroundView
        let originY = panView.frame.origin.y
        switch gesture.state {
//        case .Began:
            
        case .Changed:
            let translation = gesture.translationInView(panView)
            let change = panView.frame.origin.y - (view.frame.height - panView.frame.height)
//            change += translation.y
            if translation.y > 0 || change > 0 {
                if abs(translation.x) < abs(translation.y) {
                    panView.frame.origin.y += translation.y
                    gesture.setTranslation(CGPointZero, inView: panView)
                }
            }
            println("translation.y = \(translation.y)")

        case .Ended:
            let change = panView.frame.origin.y - (view.frame.height - panView.frame.height)
            if change >= 50 {
                println("hide")
                let ratio = (panView.frame.height - change) / panView.frame.height
                panView.hide(duration: 0.6 * NSTimeInterval(ratio))
                clippedHeight = 0

                selectFrameView.hidden = false
                selectBackgroundView.hidden = false
                
                for anchorView in collageView.anchorViews {
                    anchorView.hidden = true
                }
                mode = .None
//                for wrapperView in collageView.wrapperViews {
//                    wrapperView.removeGestureRecognizer(singleTap)
//                }
//                viewForLayer.changeHeight(height: viewForLayer.frame.height + 200)

            } else {
                println("snap back")
                panView.snapBack()
            }

        default: break
        }
    }
    
    func hideBottomViews()
    {
        let bottomView = frameView.isDescendantOfView(view) ? frameView : backgroundView

        selectFrameView.hidden = false
        selectBackgroundView.hidden = false
        mode = .None
        
        if bottomView.isDescendantOfView(view) {
            clippedHeight = 0
            bottomView.hide()
            
            for anchorView in collageView.anchorViews {
                anchorView.hidden = true
            }
//            for wrapperView in collageView.wrapperViews {
//                wrapperView.removeGestureRecognizer(singleTap)
//            }

        }
//        else {
//            println("tapped")
//            let backgroundColor = viewForLayer.backgroundColor
//            viewForLayer.backgroundColor = UIColor(rgba: "#11223355")
//            UIView.animateWithDuration(0.3, animations: { () -> Void in
//                self.viewForLayer.backgroundColor = backgroundColor
//            })
//        }
    }
    
    // MARK: - Color Picker
    
    func showColorPicker(sender: CoolButton)
    {
        if mainView.backgroundColor != backgroundView.selectedColorButton.backgroundColor {
            borderColor = backgroundView.selectedColorButton.backgroundColor!
        } else {
            let colorPickerVC = SwiftColorPickerViewController()
            colorPickerVC.delegate = self
            colorPickerVC.modalPresentationStyle = .Popover
            let popVC = colorPickerVC.popoverPresentationController!;
            popVC.sourceRect = sender.frame
            popVC.sourceView = backgroundView.selectedColorButton
            popVC.permittedArrowDirections = .Any
            popVC.delegate = self
            
            self.presentViewController(colorPickerVC, animated: true, completion: {
                print("Reade<");
            })

        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return UIModalPresentationStyle.None
    }
    
    // MARK: Color Picker Delegate
    
    func colorSelectionChanged(selectedColor color: UIColor) {
        
        backgroundView.selectedColorButton.backgroundColor = color
        borderColor = color
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
////            l.contentMode = .ScaleAspectFit
////            l.contents = pickedImage
//            image = pickedImage
//        } else {
//            println("photo is nil")
//        }
//        
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
//    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
    // MARK: - UIScrollViewDelegate Method
    // required for zooming
//    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//        return imageView
//    }
    
    // MARK: - Navigation
    private struct Segue {
        static let PhotoGallery = "Photo Gallery"
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination: AnyObject = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let identifier = segue.identifier {
            switch identifier {
            case Segue.PhotoGallery:
                println(Segue.PhotoGallery)
                if let cvc = destination as? ContainersViewController {
                    cvc.maximumSelectableImages = compositionType.maximumImageCount
                }
            default:
                break
            }
        }
    }
    
    @IBAction func unwindFromPhotoGallery(segue: UIStoryboardSegue)
    {
        println("unwind from photo gallery")
        if assets.count > 0 {
            println("assets.count = \(assets.count)")
            println("loading image")
//            image = images[0]
            loadImage()
        }
        
    }
}













