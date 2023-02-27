import UIKit

public extension UIColor {
    
    static var isDarkModeAllowed = false
    
    // MARK: - Color System
    
    func configureSemanticColorSystem(
        brand: UIColor = UIColor(rgb: 0x1AC8ED),
        accent: UIColor = UIColor(rgb: 0x97DFFC),
        tint: UIColor = UIColor(rgb: 0x003459),
        background: UIColor = UIColor(rgb: 0xFFFFFF),
        surface: UIColor = UIColor(rgb: 0xFFFFFF),
        error: UIColor = UIColor(rgb: 0xB00020),
        warning: UIColor = UIColor(rgb: 0xF48C06),
        success: UIColor = UIColor(rgb: 0x90A959)
    ) {
        UIColor._brand = brand
        UIColor._accent = accent
        UIColor._tint = tint
        UIColor._background = background
        UIColor._surface = surface
        UIColor._error = error
        UIColor._warning = warning
        UIColor._success = success
    }
    
    func configureSemanticColorSystemDark(
        brandDark: UIColor = UIColor(rgb: 0x1AC8ED),
        accentDark: UIColor = UIColor(rgb: 0x97DFFC),
        tintDark: UIColor = UIColor(rgb: 0x858AE3),
        backgroundDark: UIColor = UIColor(rgb: 0xFFFFFF),
        surfaceDark: UIColor = UIColor(rgb: 0xFFFFFF),
        errorDark: UIColor = UIColor(rgb: 0xB00020),
        warningDark: UIColor = UIColor(rgb: 0xF48C06),
        successDark: UIColor = UIColor(rgb: 0x90A959)
    ) {
        UIColor._brandDark = brandDark
        UIColor._tintDark = tintDark
        UIColor._backgroundDark = backgroundDark
        UIColor._surfaceDark = surfaceDark
        UIColor._errorDark = errorDark
        UIColor._warningDark = warningDark
        UIColor._successDark = successDark
    }
    
    func configureSemanticTextColorSystem(
        textBrand: UIColor = UIColor(rgb: 0xFFFFFF),
        textAccent: UIColor = UIColor(rgb: 0xFFFFFF),
        textBackground: UIColor = UIColor(rgb: 0x00171F),
        textSurface: UIColor = UIColor(rgb: 0x00171F),
        textError: UIColor = UIColor(rgb: 0xFFFBFF),
        textWarning: UIColor = UIColor(rgb: 0xFFFBFF),
        textSuccess: UIColor = UIColor(rgb: 0xFFFBFF)
    ) {
        UIColor._textBrand = textBrand
        UIColor._textAccent = textAccent
        UIColor._textBackground = textBackground
        UIColor._textSurface = textSurface
        UIColor._textError = textError
        UIColor._textWarning = textWarning
        UIColor._textSuccess = textSuccess
    }
    
    func configureSemanticTextColorSystemDark(
        textBrandDark: UIColor = UIColor(rgb: 0xFFFFFF),
        textAccentDark: UIColor = UIColor(rgb: 0x0171F),
        textBackgroundDark: UIColor = UIColor(rgb: 0xFFFBFF),
        textSurfaceDark: UIColor = UIColor(rgb: 0xFFFBFF),
        textErrorDark: UIColor = UIColor(rgb: 0xFFFFFF),
        textWarningDark: UIColor = UIColor(rgb: 0xFFFFFF),
        textSuccessDark: UIColor = UIColor(rgb: 0xFFFFFF)
    ) {
        UIColor._textBrandDark = textBrandDark
        UIColor._textAccentDark = textAccentDark
        UIColor._textBackgroundDark = textBackgroundDark
        UIColor._textSurfaceDark = textSurfaceDark
        UIColor._textErrorDark = textErrorDark
        UIColor._textWarningDark = textWarningDark
        UIColor._textSuccessDark = textSuccessDark
    }
    
    func configureBrandColorSystem(
        primary: UIColor = UIColor(rgb: 0x1AC8ED),
        primaryVariation: UIColor = UIColor(rgb: 0x97DFFC),
        secondary: UIColor = UIColor(rgb: 0xAF7575),
        secondaryVariation: UIColor = UIColor(rgb: 0x8C2155),
        tertiary: UIColor = UIColor(rgb: 0x613DC1),
        tertiaryVariation: UIColor = UIColor(rgb: 0x4E148C)
    ) {
        UIColor.primary = primary
        UIColor.primaryVariation = primaryVariation
        UIColor.secondary = secondary
        UIColor.secondaryVariation = secondaryVariation
        UIColor.tertiary = tertiary
        UIColor.tertiaryVariation = tertiaryVariation
    }
    
    func configureBrandTextColorSystem(
        textPrimary: UIColor = UIColor(rgb: 0xFFFFFF),
        textPrimaryVariation: UIColor = UIColor(rgb: 0x000000),
        textSecondary: UIColor = UIColor(rgb: 0xFFFFFF),
        textSecondaryVariation: UIColor = UIColor(rgb: 0xFFFFFF),
        textTertiary: UIColor = UIColor(rgb: 0x000000),
        textTertiaryVariation: UIColor = UIColor(rgb: 0x000000)
    ) {
        UIColor.textPrimary = textPrimary
        UIColor.textPrimaryVariation = textPrimaryVariation
        UIColor.textSecondary = textSecondary
        UIColor.textSecondaryVariation = textSecondaryVariation
        UIColor.textTertiary = textTertiary
        UIColor.textTertiaryVariation = textTertiaryVariation
    }
    
