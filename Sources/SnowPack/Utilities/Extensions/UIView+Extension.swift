import TinyConstraints
import UIKit

public extension UIView {
    
    @discardableResult
    func addActivityIndicatorToCenter<T: UIView>() -> T {
        let activityIndicator = UIActivityIndicatorView()
        let overlay = UIView()
        overlay.accessibilityIdentifier = "Snowpack.UIViewActivityIndicator"
        overlay.applyBackgroundColor(.black.withAlphaComponent(0.35))
        overlay.alpha = 0.0
        overlay.addSubview(activityIndicator)
        activityIndicator.centerInSuperview()
        addSubview(overlay)
        overlay.edgesToSuperview()
        activityIndicator.startAnimating()
        activityIndicator.color = .textBrand
        UIView.animate(withDuration: 0.2) {
            overlay.alpha = 1.0
        }
        return self as! T
    }
    
    @discardableResult
    func removeActivityIndicatorAtCenter<T: UIView>() -> T {
        let activityOverlay = subviews.first(where: { $0.accessibilityIdentifier == "Snowpack.UIViewActivityIndicator" })
        UIView.animate(withDuration: 0.2) {
            activityOverlay?.alpha = 0.0
        } completion: { done in
            activityOverlay?.removeFromSuperview()
        }
        return self as! T
    }
    
    var snapshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// A convenient method to set a view's `layer.cornerRadius` property while also ensuring
    /// that the `cornerCurve` and `masksToBounds` properties are set correctly
    @discardableResult
    func applyRoundedCorners<T: UIView>(_ cornerRadius: CGFloat, curve: CALayerCornerCurve = .circular) -> T {
        layer.cornerCurve = curve
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        return self as! T
    }
    
    /// A convenient method to set a view's `layer.borderColor` and `layer.borderWidth` properties
    @discardableResult
    func applyBorder<T: UIView>(_ color: UIColor, width: CGFloat) -> T {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        return self as! T
    }
    
    @discardableResult
    func applyTint<T: UIView>(_ color: UIColor) -> T {
        tintColor = color
        return self as! T
    }
    
    @discardableResult
    func applyBackgroundColor<T: UIView>(_ color: UIColor) -> T {
        backgroundColor = color
        return self as! T
    }
    
    @discardableResult
    func applyStroke<T: UIView>(weight: CGFloat, color: UIColor) -> T {
        layer.borderColor = color.cgColor
        layer.borderWidth = weight
        return self as! T
    }

    @discardableResult
    func heightWidth<T: UIView>(_ value: CGFloat,
                                relation: ConstraintRelation = .equal,
                                priority: LayoutPriority = .defaultHigh,
                                isActive: Bool = true
    ) -> T {
        height(value, relation: relation, priority: priority, isActive: isActive)
        width(value, relation: relation, priority: priority, isActive: isActive)
        return self as! T
    }
    
