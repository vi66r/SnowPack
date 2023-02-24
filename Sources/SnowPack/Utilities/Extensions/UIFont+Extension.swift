import UIKit

public extension UIFont {
    
    func estimatedSize(for text: String) -> CGSize {
        let attributes = [NSAttributedString.Key.font : self]
        return (text as NSString).size(withAttributes: attributes)
    }
    
}
