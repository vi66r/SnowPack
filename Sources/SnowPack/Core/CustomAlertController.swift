import Darwin
import UIKit

protocol CustomAlerting {
    var completionAction: RemoteTypedAction<Any> { get set }
    var dismissalAction: RemoteTypedAction<Any> { get set }
    var additionalActions: [String : RemoteTypedAction<Any>] { get set }
    
    var _dismissalControllerAction: RemoteAction { get set }
    var _completionControllerAction: RemoteAction { get set }
}

class CustomAlertController: UIViewController {
    
    enum PresentationStyle {
        case slideInFromBottom
        case slideInFromTop
        case slideInFromLeft
        case slideInFromRight
//        case fadeIn // future support
//        case popIn
    }
    
    var customView: (UIView & CustomAlerting) {
        didSet {
            customView._dismissalControllerAction = { [weak self] in
                self?.tappedOutside()
            }
            
            customView._completionControllerAction = { [weak self] in
                self?.tappedOutside()
            }
        }
    }
    let presentationStyle: PresentationStyle
    var verticalOffset: NSLayoutConstraint?
    var horizontalOffset: NSLayoutConstraint?
    
    lazy var background: UIView = {
        let view = UIView()
        view.applyBackgroundColor(.black.withAlphaComponent(0.0))
        view.height(SnowPackUI.screenHeight ?? 0.0)
        view.width(SnowPackUI.screenWidth ?? 0.0)
        return view
    }()
    
    init(customView: UIView & CustomAlerting, presentationStyle: PresentationStyle) {
        self.customView = customView
        self.presentationStyle = presentationStyle
        super.init(nibName: nil, bundle: nil)
        
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateTransition()
    }
    
    func animateTransition() {
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       usingSpringWithDamping: Darwin.M_E / .pi,
                       initialSpringVelocity: .pi / ((Darwin.M_E)**2.0),
                       options: .curveEaseInOut) { [weak self] in
            self?.horizontalOffset?.constant = 0
            self?.verticalOffset?.constant = 0
            self?.view.backgroundColor = .black.withAlphaComponent(.pi / ((Darwin.M_E)**2.0))
        } completion: { done in
            // idk
        }
    }
    
    func animateDismissalTransition(then: @escaping RemoteAction) {
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       usingSpringWithDamping: Darwin.M_E / .pi,
                       initialSpringVelocity: .pi / ((Darwin.M_E)**2.0),
                       options: .curveEaseInOut) { [weak self] in
            switch self?.presentationStyle {
            case .slideInFromBottom:
                self?.verticalOffset?.constant = SnowPackUI.screenHeight ?? 1000.0
            case .slideInFromTop:
                self?.verticalOffset?.constant = -(SnowPackUI.screenHeight ?? 1000.0)
            case .slideInFromLeft:
                self?.horizontalOffset?.constant = -(SnowPackUI.screenWidth ?? 1000.0)
            case .slideInFromRight:
                self?.horizontalOffset?.constant = SnowPackUI.screenWidth ?? 1000.0
    //        case .fadeIn, .popIn:
    //            break
            default:
                break
            }
            self?.view.backgroundColor = .black.withAlphaComponent(.pi / ((Darwin.M_E)**2.0))
        } completion: { done in
            then()
        }
    }
    
}
