//
//  GoodCropNavigationController.swift
//  Good Crop
//
//  Created by Haluk Isik on 7/25/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit

class GoodCropNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.titleTextAttributes = [ NSFontAttributeName: goodCropFont,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        navigationBarAppearance.barTintColor = UIColor.whiteColor()
        navigationBarAppearance.tintColor = UIColor.whiteColor()
        navigationBarAppearance.setBackgroundImage(UIImage(named: "navigationBackground4"), forBarMetrics: .Default)
//        navigationBarAppearance.backgroundColor = UIColor(rgba: "#666")
        
        UIApplication.sharedApplication().statusBarHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
