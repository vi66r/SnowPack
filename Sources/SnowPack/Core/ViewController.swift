import Combine
import UIKit

/// Base class that defines common functionality of all ViewControllers
open class ViewController: UIViewController, Loading {
    public var cancellables = Set<AnyCancellable>()
    /// no need to touch this value ever, instead call `showBasicLoader(with: ...)` and `hideBasicLoader()`
    public var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if SnowPack.shouldApplyColorSystemUniversally {
            let standardAppearance = UINavigationBarAppearance()
            standardAppearance.configureWithOpaqueBackground()
            standardAppearance.backgroundColor = .accent
            standardAppearance.shadowColor = .accent
            standardAppearance.titleTextAttributes = [.foregroundColor : UIColor.tint]
            navigationController?.navigationBar.standardAppearance = standardAppearance
            
            let scrollEdgeAppearance = UINavigationBarAppearance()
            scrollEdgeAppearance.configureWithTransparentBackground()
            scrollEdgeAppearance.titleTextAttributes = [.foregroundColor : UIColor.tint]
            navigationController?.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
            
            navigationController?.navigationBar.tintColor = .tint
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        // Do any additional setup after loading the view.
    }
    
    public func navigate(to viewController: UIViewController) {
        switch viewController {
        case is UIActivityViewController, is UIAlertController:
            present(viewController, animated: true)
        default:
            if let navigationController = navigationController {
                navigationController.pushViewController(viewController, animated: true)
            } else {
                present(viewController, animated: true)
            }
        }
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIColor.isDarkModeAllowed ? .default : .darkContent
    }
}

