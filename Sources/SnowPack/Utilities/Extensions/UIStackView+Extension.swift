import UIKit

public extension UIStackView {
    convenience init(
        axis: NSLayoutConstraint.Axis = .horizontal,
        alignment: Alignment = .fill,
        distribution: Distribution = .fill)
    {
        self.init()
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
    }
}
