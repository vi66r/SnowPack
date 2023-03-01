import Combine
import UIKit

/// Base class that defines common functionality of all ViewControllers
open class ViewController: UIViewController, Loading {
    public var cancellables = Set<AnyCancellable>()
    /// no need to touch this value ever, instead call `showBasicLoader(with: ...)` and `hideBasicLoader()`
    public var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    private(set) var navigationBarHidden: Bool = false
    
    public var headerHeight: CGFloat = 44.0 {
        didSet {
            guard isViewLoaded else { return }
            let screenHeight = SnowPackUI.mainScreen?.bounds.height ?? view.bounds.height
            headerHeightConstraint?.constant = headerHeight
            contentViewHeightConstraint?.constant = screenHeight - headerHeight
            headerBackgroundHeightConstraint?.constant = headerHeight + (SnowPackUI.topSafeAreaMetric ?? 0.0)
        }
    }
    
    var headerHeightConstraint: NSLayoutConstraint?
    var headerBackgroundHeightConstraint: NSLayoutConstraint?
    var contentViewHeightConstraint: NSLayoutConstraint?
    
    lazy var headerBackground: UIView = {
        let view = UIView()
        let screenWidth = SnowPackUI.mainScreen?.bounds.width
        headerBackgroundHeightConstraint = view.height(headerHeight + (SnowPackUI.topSafeAreaMetric ?? 0.0))
        view.width(screenWidth ?? self.view.bounds.width)
        return view
    }()
    
    public lazy var headerView: UIView = {
        let view = UIView()
        let screenWidth = SnowPackUI.mainScreen?.bounds.width
        headerHeightConstraint = view.height(headerHeight)
        view.width(screenWidth ?? self.view.bounds.width)
        return view
    }()
    
    public lazy var contentView: UIView = {
        let view = UIView()
        let screenWidth = SnowPackUI.mainScreen?.bounds.width
        let screenHeight = SnowPackUI.mainScreen?.bounds.height
        contentViewHeightConstraint = view.height((screenHeight ?? self.view.bounds.height) - headerHeight)
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
            navigationBarHidden = true
            [contentView, headerBackground, headerView].forEach(view.addSubview(_:))
            headerBackground.centerXToSuperview()
            headerBackground.topToSuperview(usingSafeArea: false)
            headerView.centerXToSuperview()
            headerView.topToSuperview(usingSafeArea: true)
            contentView.centerXToSuperview()
            contentView.topToBottom(of: headerView)
        }
        
        // Do any additional setup after loading the view.
    }
    
    open func showNavigationBar(animated: Bool = true) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationBarHidden = false
        headerView.removeAllConstraints()
        headerView.removeFromSuperview()
        contentView.removeAllConstraints()
        contentView.removeFromSuperview()
    }
    
    open func hideNavigationBar(animated: Bool = true) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationBarHidden = true
        [headerView, contentView].forEach(view.addSubview(_:))
        headerView.centerXToSuperview()
        headerView.topToSuperview(usingSafeArea: true)
        contentView.centerXToSuperview()
        contentView.topToBottom(of: headerView)
    }
    
    open func addSubview(_ view: UIView) {
        if navigationBarHidden {
            contentView.addSubview(view)
        } else {
            self.view.addSubview(view)
        }
    }
    
    open func navigate(to viewController: UIViewController) {
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

