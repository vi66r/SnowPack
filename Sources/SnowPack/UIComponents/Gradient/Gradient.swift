import UIKit

final class Gradient: UIView {
    
    let gradient = CAGradientLayer()
    
    init(colors: [UIColor], type: CAGradientLayerType = .axial) {
        super.init(frame: .zero)
        gradient.colors = colors.map({ $0.cgColor })
        gradient.type = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = frame
    }
    
    
}
