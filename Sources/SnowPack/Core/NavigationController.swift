import UIKit

open class NavigationController: UINavigationController {
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        guard let topMostViewController = viewControllers.last else { return .default }
        return topMostViewController.preferredStatusBarStyle
    }
}
