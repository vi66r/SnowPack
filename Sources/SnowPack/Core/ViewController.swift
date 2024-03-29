import MessageUI
import Combine
import Shuttle
import StoreKit
import UIKit

/// Base class that defines common functionality of all ViewControllers
open class ViewController: UIViewController, Loading, ToastPresenting {
    public var cancellables = Set<AnyCancellable>()
    /// no need to touch this value ever, instead call `showBasicLoader(with: ...)` and `hideBasicLoader()`
    @EventStream(value: false) public var isLoading
    
    private(set) var navigationBarHidden: Bool = false
    var popRecognizer: InteractivePopRecognizer?

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
    public var contentViewBottomConstraint: NSLayoutConstraint?
    
    var scrollViewObserver: NSKeyValueObservation?
    
    lazy var headerBackground: UIView = {
        let view = UIView()
        let screenWidth = SnowPackUI.mainScreen?.bounds.width
        view.width(screenWidth ?? self.view.bounds.width)
        view.backgroundColor = .background
        return view
    }()
    
    public lazy var headerView: UIView = {
        let view = UIView()
        let screenWidth = SnowPackUI.mainScreen?.bounds.width
        headerHeightConstraint = view.height(headerHeight)
        view.width(screenWidth ?? self.view.bounds.width)
        view.backgroundColor = .background
        return view
    }()
    
    public lazy var contentView: UIView = {
        let view = UIView()
        let screenWidth = SnowPackUI.mainScreen?.bounds.width
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
            headerBackground.bottom(to: headerView)
            headerView.centerXToSuperview()
            headerView.topToSuperview(usingSafeArea: true)
            contentView.centerXToSuperview()
            contentView.topToBottom(of: headerView)
            contentViewBottomConstraint = contentView.bottomToSuperview()
            setInteractiveRecognizer()
        }
        
        // Do any additional setup after loading the view.
    }
    
    open func showNavigationBar(animated: Bool = true) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationBarHidden = false
        headerView.removeAllConstraints()
        headerView.removeFromSuperview()
        headerBackground.removeAllConstraints()
        headerBackground.removeFromSuperview()
        contentView.removeAllConstraints()
        contentView.removeFromSuperview()
    }
    
    open func hideNavigationBar(animated: Bool = true) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationBarHidden = true
        [contentView, headerBackground, headerView].forEach(view.addSubview(_:))
        headerBackground.centerXToSuperview()
        headerBackground.topToSuperview(usingSafeArea: false)
        headerBackground.bottom(to: headerView)
        headerView.centerXToSuperview()
        headerView.topToSuperview(usingSafeArea: true)
        contentView.centerXToSuperview()
        contentView.topToBottom(of: headerView)
        contentView.bottomToSuperview()
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
//        case is SimpleWebViewController:
//            let navigationController = NavigationController(rootViewController: viewController)
//            navigationController.modalPresentationStyle = .overFullScreen
//            navigationController.addDismissButton()
//            present(navigationController, animated: true)
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
                                 dismissAction: Action? = nil,
                                 actionTitle: String? = nil,
                                 action: Action? = nil
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
    
    public func enableCustomHeaderReaction(to scrollView: UIScrollView) {
        scrollViewObserver = scrollView
            .observe(\UITableView.contentOffset, options: .new) { [weak self] scrollView, observation in
                if observation.newValue?.y ?? 0.0 > 0.0 {
                    self?.headerBackground.applyDropShadow(opacity: 0.1, radius: 10.0)
                } else {
                    self?.headerBackground.removeShadow()
                }
            }
    }
    
    public func setHeaderColor(_ color: UIColor) {
        headerView.applyBackgroundColor(color)
        headerBackground.applyBackgroundColor(color)
    }
    
    deinit {
        scrollViewObserver?.invalidate()
    }
    
    public func presentCustomAlert(_ alertView: UIView & CustomAlerting) {
        let alert = CustomAlertController(customView: alertView, presentationStyle: .slideInFromBottom)
        alert.modalPresentationStyle = .overFullScreen
        present(alert, animated: false)
    }
    
    public func shareViaMessages(_ message: TextableMessage) {
        let messageViewController = MFMessageComposeViewController()
        messageViewController.messageComposeDelegate = self
        
        messageViewController.recipients = message.recepients
        messageViewController.body = message.message
        
        if MFMessageComposeViewController.canSendText() {
            self.present(messageViewController, animated: true, completion: nil)
        } else {
            print("Can't send messages.")
        }
    }
    
    open func sentMessageWithSuccess(_ success: Bool) {
        print("you're supposed to override this, but if you don't need to, that's okay too")
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    public func subscribe<T>(to subject: PassthroughSubject<T, Never>, performing: @escaping ((T) -> Void)) {
        subject.receive(on: DispatchQueue.main).sink(receiveValue: performing).store(in: &cancellables)
    }
    
    public func subscribeInBackground<T>(to subject: PassthroughSubject<T, Never>, performing: @escaping ((T) -> Void)) {
        subject.receive(on: DispatchQueue.main).sink(receiveValue: performing).store(in: &cancellables)
    }
    
    public func subscribe<T>(to stream: CurrentValueSubject<T, Never>, performing: @escaping ((T) -> Void)) {
        stream.receive(on: DispatchQueue.main).sink(receiveValue: performing).store(in: &cancellables)
    }
    
    public func subscribeInBackground<T>(to stream: CurrentValueSubject<T, Never>, performing: @escaping ((T) -> Void)) {
        stream.receive(on: DispatchQueue.main).sink(receiveValue: performing).store(in: &cancellables)
    }
    
    public func goBack() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    public func requestAppStoreReview() {
        if let windowScene = view.window?.windowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    open func keyboardDidShow(_ height: CGFloat) {
        assertionFailure("If you're observing you're keyboard, you should override this method to use the observation")
    }
    
    open func keyboardDidHide() {
        assertionFailure("If you're observing you're keyboard, you should override this method to use the observation")
    }
    
    public func observeKeyboard() {
        
        let showPublisher: NotificationCenter.Publisher = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
        
        showPublisher.receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let keyboardFrame: NSValue = output.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
                else { return }
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                self?.keyboardDidShow(keyboardHeight)
            }.store(in: &cancellables)
        
        
        let hidePublisher: NotificationCenter.Publisher = NotificationCenter.default
            .publisher(for: UIResponder.keyboardDidHideNotification)
        
        hidePublisher.receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                self?.keyboardDidHide()
            }.store(in: &cancellables)
    }
}

extension ViewController: MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                             didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled, .failed:
            sentMessageWithSuccess(false)
        case .sent:
            sentMessageWithSuccess(true)
        @unknown default:
            break
        }
        controller.dismiss(animated: true)
    }
}

