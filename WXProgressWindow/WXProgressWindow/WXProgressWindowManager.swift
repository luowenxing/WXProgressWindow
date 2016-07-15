//
//  ProgressWindow.swift
//  WXProgressWindow
//
//  Created by Luo on 7/14/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

enum WXProgressWindowStatus {
    case InitialView
    case RootView
    case ProgressView
    
}

class WXProgressWindow:UIWindow {
    weak var manager:WXProgressWindowManager!
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        //显示悬浮窗时，只响应悬浮窗区域的手势事件
        if let m = self.manager where m.status == .ProgressView {
            if let _ = hitView as? WXProgressView {
                return hitView
            } else {
                return nil
            }
        }
        return hitView
    }
}

@objc protocol WXProgressWindowManagerDelegate:NSObjectProtocol {
    func currentProgress() -> Float
    optional func currentProgressText() -> String?
}

class WXProgressWindowManager:NSObject,UIViewControllerTransitioningDelegate,WXProgressViewControllerDelegate {
    
    deinit {
        NSLog("deinit ProgressWindowManager")
    }
    
    var progressRect:CGRect {
        get {
            return self.progressVC.progressRect
        }
        set {
            self.progressVC.progressRect = newValue
        }
    }
    var cycleColor:UIColor {
        get {
            return self.progressVC.cycleColor
        }
        set {
            self.progressVC.cycleColor = newValue
        }
    }
    var arcColor:UIColor  {
        get {
            return self.progressVC.arcColor
        }
        set {
            self.progressVC.arcColor = newValue
        }
    }
    var fontSize:CGFloat  {
        get {
            return self.progressVC.fontSize
        }
        set {
            self.progressVC.fontSize = newValue
        }
    }
    
    var status:WXProgressWindowStatus = .InitialView
    private weak var rootViewController:UIViewController!
    private weak var delegate:WXProgressWindowManagerDelegate?
    private lazy var progressVC:WXProgressViewController = WXProgressViewController(delegate: self)
    private lazy var snapView:UIView = self.rootViewController.view.snapshotViewAfterScreenUpdates(false)
    private lazy var window:WXProgressWindow = {
        let window = WXProgressWindow(frame: UIScreen.mainScreen().bounds)
        window.backgroundColor = UIColor.clearColor()
        window.layer.masksToBounds = true
        window.manager = self
        return window
    }()
    
    init(rootViewController:UIViewController,delegate:WXProgressWindowManagerDelegate) {
        super.init()
        self.rootViewController = rootViewController
        self.delegate = delegate
    }
    
    func showProgressWindow() {
        if self.status == .InitialView {
            if self.window.hidden {
                self.window.addSubview(self.snapView)
                self.window.hidden = false
                // 在window上增加一个snapView防止闪屏
                self.performSelector(#selector(WXProgressWindowManager.showProgressWindow), withObject: nil, afterDelay: 0.05)
                return
            }
            self.status = .RootView
            self.rootViewController.dismissViewControllerAnimated(false) {
                self.window.rootViewController = self.rootViewController
                // 防止闪屏
                self.performSelector(#selector(WXProgressWindowManager.showProgressWindow), withObject: nil, afterDelay: 0)
            }
        }
        else if self.status == .RootView{
            self.status = .ProgressView
            self.progressVC.transitioningDelegate = self
            //view已经增加到window上，把snapView remove
            self.snapView.removeFromSuperview()
            self.rootViewController.transitioningDelegate = self
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
    
    func dismissProgressWindow() {
        if self.status == .InitialView {
            self.rootViewController.dismissViewControllerAnimated(true, completion: nil)
        }
        else if self.status == .RootView {
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
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return WXProgressCircleTransition(type: .Dismiss)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return WXProgressCircleTransition(type: .Present)
    }
    
}
