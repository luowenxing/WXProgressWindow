//
//  TestViewController.swift
//  WXProgressWindow
//
//  Created by Luo on 7/14/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

class TestViewController:UIViewController,WXProgressWindowManagerDelegate {
    
    private var timer:NSTimer!
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    
    override func viewDidLoad() {
        self.progress.progress = 0
    }
    
    func updateProgress() {
        if self.progress.progress < 1 {
            self.progress.progress += 0.01
            self.labelProgress.text = "\(Int(self.progress.progress * 100))%"
        } else {
            self.timer.invalidate()
        }
    }
    
    @IBAction func btnStartTouch(sender: AnyObject) {
        self.timer = NSTimer(timeInterval: 0.1, target: self, selector: #selector(TestViewController.updateProgress), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSDefaultRunLoopMode)
    }
    
    
    
    //MARK:ProgressWindowManager
    
    private lazy var progressManager:WXProgressWindowManager = {
        let manager = WXProgressWindowManager(rootViewController: self.navigationController!, delegate: self)
        return manager
    }()
    
    @IBAction func btnHideTouch(sender: AnyObject) {
        self.progressManager.showProgressWindow()
    }

    @IBAction func btnCancelTouch(sender: AnyObject) {
        self.progressManager.dismissProgressWindow()
    }
    
    func currentProgress() -> Float {
        return progress.progress
    }
}
