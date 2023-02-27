import Combine
import UIKit

/// Base class that defines common functionality of all ViewControllers
open class ViewController: UIViewController, Loading {
    public var cancellables = Set<AnyCancellable>()
    /// no need to touch this value ever, instead call `showBasicLoader(with: ...)` and `hideBasicLoader()`
    public var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if SnowPackUI.shouldApplyColorSystemUniversally {
            let standardAppearance = UINavigationBarAppearance()
            standardAppearance.configureWithOpaqueBackground()
            standardAppearance.backgroundColor = .surface
            standardAppearance.shadowColor = .surface
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
    
    open func triggerSystemAlert(title: String,
                                 message: String,
                                 dismissTitle: String = "Okay",
                                 dismissAction: RemoteAction? = nil,
                                 actionTitle: String? = nil,
                                 action: RemoteAction? = nil
    ) {
        let dismiss = UIAlertAction(title: dismissTitle, style: .cancel) { action in
            dismissAction?()
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(dismiss)
        
        let background = alert.view.allSubviews.first(where: { $0 is UIVisualEffectView })
        background?.backgroundColor = .surface
        
        if let actionTitle = actionTitle, let action = action {
            let alertAction = UIAlertAction(title: actionTitle, style: .default) { _ in
                action()
            }
            alert.addAction(alertAction)
        }
        
        navigate(to: alert)
    }
}

