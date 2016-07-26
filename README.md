# WXProgressWindow
A progress window hide presented view controller of background work with progress(e.g. download),and return to view controller by tap.The progress window also can be dragged to place in somewhere else.

# Demo
![progressWindow.png](https://github.com/luowenxing/WXProgressWindow/blob/master/WXProgressWindow/Demo/progressWindow.png)

![Demo.gif](https://github.com/luowenxing/WXProgressWindow/blob/master/WXProgressWindow/Demo/demo.gif)

# Installation
There is no other dependecy in it.Just add WXProgressWindow folder to your project.

# Usage
* Implement delegate method.
```
@objc protocol WXProgressWindowManagerDelegate:NSObjectProtocol {
    func currentProgress() -> Float
    optional func currentProgressText() -> String?
}
```
* Init `WXProgressWindowManager` in view controller to present.
```
private lazy var progressManager:WXProgressWindowManager = {
  //Pass self.navigationController! to rootViewController if your view controller is wrapped in a navigationController.
  let manager = WXProgressWindowManager(rootViewController: self, delegate: self)
  //manager.arcColor = UIColor.redColor()
  //manager.cycleColor = UIColor.grayColor()
  //manager.fontSize = 13
  //manager.progressRect = CGRect(x: UIScreen.mainScreen().compatibleBounds.width - 50 - 100, y: 20, width: 50, height: 50)
  return manager
}()
```
* Call instance function `showProgressWindow()` to hide your view controller and show the progress window.
* Call instance function `dismissProgressWindow()` to dismiss your view controller and destory progress window.

# Detail
http://www.jianshu.com/p/34701b334ed7

