import UIKit

public class BlurEffectView: UIView {
    
    public override class var layerClass: AnyClass {
        return BlurIntensityLayer.self
    }
    
    @objc
    @IBInspectable
    public dynamic var intensity: CGFloat {
        set { blurIntensityLayer.intensity = newValue }
        get { return blurIntensityLayer.intensity }
    }
    
    @IBInspectable
    public var effect = UIBlurEffect(style: .dark) {
        didSet { setupPropertyAnimator() }
    }
    
    private let visualEffectView = PassthroughVisualEffectView(effect: nil)
    private var propertyAnimator: UIViewPropertyAnimator!
    
    private var blurIntensityLayer: BlurIntensityLayer {
        return layer as! BlurIntensityLayer
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    deinit {
        propertyAnimator.stopAnimation(true)
    }
    
    private func setupPropertyAnimator() {
        propertyAnimator?.stopAnimation(true)
        propertyAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear)
        propertyAnimator.addAnimations { [weak self] in
            self?.visualEffectView.effect = self?.effect
        }
        propertyAnimator.pausesOnCompletion = true
    }
    
    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        addSubview(self.visualEffectView)
        visualEffectView.edgesToSuperview()
        setupPropertyAnimator()
    }
    
    public override func display(_ layer: CALayer) {
        guard let presentationLayer = layer.presentation() as? BlurIntensityLayer else {
            return
        }
        let clampedIntensity = max(0.0, min(1.0, presentationLayer.intensity))
        propertyAnimator.fractionComplete = clampedIntensity
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
