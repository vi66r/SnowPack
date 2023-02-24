import UIKit

final public class Badge: PassthroughView {
    
    /// A universal badge color value. Changing this will change the color of all badges.
    public static var color: UIColor = .red
    
    /// A universal badge font. Changing this will change the font of all badges.
    public static var font: UIFont = .systemFont(ofSize: 10.0)
    
    public var textColor = Badge.color.preferredOverlayTextColor
    
    public lazy var countLabel: PassthroughLabel = {
        let label = PassthroughLabel()
        label.font = Badge.font
        label.textColor = textColor
        return label
    }()
    
    public var value: Int = 0 {
        didSet {
            countLabel.text = value.friendly
            widthConstraint?.constant = Badge.font.estimatedSize(for: value.friendly).width + 2.0
        }
    }
    
    public var badgeHeight: CGFloat = 4.0
    
    public var showsValue: Bool = true {
        didSet { countLabel.isHidden = !showsValue }
    }
    
    var widthConstraint: NSLayoutConstraint?
    
    public init(badgeHeight: CGFloat = 4.0, showsValue: Bool = true) {
        self.showsValue = showsValue
        self.badgeHeight = badgeHeight
        super.init(frame: .zero)
        
        height(badgeHeight)
        widthConstraint = width(Badge.font.estimatedSize(for: value.friendly).width + 2.0)
        
        addSubview(countLabel)
        if !showsValue { countLabel.isHidden = true }
        countLabel.sizeToFit()
        countLabel.centerInSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        applyRoundedCorners(badgeHeight/2.0)
    }
}
