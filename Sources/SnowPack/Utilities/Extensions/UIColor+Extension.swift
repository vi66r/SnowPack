import UIKit

public extension UIColor {
    // MARK: - Utilities
    
    var darkened: UIColor? {
        var r: CGFloat = 0,
            g: CGFloat = 0,
            b: CGFloat = 0,
            a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(
                red: max(r - 0.2, 0.0),
                green: max(g - 0.2, 0.0),
                blue: max(b - 0.2, 0.0),
                alpha: a
            )
        }
        return nil
    }
    
    var lightened: UIColor? {
        var r: CGFloat = 0,
            g: CGFloat = 0,
            b: CGFloat = 0,
            a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(
                red: max(r + 0.2, 0.0),
                green: max(g + 0.2, 0.0),
                blue: max(b + 0.2, 0.0),
                alpha: a
            )
        }
        return nil
    }
    
    /// Returns either `black` or `white` depending on the luminance of the color. Intended to be used to determine the color of text on top of the color in question.
    /// - Returns: `UIColor.black` or `UIColor.white`
    var preferredOverlayTextColor: UIColor {
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        brightness = ((r * 299) + (g * 587) + (b * 114)) / 1000;
        if (brightness < 0.5) {
            return .white
        }
        else {
            return .black
        }
    }
    
    // MARK: - Initializers
    
    convenience init(rgb: Int) {
        let r = (rgb >> 16) & 0xFF
        let g = (rgb >> 8) & 0xFF
        let b = rgb & 0xFF
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: 1.0)
   }
    
    // MARK: - Test Stuff
    
    static func test_randomColor() -> UIColor {
        UIColor(hue: CGFloat(drand48()), saturation: 1, brightness: 1, alpha: 1)
    }
    
    // MARK: - Color Image Generation
    func image(squareSize: CGFloat) -> UIImage {
        image(size: CGSize(square: squareSize))
    }
    
    func image(size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
