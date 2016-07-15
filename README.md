# WXProgressWindow
A progress window hide presented view controller of background work with progress(e.g. download),and return to view controller by tap.The progress window also can be dragged to place in somewhere else.

# Demo
![progressWindow.png](https://github.com/luowenxing/WXProgressWindow/blob/master/WXProgressWindow/Demo/progressWindow.png)
![Demo.gif](https://github.com/luowenxing/WXProgressWindow/blob/master/WXProgressWindow/Demo/demo.gif)

# Usage
* Implement delegate method.
```
@objc protocol ProgressWindowManagerDelegate:NSObjectProtocol {
    func currentProgress() -> Float
    optional func currentProgressText() -> String?
}
```
* Lazy Init `ProgressWindowManager` in `viewController` to present.You should choose a `init` function depending on whether you need a `navigationController` (explictly `navigationBar`).
  * `init(rootViewController:UIViewController,delegate:ProgressWindowManagerDelegate)` has no `navigationBar`
  * `init(navigationController:UINavigationController,delegate:ProgressWindowManagerDelegate)` has `navigationBar`
```
private lazy var progressManager:ProgressWindowManager = {
  let nc = UINavigationController(rootViewController:self)
  let manager = ProgressWindowManager(navigationController: nc, delegate: self)
  //manager.arcColor = UIColor.redColor()
  //manager.cycleColor = UIColor.grayColor()
  //manager.fontSize = 13
  //manager.progressRect = CGRect(x: UIScreen.mainScreen().compatibleBounds.width - 50 - 100, y: 20, width: 50, height: 50)
  return manager
}()
```
* Add following code at the function of hiding view controller which will show the progress window.
```
@IBAction func btnHideTouch(sender: AnyObject) {
    self.dismissViewControllerAnimated(false, completion: nil)
    // right after dismissVC function.The sequence should be followed
    self.progressManager.showProgressView()
}
```
* Add `dismissProgressView` **right after** `dismissViewControllerAnimated` every time you want to exit the view controller
```
@IBAction func btnCancelTouch(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
    // right after dismissVC function.The sequence should be followed
    self.progressManager.dismissProgressView()
}
```

# TODO
* Handle the warning message in debug console.
```
Unbalanced calls to begin/end appearance transitions for xxx.
```
* Make it easier to use.


