import UIKit

public extension UITextField {
    
    enum PaddingSpace {
        case left(CGFloat)
        case right(CGFloat)
        case equalSpacing(CGFloat)
    }

    func addPadding(padding: PaddingSpace) {

        self.leftViewMode = .always
        self.layer.masksToBounds = true

        switch padding {

        case .left(let spacing):
            if let leftView = leftView {
                leftView.frame = CGRect(origin: leftView.frame.origin,
                                        size: .init(width: leftView.frame.width + (spacing * 2.0),
                                                    height: leftView.frame.height))
                return
            }
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.leftView = leftPaddingView
            self.leftViewMode = .always

        case .right(let spacing):
            let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.rightView = rightPaddingView
            self.rightViewMode = .always

        case .equalSpacing(let spacing):
            addPadding(padding: .left(spacing))
            addPadding(padding: .right(spacing))
        }
    }
    
    func validate(as type: ValidatorType) throws -> String {
        let validator = Validators.validatorFor(type: type)
        return try validator.validate(text!)
    }
}
