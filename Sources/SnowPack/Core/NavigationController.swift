import UIKit

open class NavigationController: UINavigationController {
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        guard let topMostViewController = viewControllers.last else { return .default }
        return topMostViewController.preferredStatusBarStyle
    }
    
    func addDismissButton() {
        let barButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
}
