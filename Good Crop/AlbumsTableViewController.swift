//
//  AlbumsTableViewController.swift
//  Containers
//
//  Created by Haluk Isik on 7/30/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit
import Photos

///// With this delegate, BottomViewController can send selected images to AlbumsTableViewController
///// and dismiss the controller.
///// AlbumsTableViewController will pass these images to parent view controller in the segue
//protocol AlbumsTableViewControllerDelegate: class {
//    var albumsTableViewController: AlbumsTableViewController? { get set }
//}

/// Show the photos in album folders with album pictures
@available(iOS 8.0, *)
class AlbumsTableViewController: UITableViewController, BottomViewControllerDelegate
{
//    weak var delegate: AlbumsTableViewControllerDelegate?
    
    private var imageManager = PHCachingImageManager()
    var imageViewContentMode = UIViewContentMode.ScaleAspectFill
    private var _bottomViewController: BottomViewController?
    var bottomViewController: BottomViewController? {
        get {
            return _bottomViewController
        }
        set {
            _bottomViewController = newValue
        }
    }
    
//    private var _cellImages: [UIImage?] = []
//    /// Images received from BottomViewController
//    var cellImages: [UIImage?] {
//        get {
//            return _cellImages
//        }
//        set {
//            _cellImages = newValue
////            dismiss()
//        }
//    }
    
    var albumTitles = [String]()
    var albumsCount = [Int]()
    var smartAlbums = [PHFetchResult]()
//    var assetsFetchResults: PHFetchResult!
//    var assetCollection: PHAssetCollection!
    var assetCollections = [PHAssetCollection]()
    var fetchResults: [PHFetchResult!] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        delegate = bottomViewController
//        delegate?.albumsTableViewController = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Done, target: self, action: "dismiss")

        print("(AlbumsTableViewController) bottomViewController = \(_bottomViewController)")
        print("bottomViewController!.maximumSelectableImages = \(bottomViewController!.maximumSelectableImages)")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
//        findAlbums()
        
        dispatch_async(dispatch_get_main_queue()) {
            let album1 = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: nil)
            let album2 = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: nil)
            
            self.smartAlbums = [album1, album2] // , smartAlbumGeneric, albumRegular, albumImported]
            
            for (_, album) in self.smartAlbums.enumerate() {
                //            assets.append([])
                //            fetchResults.append([])
                
                for i in 0..<album.count {
                    
                    let collection = album[i] as! PHAssetCollection
                    let localizedTitle = collection.localizedTitle!
                    self.albumTitles.append(localizedTitle)
                    
                    let options = PHFetchOptions()
                    options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
                    let assetsFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
                    
                    self.fetchResults.append(assetsFetchResult)
                    self.albumsCount.append(assetsFetchResult.count)
                    self.assetCollections.append(collection)
                }
            }
        }


    
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor(rgba: "#B3B3B3")


        tableView.reloadData()

    }
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
        tableView.setNeedsLayout()

    }
//    func findAlbums()
//    {
//        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: nil)
//        
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
//        var numberOfRows = 0
//        for album in smartAlbums {
//            numberOfRows += album.count
//        }
//        return numberOfRows
        return assetCollections.count
    }

    private struct Album {
        static let Name = "album name"
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(Album.Name, forIndexPath: indexPath) as! AlbumTableViewCell
        
//        cell.textLabel?.text = assetCollections[indexPath.row].localizedTitle // albumTitles[indexPath.row]
//        cell.detailTextLabel?.text = "\(albumsCount[indexPath.row])"
        cell.albumNameLabel?.text = assetCollections[indexPath.row].localizedTitle
        cell.albumImageCountLabel?.text = "\(albumsCount[indexPath.row])"
        cell.albumImageView.clipsToBounds = true
        cell.albumImageView.contentMode = imageViewContentMode

        
        if let asset = fetchResults[indexPath.row].lastObject as? PHAsset {
        
            imageManager.requestImageForAsset(asset, targetSize: cell.albumImageView.frame.size, contentMode: PHImageContentMode.AspectFill, options: nil) { result, info in
                    cell.albumImageView.image = result
            }
        }
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

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
//            case Segue.Top:
//                println("(album) top")
//
//                if let tvc = destination as? TopViewController {
//                    tvc.bottomViewController = bottomViewController
//
//                }
//            case Segue.Bottom:
//                println("(album) bottom")
//                if let bvc = destination as? BottomViewController {
//                    bottomViewController = bvc
//                }
            case Segue.Album:
                print("(album) album")
                let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!

                if let tvc = destination as? TopViewController {
                    tvc.bottomViewController = bottomViewController
                    tvc.title = assetCollections[indexPath.row].localizedTitle
                    tvc.fetchResult = fetchResults[indexPath.row]
//                    println("fetchResults[indexPath.row].count = \(fetchResults[indexPath.row].count)")
                }
            case Segue.Unwind:
                print("(album) unwinding")
//                if let vc = destination as? ViewController {
//                    vc.images = cellImages
//                }
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
