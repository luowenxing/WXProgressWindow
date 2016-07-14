//
//  ViewController.swift
//  WXProgressWindow
//
//  Created by Luo on 7/14/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.lightGrayColor()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnPresentTouch(sender: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("TestViewController")
        let nc = UINavigationController(rootViewController: vc)
        self.presentViewController(nc, animated: true, completion: nil)
        
    }
    @IBAction func btnPresentNoNavTouch(sender: AnyObject) {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("TestNoNavViewController")
        self.presentViewController(vc, animated: true, completion: nil)
    }

}

