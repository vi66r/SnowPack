import Darwin
import UIKit

public extension CGFloat {
    
    static var magicSpringDampening: CGFloat {
        Darwin.M_E / .pi
    }
    
    static var magicInitialSpringVelocity: CGFloat {
        .pi / ((Darwin.M_E)**2.0)
    }
    
}
