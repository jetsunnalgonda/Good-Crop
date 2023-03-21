//
//  ViewController.swift
//  Containers
//
//  Created by Haluk Isik on 7/29/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit

/// Use this delegate to drop images and catch them in BottomViewController
protocol BottomViewControllerDelegate: class {
    var bottomViewController: BottomViewController? { get set }
}

@available(iOS 8.0, *)
class ContainersViewController: UIViewController
{
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Properties
    weak var delegate: BottomViewControllerDelegate?
    var albumsTableViewController: AlbumsTableViewController!
    var topViewController: TopViewController!
    var bottomViewController: BottomViewController!
    
    var maximumSelectableImages = 0

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = albumsTableViewController
        delegate?.bottomViewController = bottomViewController
        
    }
    

    // MARK: - Navigation
    private struct Segue {
        static let Top = "Top"
        static let Bottom = "Bottom"
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        var destination: AnyObject = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
        print("destination = \(destination)")
        if let identifier = segue.identifier {
            switch identifier {
            case Segue.Top:
                print("Top")
                if let tvc = destination as? AlbumsTableViewController {
                    albumsTableViewController = tvc
                }
            case Segue.Bottom:
                print("Bottom")
                if let bvc = destination as? BottomViewController {
                    bottomViewController = bvc
                    bvc.maximumSelectableImages = maximumSelectableImages
                }
            default: break
            }
        }
        
    }
    
    // MARK: - Status Bar

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

