import UIKit

/// A `UIButton` subclass that provides haptic and visual feedback as if this were a real button.
/// Note that it will always render a dynamic shadow under the button in its unpressed state, which
/// does have a (n extremely minute) performance impact. In the future this can be improved with
/// prerendering. More info here https://www.hackingwithswift.com/read/30/4/fixing-the-bugs-slow-shadows
open class HapticButton: UIButton, Haptic {
    
    public enum BadgePosition {
        case topRight
        case bottomRight
    }
    
    public typealias HapticStateImages = (unpressed: UIImage?, pressed: UIImage?)
    
    public override var backgroundColor: UIColor? {
        didSet {
            if originalBackgroundColor == nil {
                originalBackgroundColor = backgroundColor
            }
        }
    }
    
    public var badgeValue: Int = 0 {
        didSet {
            if badgeValue > 1 {
                badgeView.unhide()
                badgeView.value = badgeValue
            }
        }
    }
    
    private var badgeHeight: CGFloat
    private var badgePosition: BadgePosition
    private var showBadgeValue: Bool
    
    lazy private var badgeView: Badge = {
        // hard coded for now -- can be changed later
        let view = Badge(badgeHeight: badgeHeight, showsValue: showBadgeValue)
        return view
    }()
    
    private var originalBackgroundColor: UIColor? = nil
    private var renderShadow: Bool
    
    public init(
        renderShadow: Bool = false,
        badgeHeight: CGFloat = 4.0,
        badgePosition: BadgePosition = .topRight,
        hideBadgeOnLoad: Bool = true,
        showBadgeValue: Bool = true
    ) {
        self.renderShadow = renderShadow
        self.badgePosition = badgePosition
        self.badgeHeight = badgeHeight
        self.showBadgeValue = showBadgeValue
        super.init(frame: .zero)
        
        addSubview(badgeView)
        if hideBadgeOnLoad { badgeView.hide() }
        
        addAction(UIAction { [weak self] action in
            self?.pressDown()
        }, for: .touchDown)
        
        let unpressAction = UIAction { [weak self] action in self?.letGo() }
        [UIControl.Event.touchDragExit, .touchUpInside, .touchCancel].forEach({ addAction(unpressAction, for: $0) })
        
        if renderShadow {
            applyDropShadow()
        }
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        switch badgePosition {
        case .topRight:
            badgeView.topToSuperview(offset: -4)
        case .bottomRight:
            badgeView.bottomToSuperview(offset: 4)
        }
        badgeView.trailingToSuperview(offset: -4)
    }
    
    private func pressDown() {
        mediumImpact()
        if renderShadow { removeShadow() }
        backgroundColor = backgroundColor == .black ? backgroundColor?.lightened : backgroundColor?.darkened
    }
    
    private func letGo() {
        heavyImpact()
        if renderShadow { applyDropShadow() }
        backgroundColor = originalBackgroundColor
    }
    
    /// Sets the images for the pressed and unpressed states of the haptic button
    /// - Parameter images: Typealiased as `HapticStateImages`, this parameter is just a tuple
    /// where the first image item is `unpressed` which corresponds to `UIControlState.normal`
    /// and the second image item is `pressed` which corresponds to `UIControlState.highlighted`
    func setHapticStateImages(_ images: HapticStateImages) {
        setImage(images.unpressed, for: .normal)
        setImage(images.pressed, for: .highlighted)
    }
}
