import UIKit

public final class TimePickerCell: UIView, Hydratable {
    
    public static var font: UIFont = .body
    public static var color: UIColor = .textBrand
    
    public lazy var label: UILabel = {
        let label = UILabel()
        label.applyBackgroundColor(.clear)
        label.textColor = TimePickerCell.color
        label.font = TimePickerCell.font
        label.textAlignment = .right
        return label
    }()
    
    public init() {
        super.init(frame: .zero)
        addSubview(label)
        label.edgesToSuperview()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func hydrate(with model: String) {
        label.text = model
    }
    
}
