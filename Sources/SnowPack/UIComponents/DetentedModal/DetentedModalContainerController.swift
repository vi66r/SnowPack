import Darwin
import UIKit

final class DetentedModalContainerController: UIViewController, Haptic {
    
    enum Style {
        case light
        case dark
        case black
    }
    
    var preferredDefaultHeight: CGFloat?
    
    var defaultHeight: CGFloat {
        (preferredDefaultHeight ?? UIScreen.main.bounds.height * 0.475) + 44.0
    }
    
    var dismissibleHeight: CGFloat {
        defaultHeight * 0.75
    }
    
    var preferredMaximumHeight: CGFloat?
    var maximumContainerHeight: CGFloat {
        (preferredMaximumHeight ?? UIScreen.main.bounds.height - 64) + 44.0
    }
    var stretchLimit: CGFloat {
        40
    }
    let maxDimmedAlpha: CGFloat = 0.6
    let animationTiming = 0.25
    
    let displayDragIndicator: Bool
    
    let springOnDisplay: Bool
    var springDampingValue: CGFloat {
        springOnDisplay ? 0.576 : 1.0
    }
    
    let useAutomaticContentInsets: Bool
    var horizontalContentInsets: CGFloat {
        useAutomaticContentInsets ? 10.0 : 0.0
    }
    
    lazy var containerView: UIView = {
        $0.backgroundColor = style == .dark ? .darkGray : .white
        if style == .black {
            $0.backgroundColor = .black.withAlphaComponent(0.8)
        }
        $0.applyRoundedCorners(35.0, curve: .continuous)
        $0.clipsToBounds = false
        return $0
    }(UIView())
    
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.0
        return view
    }()
    
    lazy var dragIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 4.0
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var currentContainerHeight: CGFloat = {
        defaultHeight
    }()
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    var mainChildController: UIViewController
    var style: Style
    
    init(
        _ viewController: UIViewController,
        _ style: Style = .light,
        _ preferredDefaultHeight: CGFloat? = nil,
        _ preferredMaximumHeight: CGFloat? = nil,
        _ displayDragIndicator: Bool = true,
        _ springOnDisplay: Bool = false,
        _ useAutomaticContentInsets: Bool = true
    ) {
        self.style = style
        self.preferredDefaultHeight = preferredDefaultHeight
        self.preferredMaximumHeight = preferredMaximumHeight
        self.displayDragIndicator = displayDragIndicator
        self.springOnDisplay = springOnDisplay
        self.useAutomaticContentInsets = useAutomaticContentInsets
        mainChildController = viewController
        super.init(nibName: nil, bundle: nil)
        addChild(mainChildController)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupConstraints()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        
        setupPanGesture()
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    func setupConstraints() {
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        containerView.addSubview(dragIndicator)
        
        if !displayDragIndicator {
            dragIndicator.isHidden = true
        }
        
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(mainChildController.view)
        mainChildController.view.translatesAutoresizingMaskIntoConstraints = false
        
        mainChildController.view.horizontalToSuperview(insets: .horizontal(horizontalContentInsets))
        mainChildController.view.verticalToSuperview(insets: .init(
            top: displayDragIndicator ? 30.0 : 11.0,
            left: 0.0,
            bottom: 44.0,
            right: 0.0)
        )
        
        dimmedView.edgesToSuperview()
        containerView.horizontalToSuperview()
        
        containerViewHeightConstraint = containerView.height(defaultHeight)
        containerViewBottomConstraint = containerView.bottomToSuperview(offset: defaultHeight)
        
        dragIndicator.centerXToSuperview()
        dragIndicator.topToSuperview(offset: 11.0)
        dragIndicator.width(44.0)
        dragIndicator.height(8.0)
    }
    
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        let isDraggingDown = translation.y > 0
        
        let newHeight = currentContainerHeight - translation.y
        
        let hapticRange = defaultHeight-1.0...defaultHeight+1.0
        
        if hapticRange ~= newHeight {
            softImpact()
        }
        
        switch gesture.state {
        case .changed:
            if newHeight < maximumContainerHeight {
                containerViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            } else if newHeight > maximumContainerHeight {
                containerViewHeightConstraint?.constant = maximumContainerHeight + 2*logC(val: newHeight-maximumContainerHeight, forBase: Darwin.M_E)
            }
        case .ended:
            if newHeight < dismissibleHeight {
                animateDismissView()
            } else if newHeight < defaultHeight {
                animateContainerHeight(defaultHeight)
            } else if newHeight < maximumContainerHeight && isDraggingDown {
                animateContainerHeight(defaultHeight)
            } else if newHeight > defaultHeight && !isDraggingDown {
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(
            withDuration: animationTiming,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: ({ [weak self] in
                self?.containerViewHeightConstraint?.constant = height
                self?.view.layoutIfNeeded()
            }),
            completion: ({ [weak self] done in
                if height == self?.defaultHeight { self?.softImpact() }
            })
        )
        currentContainerHeight = height
    }
    
    func animatePresentContainer() {
        UIView.animate(
            withDuration: animationTiming,
            delay: 0.0,
            usingSpringWithDamping: springDampingValue,
            initialSpringVelocity: 1,
            options: [.curveEaseInOut],
            animations: { [weak self] in
                self?.containerViewBottomConstraint?.constant = 44.0
                self?.view.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.doubleImpact()
            })
    }
    
    func animateShowDimmedView() {
        UIView.animate(withDuration: animationTiming) { [weak self] in
            self?.dimmedView.alpha = self?.maxDimmedAlpha ?? 0.6
        }
    }
    
    func animateDismissView(_ done: RemoteAction? = nil) {
        UIView.animate(
            withDuration: animationTiming,
            animations: ({ [weak self] in
                self?.dimmedView.alpha = 0.0
            }),
            completion: ({ [weak self] _ in
                self?.mediumImpact()
                (self?.parent ?? self)?.dismiss(animated: false)
                done?()
            })
        )
        
        UIView.animate(
            withDuration: animationTiming,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: ({ [weak self] in
                self?.containerViewBottomConstraint?.constant = self?.defaultHeight ?? 300
                self?.view.layoutIfNeeded()
            })
        )
    }
}
