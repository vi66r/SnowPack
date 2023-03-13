import UIKit

public final class Gradient: UIView {
    
    let gradient = CAGradientLayer()
    
    public init(colors: [UIColor], type: CAGradientLayerType = .axial, locations: [Double]? = nil) {
        super.init(frame: .zero)
        gradient.colors = colors.map({ $0.cgColor })
        gradient.type = type
        if let locations = locations {
            gradient.locations = locations.map({ NSNumber(floatLiteral: $0) })
        }
        layer.addSublayer(gradient)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
    
}
