//
//  ProgressWindowTransition.swift
//  WXProgressWindow
//
//  Created by Luo on 7/14/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit


enum ProgressCircleTransitionType {
    case Present
    case Dismiss
}

class ProgressCircleTransition:NSObject,UIViewControllerAnimatedTransitioning {
    
    var type:ProgressCircleTransitionType
    
    init(type:ProgressCircleTransitionType) {
        self.type = type
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if self.type == .Present {
            self.animateTransitionPresent(transitionContext)
        } else {
            self.animateTransitionDismiss(transitionContext)
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.35
    }
    
    func animationEnded(transitionCompleted: Bool) {
        
    }
    
    private func animateTransitionPresent(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? ProgressViewController else {
            return
        }
        if let containerView = transitionContext.containerView() {
            containerView.addSubview(fromVC.view)
            let x = max(toVC.progressRect.origin.x,containerView.frame.size.width - toVC.progressRect.origin.x)
            let y = max(toVC.progressRect.origin.y,containerView.frame.size.height - toVC.progressRect.origin.y)
            let radius = sqrt(x*x + y*y)
            let startCycle = UIBezierPath(arcCenter: containerView.center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise:true)
            let endCycle = UIBezierPath(ovalInRect: toVC.progressRect)
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = startCycle.CGPath
            fromVC.view.layer.mask = maskLayer
            
            let maskAnimation = CABasicAnimation(keyPath: "path")
            maskAnimation.delegate = self
            maskAnimation.fromValue = startCycle.CGPath
            maskAnimation.toValue = endCycle.CGPath
            maskAnimation.duration = self.transitionDuration(transitionContext)
            maskAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            maskAnimation.setValue(transitionContext, forKey: "transitionContext")
            maskAnimation.setValue(fromVC.view, forKey: "maskedView")
            maskAnimation.fillMode = kCAFillModeForwards
            maskAnimation.removedOnCompletion = false
            maskLayer.addAnimation(maskAnimation, forKey: "path")
            
        }
    }
    
    private func animateTransitionDismiss(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? ProgressViewController,toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)  else {
            return
        }
        if let containerView = transitionContext.containerView() {
            fromVC.view.removeFromSuperview()
            containerView.addSubview(toVC.view)
            let x = max(fromVC.progressRect.origin.x,containerView.frame.size.width - fromVC.progressRect.origin.x)
            let y = max(fromVC.progressRect.origin.y,containerView.frame.size.height - fromVC.progressRect.origin.y)
            let radius = sqrt(x*x + y*y)
            let endCycle = UIBezierPath(arcCenter: containerView.center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise:true)
            let startCycle = UIBezierPath(ovalInRect: fromVC.progressRect)
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = startCycle.CGPath
            toVC.view.layer.mask = maskLayer
            
            let maskAnimation = CABasicAnimation(keyPath: "path")
            maskAnimation.delegate = self
            maskAnimation.fromValue = startCycle.CGPath
            maskAnimation.toValue = endCycle.CGPath
            maskAnimation.duration = self.transitionDuration(transitionContext)
            maskAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            maskAnimation.setValue(transitionContext, forKey: "transitionContext")
            maskAnimation.setValue(toVC.view, forKey: "maskedView")
            maskAnimation.fillMode = kCAFillModeForwards
            maskAnimation.removedOnCompletion = false
            maskLayer.addAnimation(maskAnimation, forKey: "path")
            
        }
        
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let context = anim.valueForKey("transitionContext") as? UIViewControllerContextTransitioning,maskedView = anim.valueForKey("maskedView") as? UIView {
            context.completeTransition(true)
            maskedView.layer.mask = nil
        }
    }
}

