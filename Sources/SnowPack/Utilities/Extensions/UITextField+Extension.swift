import UIKit

public extension UITextField {
    func validate(as type: ValidatorType) throws -> String {
        let validator = ValidatorFactory.validatorFor(type: type)
        return try validator.validate(text!)
    }
}
