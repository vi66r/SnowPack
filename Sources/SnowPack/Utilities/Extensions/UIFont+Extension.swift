import UIKit

public extension UIFont {
    
    enum SizeClass {
        case heading
        case body
        case caption
    }
    
    private static var _heading: String = UIFont.sfProRounded().fontName
    private static var _body: String = UIFont.sfProRounded().fontName
    private static var _caption: String = UIFont.sfProRounded().fontName
    
    private static var _h1: CGFloat = 36.0
    private static var _h2: CGFloat = 24.0
    private static var _h3: CGFloat = 20.0
    private static var _h4: CGFloat = 16.0
    
    static var heading: UIFont = .sfProRounded(size: _h1, weight: .bold)
    static var heading2: UIFont = .sfProRounded(size: _h2, weight: .bold)
    static var heading3: UIFont = .sfProRounded(size: _h3, weight: .bold)
    static var heading4: UIFont = .sfProRounded(size: _h4, weight: .bold)
    
    private static var _b1: CGFloat = 14.0
    private static var _b2: CGFloat = 16.0
    private static var _b3: CGFloat = 20.0
    private static var _b4: CGFloat = 22.0
    
    static var body: UIFont = .sfProRounded(size: _b1, weight: .medium)
    static var body2: UIFont = .sfProRounded(size: _b2, weight: .medium)
    static var body3: UIFont = .sfProRounded(size: _b3, weight: .medium)
    static var body4: UIFont = .sfProRounded(size: _b4, weight: .medium)
    
    private static var _c1: CGFloat = 10.0
    private static var _c2: CGFloat = 12.0
    private static var _c3: CGFloat = 14.0
    private static var _c4: CGFloat = 18.0
    
    static var caption: UIFont = .sfProRounded(size: _c1, weight: .regular)
    static var caption2: UIFont = .sfProRounded(size: _c2, weight: .regular)
    static var caption3: UIFont = .sfProRounded(size: _c3, weight: .regular)
    static var caption4: UIFont = .sfProRounded(size: _c4, weight: .regular)
    
    static func registerFontFamiliesFor(heading: String? = nil,
                                        body: String? = nil,
                                        caption: String? = nil,
                                        display: String? = nil
    ) {
        if let heading = heading {
            UIFont.heading = customDynamicFont(named: heading, withStyle: .headline, size: _h1)
            UIFont.heading2 = customDynamicFont(named: heading, withStyle: .headline, size: _h2)
            UIFont.heading3 = customDynamicFont(named: heading, withStyle: .headline, size: _h3)
            UIFont.heading4 = customDynamicFont(named: heading, withStyle: .headline, size: _h4)
        }
        
        if let body = body {
            UIFont.body = customDynamicFont(named: body, withStyle: .headline, size: _b1)
            UIFont.body2 = customDynamicFont(named: body, withStyle: .headline, size: _b2)
            UIFont.body3 = customDynamicFont(named: body, withStyle: .headline, size: _b3)
            UIFont.body4 = customDynamicFont(named: body, withStyle: .headline, size: _b4)
        }
        
        if let caption = caption {
            UIFont.caption = customDynamicFont(named: caption, withStyle: .headline , size: _c1)
            UIFont.caption2 = customDynamicFont(named: caption, withStyle: .headline, size: _c2)
            UIFont.caption3 = customDynamicFont(named: caption, withStyle: .headline, size: _c3)
            UIFont.caption4 = customDynamicFont(named: caption, withStyle: .headline, size: _c4)
        }
    }
    
    static func setSizes(s1: CGFloat? = nil,
                         s2: CGFloat? = nil,
                         s3: CGFloat? = nil,
                         s4: CGFloat? = nil,
                         for sizeClass: SizeClass) {
        switch sizeClass {
        case .heading:
            _h1 = s1 ?? _h1
            _h2 = s2 ?? _h2
            _h3 = s3 ?? _h3
            _h4 = s4 ?? _h4
        case .body:
            _b1 = s1 ?? _b1
            _b2 = s2 ?? _b2
            _b3 = s3 ?? _b3
            _b4 = s4 ?? _b4
        case .caption:
            _c1 = s1 ?? _c1
            _c2 = s2 ?? _c2
            _c3 = s3 ?? _c3
            _c4 = s4 ?? _c4
        }
    }
    
    private static func reloadFonts() {
        
    }
    
    static func sfProRounded(
        withStyle style: UIFont.TextStyle = .body,
        size fontSize: CGFloat = 16.0,
        weight: UIFont.Weight = .regular
    ) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
        let roundedFont: UIFont
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            roundedFont = UIFont(descriptor: descriptor, size: fontSize)
        } else {
            roundedFont = systemFont
        }
        return roundedFont
    }
    
    static func customDynamicFont(
        named name: String,
        withStyle style: UIFont.TextStyle = .body,
        size fontSize: CGFloat = 16.0
    ) -> UIFont {
        guard let customFont = UIFont(
            name: name,
            size: fontSize)
        else {
            let descriptor = UIFontDescriptor
                .preferredFontDescriptor(withTextStyle: style)
            return UIFont(descriptor: descriptor, size: descriptor.pointSize)
        }
        return customFont.dynamicallyTyped(withStyle: style)
    }
    
    func dynamicallyTyped(withStyle style: UIFont.TextStyle) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        return metrics.scaledFont(for: self)
    }
    
    func estimatedSize(for text: String) -> CGSize {
        let attributes = [NSAttributedString.Key.font : self]
        return (text as NSString).size(withAttributes: attributes)
    }
    
}
