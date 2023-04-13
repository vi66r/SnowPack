import Shuttle
import UIKit

public final class Toast: UIView {
    
    public enum Style {
        case fade
        case slide
    }
    
    public enum Position {
        case top
        case bottom
    }
    
    public enum Kind {
        case persistent
        case ephemeral(duration: Int)
    }
    
    public enum Variation {
        case regualar
        case error
        case translucentDark
    }
    
    public enum CornerStyle {
        case rounded
        case regular
    }
    
    public var displayDuration = -1
    var style: Style
    var position: Position
    var kind: Kind
    var variation: Variation
    var cornerStyle: CornerStyle
    var verticalOffset = 0.0
    
    public var requestDismissalAction: Action?
    
    public var message: String
    
    public var estimatedContentHeight: CGFloat {
        message.heightOfString(usingFont: .body)
    }
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        var color: UIColor
        switch variation {
        case .regualar:
            color = .textBrand
        case .error, .translucentDark:
            color = .white
        }
        button.tintColor = color
        button.heightWidth(40.0)
        return button
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .body
        label.numberOfLines = 0
        label.textAlignment = .center
        var color: UIColor
        switch variation {
        case .regualar:
            color = .textBrand
        case .error, .translucentDark:
            color = .white
        }
        label.textColor = color
        label.text = message
        return label
    }()
    
    public init(_ message: String,
                style: Style = .slide,
                position: Position = .top,
                kind: Kind = .ephemeral(duration: 3000),
                variation: Variation = .regualar,
                cornerStyle: CornerStyle = .rounded
    ) {
        self.style = style
        self.position = position
        self.kind = kind
        self.message = message
        self.variation = variation
        self.cornerStyle = cornerStyle
        super.init(frame: .zero)
        
        switch variation {
        case .regualar:
            backgroundColor = .brand
        case .error:
            backgroundColor = .error
        case .translucentDark:
            backgroundColor = .gray80.withAlphaComponent(0.5)
        }
        
        var safeAreaHeight: CGFloat
        switch position {
        case .top:
            safeAreaHeight = UIDevice.current.safeAreaInsets.top
        case .bottom:
            safeAreaHeight = UIDevice.current.safeAreaInsets.bottom
        }
        verticalOffset = safeAreaHeight
        
        switch kind {
        case .persistent:
            [dismissButton, messageLabel].forEach(addSubview(_:))
            dismissButton.trailingToSuperview(offset: -8.0)
            switch position {
            case .top:
                messageLabel.topToSuperview(offset: 4.0 + verticalOffset)
            case .bottom:
                messageLabel.bottomToSuperview(offset: -4.0 - verticalOffset)
            }
            dismissButton.centerY(to: messageLabel)
            messageLabel.leadingToSuperview(offset: 8.0)
            messageLabel.trailingToLeading(of: dismissButton, offset: -8.0)
        case .ephemeral(let duration):
            addSubview(messageLabel)
            messageLabel.horizontalToSuperview(insets: .horizontal(8.0))
            switch position {
            case .top:
                messageLabel.topToSuperview(offset: 4.0 + verticalOffset)
            case .bottom:
                messageLabel.bottomToSuperview(offset: -4.0 - verticalOffset)
            }
            displayDuration = duration
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
