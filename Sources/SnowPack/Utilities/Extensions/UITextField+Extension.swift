import UIKit

public extension UITextField {
    func validate(as type: ValidatorType) throws -> String {
        let validator = Validators.validatorFor(type: type)
        return try validator.validate(text!)
    }
}
