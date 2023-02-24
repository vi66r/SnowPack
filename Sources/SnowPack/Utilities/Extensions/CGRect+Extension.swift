import UIKit

public extension CGRect {
    
    func scaledToWidth(_ targetWidth: CGFloat) -> CGRect {
        let ratio = targetWidth/width
        let adjustedHeight = height * ratio
        return CGRect(x: minX, y: minY, width: targetWidth, height: adjustedHeight)
    }
    
    func centerTranslatedBy(x: CGFloat, y: CGFloat) -> CGRect {
        CGRect(x: minX + x, y: minY + y, width: size.width, height: size.height)
    }
    
    func scaledWithoutTransform(by value: CGFloat) -> CGRect {
        guard value > 0.0 else { return self }
        return CGRect(x: origin.x, y: origin.y, width: size.width * value, height: size.height * value)
    }
    
    func rotatedAboutCenter(by degrees: CGFloat) -> CGRect {
        // In order to draw within a CGContext at a particular angle, we need to do a few calculations.
        // 1. Establish a frame that we can easily find midpoint coordinates for with UIKit
        let _targetFrame = self
        let targetSize = size
        // 2. determine the diagonal value of our frame using pythagorean theorem
        // diagonal² = height² + width² ==> √(height² + width²)
        let frameHypotenuse = sqrt(pow(targetSize.height, 2) + pow(targetSize.width, 2))
        // 3. translate into radians
        let targetAngle = degrees * .pi / 180
        // 4. set a translation vector to be used later -- this will make sense in a few lines
        let recenterDistance = (frameHypotenuse / 2)
        // 5. because the cartesian coordinate space is also rotated when we apply a rotational transformation,
        // moving in any cardinal direction with respect to the original identity of the coordinate space
        // will require taking the angular components of that translation with respect to the target angle.
        // You can think of the translation as a 2D vector at the angle with respect to 0º.
        // To do this, we use the trigonometric functions sine and cosine where sin(x) = o/h and cos(x) = a/h
        // a is defined as the side adjacent to the angle, and therefore represents our horizontal component,
        // while o is the side opposite to the angle, and represents the veritcal component. h is understood to be
        // the distance that we want to move, and in order to find the components represented by o and a, we take
        // sin(x) = o/h => o = sin(x) * h, cos(x) = a/h => a = cos(x) * h
        let horizontalComponent = recenterDistance * cos(targetAngle)
        let verticalComponent = recenterDistance * sin(targetAngle)
        // 6. We first move the origin (top left corner) to center of the target frame, apply our rotation, and then
        // translate again by the components to move our center to where it previously was
        let rotationAboutCenterTransform = CGAffineTransform(translationX: _targetFrame.midX, y: _targetFrame.midY)
            .rotated(by: -targetAngle)
            .translatedBy(x: -horizontalComponent, y: -verticalComponent)
        
        return applying(rotationAboutCenterTransform)
    }
}