    private func applyBorder(to edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let border = UIView()

        border.backgroundColor = color
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: bounds.width, height: thickness)
            border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        case .bottom:
            border.frame = CGRect(x: 0, y: bounds.height - thickness, width: bounds.width, height: thickness)
            border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: bounds.height)
            border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        case .right:
            border.frame = CGRect(x: bounds.width - thickness, y: 0, width: thickness, height: bounds.height)
            border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        default:
            break
        }
        
        addSubview(border)
    }
    
    func applyBorders(to edges: [UIRectEdge], color: UIColor, thickness: CGFloat) {
        layer.sublayers?.removeAll(where: { $0.name == "border"})
        
        edges.forEach {
            applyBorder(to: $0, color: color, thickness: thickness)
        }
    }
    
    func removeAllConstraints() {
        var _superview = self.superview
        
        while let superview = _superview {
            for constraint in superview.constraints {
                
                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }
                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }
            _superview = superview.superview
        }
        
        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
    // MARK: - Shadows
    @discardableResult
    func applyBoundingShadow<T: UIView>(inverted: Bool = false) -> T{
        layer.shadowColor = (inverted ? UIColor.white : UIColor.black).withAlphaComponent(0.95).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 1.0
        return self as! T
    }
    
    @discardableResult
    func applyDropShadow<T: UIView>(inverted: Bool = false, opacity: Float = 0.1, radius: CGFloat = 12.0) -> T {
        layer.shadowColor = (inverted ? UIColor.white : UIColor.black).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3.0)
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        return self as! T
    }
    
    @discardableResult
    func removeShadow<T: UIView>() -> T {
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.0
        layer.shadowRadius = 0.0
        return self as! T
    }
    
    // MARK: - Blurring
    
    @discardableResult
    func applyBlurOverlay<T: UIView>(animated: Bool,
                                     intensity: CGFloat = 0.3
    ) -> T {
        let blurView = BlurEffectView()
        blurView.intensity = 0.3
        blurView.frame = .init(origin: .zero, size: frame.size)
        blurView.alpha = 0.0
        blurView.accessibilityIdentifier = "VisualEffect.Blur" // not a great practice for accessibility
        addSubview(blurView)
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, animations: {
                blurView.alpha = 1.0
            })
        } else {
            blurView.alpha = 1.0
        }
        
        return self as! T
    }
    
    @discardableResult
    func removeBlurOverlay<T: UIView>(animated: Bool) -> T {
        let visualEffectView = subviews.first(where: { $0.accessibilityIdentifier == "VisualEffect.Blur" })
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, animations: {
                visualEffectView?.alpha = 0.0
            }, completion: { done in
                visualEffectView?.removeFromSuperview()
            })
        } else {
            visualEffectView?.removeFromSuperview()
        }
        
        return self as! T
    }
    
    func scaleToWidthWhileMaintainingAspectRatio(_ width: CGFloat) {
        let aspectRatio = frame.width/frame.height
        let newHeight = width / aspectRatio
        
        frame = CGRect(
            origin: frame.origin,
            size: CGSize(width: width, height: newHeight)
        )
    }
    
    func duplicate<T: UIView>() -> T? {
        guard let objectData = try? NSKeyedArchiver.archivedData(
            withRootObject: self,
            requiringSecureCoding: false
        ) else {
            return nil
        }
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(objectData) as? T
    }
    
    var allSubviews: [UIView] {
        subviews + subviews.flatMap { $0.allSubviews }
    }
    
    /// Sets the corner radius to half of the bounds width
    /// and sets masksToBounds equal to True,
    /// resulting in a view appearing as a circle
    func makeCircular() {
        layer.masksToBounds = true
        layer.cornerRadius = frame.width * 0.5
    }

    func gradientColor(bounds: CGRect, gradientLayer: CAGradientLayer) -> UIColor? {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        gradientLayer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return UIColor(patternImage: image)
    }

    // MARK: - Animations
    func dim() {
        UIView.animate(withDuration: 0.25, delay: 0.0) { [weak self] in
            self?.alpha = 0.25
        }
    }
    
    func lighten() {
        UIView.animate(withDuration: 0.25, delay: 0.0) { [weak self] in
            self?.alpha = 1.0
        }
    }

    func hide(then: RemoteAction? = nil) {
        guard !isHidden else { return }
        UIView.animate(
            withDuration: 0.1,
            animations: ({ [weak self] in
                self?.alpha = 0.0
            }),
            completion: ({ [weak self] done in
                self?.isHidden = true
                then?()
            })
        )
    }

    func unhide(then: RemoteAction? = nil) {
        guard isHidden else { return }
        UIView.animate(
            withDuration: 0.1,
            animations: ({ [weak self] in
                self?.alpha = 1.0
            }),
            completion: ({ [weak self] done in
                self?.isHidden = false
                then?()
            })
        )
    }
    
    func animateRotation() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: (Double.pi * 2))
        rotation.duration = 0.5
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func animateScale(by scale: CGFloat) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else { return }
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }
    
    func animateTranslation(by x: CGFloat, y: CGFloat) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else { return }
            self.transform = self.transform.translatedBy(x: x, y: y)
        })
    }
    
    func animateTransformToIdentity() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.transform = .identity
        })
    }
    
    // MARK: - Debugging
    func applyDebugBorder(includingSubviews: Bool = false) {
        let debugColor: UIColor
        switch self {
        case is UIImageView:
            debugColor = .red
        case is UILabel:
            debugColor = .blue
        case is UITextField:
            debugColor = .cyan
        case is UIStackView:
            debugColor = .brown
        default:
            debugColor = .green
        }
        applyBorder(debugColor, width: 2.0)
        if includingSubviews {
            allSubviews.forEach { $0.applyDebugBorder() }
        }
    }
}

