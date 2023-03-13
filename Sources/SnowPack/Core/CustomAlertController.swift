import Darwin
import UIKit

public protocol CustomAlerting {
    var completionAction: RemoteTypedAction<Any>? { get set }
    var dismissalAction: RemoteTypedAction<Any>? { get set }
    var additionalActions: [String : RemoteTypedAction<Any>]? { get set }
    
    var _dismissalControllerAction: RemoteAction? { get set }
    var _completionControllerAction: RemoteAction? { get set }
}

public class CustomAlertController: UIViewController {
    
    public enum PresentationStyle {
        case slideInFromBottom
        case slideInFromTop
        case slideInFromLeft
        case slideInFromRight
//        case fadeIn // future support
//        case popIn
    }
    
    public var customView: (UIView & CustomAlerting) {
        didSet {
            customView._dismissalControllerAction = { [weak self] in
                self?.tappedOutside()
            }
            
            customView._completionControllerAction = { [weak self] in
                self?.tappedOutside()
            }
        }
    }
    public let presentationStyle: PresentationStyle
    public var verticalOffset: NSLayoutConstraint?
    public var horizontalOffset: NSLayoutConstraint?
    
    lazy var background: UIView = {
        let view = UIView()
        view.applyBackgroundColor(.black.withAlphaComponent(0.0))
        view.height(SnowPackUI.screenHeight ?? 0.0)
        view.width(SnowPackUI.screenWidth ?? 0.0)
        return view
    }()
    
    public init(customView: UIView & CustomAlerting, presentationStyle: PresentationStyle) {
        self.customView = customView
        self.presentationStyle = presentationStyle
        super.init(nibName: nil, bundle: nil)
        
        customView._dismissalControllerAction = { [weak self] in
            self?.tappedOutside()
        }
        
        customView._completionControllerAction = { [weak self] in
            self?.tappedOutside()
        }
        
        view.backgroundColor = .black.withAlphaComponent(0.0)
        
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.addTarget(self, action: #selector(tappedOutside))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func tappedOutside() {
        animateDismissalTransition(then: { [weak self] in
            self?.dismiss(animated: false)
        })
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        view.addSubview(customView)
        verticalOffset = customView.centerYToSuperview()
        horizontalOffset = customView.centerXToSuperview()
        
        switch presentationStyle {
        case .slideInFromBottom:
            verticalOffset?.constant = SnowPackUI.screenHeight ?? 1000.0
        case .slideInFromTop:
            verticalOffset?.constant = -(SnowPackUI.screenHeight ?? 1000.0)
        case .slideInFromLeft:
            horizontalOffset?.constant = -(SnowPackUI.screenWidth ?? 1000.0)
        case .slideInFromRight:
            horizontalOffset?.constant = SnowPackUI.screenWidth ?? 1000.0
//        case .fadeIn, .popIn:
//            break
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateTransition()
    }
    
    func animateTransition() {
        horizontalOffset?.constant = 0
        verticalOffset?.constant = 0
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       usingSpringWithDamping: Darwin.M_E / .pi,
                       initialSpringVelocity: .pi / ((Darwin.M_E)**2.0),
                       options: .curveEaseInOut) { [weak self] in
            self?.view.backgroundColor = .black.withAlphaComponent(.pi / ((Darwin.M_E)**2.0))
            self?.view.layoutSubviews()
        } completion: { done in
            // idk
        }
    }
    
    func animateDismissalTransition(then: @escaping RemoteAction) {
        
        switch presentationStyle {
        case .slideInFromBottom:
            verticalOffset?.constant = SnowPackUI.screenHeight ?? 1000.0
        case .slideInFromTop:
            verticalOffset?.constant = -(SnowPackUI.screenHeight ?? 1000.0)
        case .slideInFromLeft:
            horizontalOffset?.constant = -(SnowPackUI.screenWidth ?? 1000.0)
        case .slideInFromRight:
            horizontalOffset?.constant = SnowPackUI.screenWidth ?? 1000.0
        }
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       usingSpringWithDamping: Darwin.M_E / .pi,
                       initialSpringVelocity: .pi / ((Darwin.M_E)**2.0),
                       options: .curveEaseInOut) { [weak self] in
            self?.view.backgroundColor = .black.withAlphaComponent(.pi / ((Darwin.M_E)**2.0))
            self?.view.layoutSubviews()
        } completion: { done in
            then()
        }
    }
    
}
