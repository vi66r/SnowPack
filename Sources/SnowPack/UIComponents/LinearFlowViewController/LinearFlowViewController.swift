import Combine
import UIKit

open class LinearFlowViewController: UIPageViewController {
    
    // MARK: - Adapted From ViewController
    
    public var cancellables = Set<AnyCancellable>()
    /// no need to touch this value ever, instead call `showBasicLoader(with: ...)` and `hideBasicLoader()`
    public var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    private(set) var navigationBarHidden: Bool = false
    
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
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationBarHidden = true
        
        if !stages.isEmpty {
            setViewControllers([stages.first!], direction: .forward, animated: true)
        }
        
        // Do any additional setup after loading the view.
    }
    
    open func showNavigationBar(animated: Bool = true) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationBarHidden = false
    }
    
    open func hideNavigationBar(animated: Bool = true) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationBarHidden = true
    }
    
    open func addSubview(_ view: UIView) {
        self.view.addSubview(view)
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
    
    // - END ViewController Adaptated Portion
    
    var currentPosition: Int = 0
    
    public enum FlowStage: Int {
        case starting = -1
        case inProgress = 0
        case ending = 1
    }
    
    public enum IndicatorPosition {
        case bottom
        case top
        case left
        case right
    }
    
    public var showsIndicator: Bool = false
    public var indicatorPosition: IndicatorPosition = .bottom
    
    public var flowStateUpdateAction: RemoteTypedAction<FlowStage>?
    public var currentStageUpdateAction: RemoteTypedAction<ViewController>?
    public var flowStage: FlowStage = .starting {
        didSet {
            flowStateUpdateAction?(flowStage)
        }
    }
    
    var currentStage: ViewController? {
        didSet {
            currentStageUpdateAction?(currentStage)
        }
    }
    
    public var stages: [ViewController] = [] {
        didSet {
            guard !stages.isEmpty else { return }
            setViewControllers([stages.first!], direction: .forward, animated: true)
        }
    }
    
    public init(stages: [ViewController],
                axis: UIPageViewController.NavigationOrientation = .horizontal,
                options: [UIPageViewController.OptionsKey : Any]? = nil
    ) {
        super.init(transitionStyle: .scroll, navigationOrientation: axis, options: options)
        self.stages = stages
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func next() {
        guard !stages.isEmpty, currentPosition + 1 < stages.count else { return }
        currentPosition += 1
        updateFlowStage()
        let target = stages[currentPosition]
        setViewControllers([target], direction: .forward, animated: true)
        currentStage = target
    }
    
    open func previous() {
        guard !stages.isEmpty, currentPosition - 1 >= 0 else { return }
        currentPosition -= 1
        updateFlowStage()
        let target = stages[currentPosition]
        setViewControllers([target], direction: .reverse, animated: true)
        currentStage = target
    }
    
    private func updateFlowStage() {
        switch currentPosition {
        case 0:
            flowStage = .starting
        case stages.count - 1:
            flowStage = .ending
        default:
            flowStage = .inProgress
        }
    }
}
