import UIKit

public final class Gradient: UIView {
    
    let gradient = CAGradientLayer()
    
    public init(colors: [UIColor], type: CAGradientLayerType = .axial) {
        super.init(frame: .zero)
        gradient.colors = colors.map({ $0.cgColor })
        gradient.type = type
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = frame
        layer.insertSublayer(gradient, at: 0)
    }
    
}
