//
//  ProgressWindow.swift
//  WXProgressWindow
//
//  Created by Luo on 7/14/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

enum ProgressWindowStatus {
    case InitialView
    case RootView
    case ProgressView
    
}

class ProgressWindow:UIWindow {
    weak var manager:ProgressWindowManager!
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        //显示悬浮窗时，只响应悬浮窗区域的手势事件
        if let m = self.manager where m.status == .ProgressView {
            if let _ = hitView as? ProgressView {
                return hitView
            } else {
                return nil
            }
        }
        return hitView
    }
}

@objc protocol ProgressWindowManagerDelegate:NSObjectProtocol {
    func currentProgress() -> Float
    optional func currentProgressText() -> String?
}

class ProgressWindowManager:NSObject,UIViewControllerTransitioningDelegate,ProgressViewControllerDelegate {
    
    
    var status:ProgressWindowStatus = .InitialView
    
    private var rootViewController:UIViewController!
    private weak var delegate:ProgressWindowManagerDelegate?
    private lazy var progressVC:ProgressViewController = ProgressViewController(delegate: self)
    private lazy var window:ProgressWindow = {
        let window = ProgressWindow(frame: UIScreen.mainScreen().bounds)
        window.backgroundColor = UIColor.clearColor()
        window.layer.masksToBounds = true
        window.manager = self
        return window
    }()
    
    init(rootViewController:UIViewController,delegate:ProgressWindowManagerDelegate) {
        super.init()
        let nc = UINavigationController(rootViewController: rootViewController)
        nc.navigationBarHidden = true
        self.rootViewController = nc
        self.delegate = delegate
        rootViewController.transitioningDelegate = self
    }
    
    init(navigationController:UINavigationController,delegate:ProgressWindowManagerDelegate) {
        super.init()
        self.rootViewController = navigationController
        self.delegate = delegate
        navigationController.transitioningDelegate = self
    }
    
    
    func showProgressView() {
        if self.status == .InitialView {
            window.hidden = false
            window.rootViewController = rootViewController
            self.status = .RootView
        }
        if self.status == .RootView{
            self.status = .ProgressView
            self.progressVC.transitioningDelegate = self
            self.rootViewController.presentViewController(self.progressVC, animated: true) {
                if self.progressVC.view.window == nil {
                    // iOS8以上的bug,present之后又present一个view，这个view不会被加到window上，需要手动添加
                    self.window.addSubview(self.progressVC.view)
                    self.progressVC.startCADisplayLink()
                }
            }
        }
    }
    
    func getProgress() -> Float {
        if let delegate = self.delegate {
            return delegate.currentProgress()
        }
        return 0
    }
    
    func getProgressText() -> String? {
        if let delegate = self.delegate {
            return delegate.currentProgressText?()
        }
        return nil
    }
    
    func showRootView() {
        window.windowLevel = UIWindowLevelNormal
        progressVC.stopCADisplayLink()
        self.status = .RootView
        progressVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissProgressView() {
        if self.status == .RootView {
            UIView.animateWithDuration(0.35, delay: 0, options: .CurveEaseInOut , animations: {
                if NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0 {
                    if self.rootViewController.interfaceOrientation.isPortrait {
                        self.window.frame.origin.y = UIScreen.mainScreen().bounds.height
                    } else {
                        self.window.frame.origin.x = -UIScreen.mainScreen().bounds.width
                    }
                } else {
                    self.window.frame.origin.y = UIScreen.mainScreen().bounds.height
                }
            }) {
                _ in
                self.window.hidden = true
                self.window.rootViewController = nil
            }
        }
        
        self.rootViewController = nil
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ProgressCircleTransition(type: .Dismiss)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ProgressCircleTransition(type: .Present)
    }
    
}
