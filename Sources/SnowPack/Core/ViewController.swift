import Combine
import UIKit

/// Base class that defines common functionality of all ViewControllers
open class ViewController: UIViewController, Loading {
    public var cancellables = Set<AnyCancellable>()
    /// no need to touch this value ever, instead call `showBasicLoader(with: ...)` and `hideBasicLoader()`
    public var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    public var headerHeight: CGFloat = 88.0 {
        didSet {
            guard isViewLoaded else { return }
            let screenHeight = SnowPackUI.mainScreen?.bounds.height ?? view.bounds.height
            headerHeightConstraint?.constant = headerHeight
            contentViewHeightConstraint?.constant = screenHeight - headerHeight
        }
    }
    
    var headerHeightConstraint: NSLayoutConstraint?
    var contentViewHeightConstraint: NSLayoutConstraint?
    
    public lazy var headerView: UIView = {
        let view = UIView()
        let screenWidth = SnowPackUI.mainScreen?.bounds.width
        headerHeightConstraint = view.height(88.0)
        view.width(screenWidth ?? self.view.bounds.width)
        return view
    }()
    
    public lazy var contentView: UIView = {
        let view = UIView()
        let screenWidth = SnowPackUI.mainScreen?.bounds.width
        let screenHeight = SnowPackUI.mainScreen?.bounds.height
        contentViewHeightConstraint = view.height((screenHeight ?? self.view.bounds.height) - 88.0)
        view.width(screenWidth ?? self.view.bounds.width)
        return view
    }()
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        if SnowPackUI.shouldApplyColorSystemUniversally {
            navigationController?.navigationBar.standardAppearance = UINavigationBar.configuration.appearance.standardAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBar.configuration.appearance.scrollEdgeAppearance
            navigationController?.navigationBar.prefersLargeTitles = UINavigationBar.configuration.titleStyle == .large
            navigationController?.navigationBar.tintColor = .tint
        }
        
        if UINavigationBar.configuration.appearance == .fullyHidden {
            navigationController?.setNavigationBarHidden(true, animated: false)
            [headerView, contentView].forEach(view.addSubview(_:))
            headerView.centerXToSuperview()
            headerView.topToSuperview(usingSafeArea: false)
            contentView.centerXToSuperview()
            contentView.topToBottom(of: headerView)
        }
        
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
        
        let background = alert.view.allSubviews.first(where: { $0 is UIVisualEffectView }) as? UIVisualEffectView
        background?.backgroundColor = .surface.darkened
        background?.effect = nil
        
        (background?.allSubviews.filter({ $0 is UILabel }) as? [UILabel])?.forEach({ label in
            label.textColor = .textSurface
        })
        
        if let actionTitle = actionTitle, let action = action {
            let alertAction = UIAlertAction(title: actionTitle, style: .default) { _ in
                action()
            }
            alert.addAction(alertAction)
        }
        
        navigate(to: alert)
    }
}

