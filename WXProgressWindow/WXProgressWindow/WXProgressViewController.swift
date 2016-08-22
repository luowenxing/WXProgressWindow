//
//  ProgressWindowController.swift
//  CMBMobile
//
//  Created by Luo on 7/11/16.
//  Copyright © 2016 Yst－WHB. All rights reserved.
//

import Foundation
import UIKit

class WXProgressView:UIView {
    
}

protocol WXProgressViewControllerDelegate:NSObjectProtocol {
    func getProgress() -> Float
    func getProgressText() -> String?
    func showRootView()
}

class WXProgressViewController:UIViewController {
    
    weak var delegate: WXProgressViewControllerDelegate?
    init(delegate:WXProgressViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var progressRect:CGRect = CGRect(x: UIScreen.mainScreen().compatibleBounds.width - 50 - 100, y: 20, width: 50, height: 50)
    var cycleColor:UIColor = UIColor.hexColor("#AFD8FB")
    var arcColor:UIColor = UIColor.hexColor("#1F7FEC")
    lazy var fontSize:CGFloat = self.progressRect.size.width / 8.0 * 3.0
    
    private lazy var progressView:WXProgressView = WXProgressView()
    private lazy var progressLabel = UILabel()
    private lazy var circleLayer:CAShapeLayer! = self.getCycleLayer(self.cycleColor, startAngle: 0, endAngle: CGFloat(M_PI * 2))
    private lazy var arcLayer:CAShapeLayer! = self.getCycleLayer(self.arcColor, startAngle: -CGFloat(M_PI_2), endAngle: -CGFloat(M_PI_2))
    private var displayLink:CADisplayLink!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.circleLayer.frame = self.progressView.bounds
    }
    
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if self.interfaceOrientation.isPortrait != toInterfaceOrientation.isPortrait {
            let size = self.view.frame.size
            self.resetProgressViewFrameOnRotate(size.height, toHeight: size.width)
        }
    }
    
    // 处理iOS7旋转bug
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        let size = self.view.frame.size
        self.resetProgressViewFrameOnRotate(size.width, toHeight: size.height)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        
        self.progressView.frame = self.progressRect
        self.progressView.backgroundColor = UIColor.whiteColor()
        self.progressView.layer.cornerRadius = self.progressRect.width / 2.0
        self.view.addSubview(progressView)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(WXProgressViewController.onTap))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(WXProgressViewController.onPan))
        self.progressView.addGestureRecognizer(tapRecognizer)
        self.progressView.addGestureRecognizer(panRecognizer)
        
        self.progressLabel.translatesAutoresizingMaskIntoConstraints = false
        self.progressLabel.text = "0"
        self.progressLabel.textColor = arcColor
        self.progressLabel.font = UIFont.boldSystemFontOfSize(fontSize)
        self.progressView.addSubview(self.progressLabel)
        let constraintX = NSLayoutConstraint(item: progressLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self.progressView, attribute: .CenterX, multiplier: 1, constant: 0)
        let constraintY = NSLayoutConstraint(item: progressLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self.progressView, attribute: .CenterY, multiplier: 1, constant: 0)
        self.progressView.addConstraints([constraintX,constraintY])
        
        self.progressView.layer.addSublayer(self.circleLayer)
        self.progressView.layer.addSublayer(self.arcLayer)
        
    }
    
    func startCADisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(WXProgressViewController.updateProgressView))
        self.displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func stopCADisplayLink() {
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
    
    func updateProgressView() {
        if let delegate = self.delegate {
            let progress = CGFloat(delegate.getProgress())
            self.arcLayer.path = self.getLayerPath(-CGFloat(M_PI_2), endAngle: CGFloat(M_PI) * 2 * progress - CGFloat(M_PI_2) )
            self.arcLayer.setNeedsDisplay()
            if let text = delegate.getProgressText() {
                self.progressLabel.text = text
            } else {
                self.progressLabel.text = String(Int(progress * 100))
            }
        }
    }
    
    func onTap() {
        self.delegate?.showRootView()
    }
    
    func onPan(sender:UIPanGestureRecognizer) {
        let point = sender.locationInView(self.view)
        // 保证悬浮框在边框范围内
        let prevCenter = self.progressView.center
        var frame = UIScreen.mainScreen().compatibleBounds
        frame.origin.y = 20
        frame.size.height -= 20
        self.progressView.center = point
        if !frame.contains(self.progressView.frame) {
            let unionFrame = frame.union(self.progressView.frame)
            if unionFrame.width > frame.width {
                self.progressView.center.x = prevCenter.x
            }
            if unionFrame.height > frame.height {
                self.progressView.center.y = prevCenter.y
            }
        }
        self.progressRect = self.progressView.frame
    }
    
    private func getLayerPath(startAngle:CGFloat,endAngle:CGFloat) -> CGPath {
        let width = self.progressRect.size.width
        let lineWidth:CGFloat = width / 8.0
        let radius = (width - lineWidth ) / 2.0
        let center = CGPoint(x: width / 2.0, y: width / 2.0)
        return UIBezierPath(arcCenter:center , radius: radius, startAngle: startAngle, endAngle:endAngle , clockwise:true).CGPath
    }
    
    private func getCycleLayer(color:UIColor,startAngle:CGFloat,endAngle:CGFloat) -> CAShapeLayer {
        let width = self.progressRect.size.width
        let lineWidth:CGFloat = width / 8.0
        let layer = CAShapeLayer()
        layer.strokeColor = color.CGColor
        layer.lineCap = "round"
        layer.lineWidth = lineWidth
        layer.path = self.getLayerPath(startAngle, endAngle: endAngle)
        layer.fillColor = UIColor.clearColor().CGColor
        return layer
    }
    
    // 处理旋转
    private func resetProgressViewFrameOnRotate(toWidth:CGFloat,toHeight:CGFloat) {
        let origin = self.progressView.frame.origin
        let size = self.progressView.frame.size
        if origin.x + size.width > toWidth {
            self.progressView.frame.origin.x = toWidth - size.width
        }
        if origin.y + size.height > toHeight {
            self.progressView.frame.origin.y = toHeight - size.height
        }
        self.progressRect = self.progressView.frame
    }
}





