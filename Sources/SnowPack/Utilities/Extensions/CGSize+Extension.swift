import UIKit

public extension CGSize {
    var containingSquare: CGSize {
        let max = max(width, height)
        
        return .init(width: max, height: max)
    }
    
    init(square: CGFloat) {
        self.init(width: square, height: square)
    }
    
    static func square(_ value: CGFloat) -> CGSize {
        CGSize(width: value, height: value)
    }
    
    var aspectRatio: CGFloat {
        width / height
    }
    
    func scaledToWidth(_ targetWidth: CGFloat) -> CGSize {
        let ratio = targetWidth/width
        let adjustedHeight = height * ratio
        return CGSize(width: targetWidth, height: adjustedHeight)
    }
}