    // Semantic Color Accessors
    static var brand: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._brandDark : UIColor._brand) : UIColor._brand }
    static var accent: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._accentDark : UIColor._accent) : UIColor._accent}
    static var tint: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._tintDark : UIColor._tint) : UIColor._tint}
    static var background: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._backgroundDark : UIColor._background) : UIColor._background }
    static var surface: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._surfaceDark : UIColor._surface) : UIColor._surface }
    static var error: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._errorDark : UIColor._error) : UIColor._error }
    static var warning: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._warningDark : UIColor._warning) : UIColor._warning }
    static var success: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._successDark : UIColor._success) : UIColor._success }
    
    // Semantic Text Color Accessors
    static var textBrand: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._textBrandDark : UIColor._textBrand) : UIColor._textBrand }
    static var textAccent: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._textAccentDark : UIColor._textAccent) : UIColor._textAccent }
    static var textBackground: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._textBackgroundDark : UIColor._textBackground) : UIColor._textBackground }
    static var textSurface: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._textSurfaceDark : UIColor._textSurface) : UIColor._textSurface }
    static var textError: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._textErrorDark : UIColor._textError) : UIColor._textError }
    static var textWarning: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._textWarningDark : UIColor._textWarning) : UIColor._textWarning }
    static var textSuccess: UIColor { UIColor.isDarkModeAllowed ?
        (SnowPack.interfaceIsDarkMode() ? UIColor._textSuccessDark : UIColor._textSuccess) : UIColor._textSuccess }
    
    // Semantic Colors - Dark Mode
    static var _brandDark = UIColor(rgb: 0x2C0735)
    static var _accentDark = UIColor(rgb: 0x4E148C)
    static var _tintDark = UIColor(rgb: 0x858AE3)
    static var _backgroundDark = UIColor(rgb: 0x151515)
    static var _surfaceDark = UIColor(rgb: 0x000500)
    static var _errorDark = UIColor(rgb: 0xA63D40)
    static var _warningDark = UIColor(rgb: 0xE9B872)
    static var _successDark = UIColor(rgb: 0x90A959)
    
    // Semantic Colors - Light Mode
    static var _brand = UIColor(rgb: 0x1AC8ED)
    static var _accent = UIColor(rgb: 0x97DFFC)
    static var _tint = UIColor(rgb: 0x003459)
    static var _background = UIColor(rgb: 0xFFFFFF)
    static var _surface = UIColor(rgb: 0xFFFFFF)
    static var _error = UIColor(rgb: 0xB00020)
    static var _warning = UIColor(rgb: 0xF48C06)
    static var _success = UIColor(rgb: 0x90A959)
    
    // Brand Colors
    static var primary = UIColor(rgb: 0x1AC8ED)
    static var primaryVariation = UIColor(rgb: 0x97DFFC)
    static var secondary = UIColor(rgb: 0xAF7575)
    static var secondaryVariation = UIColor(rgb: 0x8C2155)
    static var tertiary = UIColor(rgb: 0x613DC1)
    static var tertiaryVariation = UIColor(rgb: 0x4E148C)
    
    // Semantic Text Colors - Light Mode
    static var _textBrand = UIColor(rgb: 0xFFFFFF)
    static var _textAccent = UIColor(rgb: 0xFFFFFF)
    static var _textBackground = UIColor(rgb: 0x00171F)
    static var _textSurface = UIColor(rgb: 0x00171F)
    static var _textError = UIColor(rgb: 0xFFFBFF)
    static var _textWarning = UIColor(rgb: 0xFFFBFF)
    static var _textSuccess = UIColor(rgb: 0xFFFBFF)
    
    // Semantic Text Colors - Dark Mode
    static var _textBrandDark = UIColor(rgb: 0xFFFFFF)
    static var _textAccentDark = UIColor(rgb: 0x0171F)
    static var _textBackgroundDark = UIColor(rgb: 0xFFFBFF)
    static var _textSurfaceDark = UIColor(rgb: 0xFFFBFF)
    static var _textErrorDark = UIColor(rgb: 0xFFFFFF)
    static var _textWarningDark = UIColor(rgb: 0xFFFFFF)
    static var _textSuccessDark = UIColor(rgb: 0xFFFFFF)
    
    // Brand Text Colors
    static var textPrimary = UIColor(rgb: 0xFFFFFF)
    static var textPrimaryVariation = UIColor(rgb: 0x000000)
    static var textSecondary = UIColor(rgb: 0xFFFFFF)
    static var textSecondaryVariation = UIColor(rgb: 0xFFFFFF)
    static var textTertiary = UIColor(rgb: 0x000000)
    static var textTertiaryVariation = UIColor(rgb: 0x000000)
    
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
    
    convenience init(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            self.init(rgb: 0x808080)
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    convenience init(rgb: Int) {
        let r = (rgb >> 16) & 0xFF
        let g = (rgb >> 8) & 0xFF
        let b = rgb & 0xFF
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: 1.0)
   }
    
    // MARK: - Debug
    
    static func _randomColor() -> UIColor {
        UIColor(hue: CGFloat(drand48()), saturation: 1, brightness: 1, alpha: 1)
    }
    
    func _hexValue() -> String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX",
                                    lroundf(Float(r * 255)),
                                    lroundf(Float(g * 255)),
                                    lroundf(Float(b * 255))
        )
        return hexString
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
