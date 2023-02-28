import UIKit

public struct NavigationBarConfiguration {
    public var titleStyle: UINavigationBar.TitleStyle
    public var appearance: UINavigationBar.DisplayStyle
}

public extension UINavigationBar {
    
    static var configuration = NavigationBarConfiguration(titleStyle: .regular,
                                                          appearance: .opaqueWhenScrolling)
    enum TitleStyle {
        case large
        case regular
    }
    
    enum DisplayStyle {
        case opaqueWhenScrolling
        case alwaysTransparent
        case alwaysOpaque
        case fullyHidden
        
        var standardAppearance: UINavigationBarAppearance {
            let appearance = UINavigationBarAppearance()
            
            switch self {
            case .opaqueWhenScrolling, .alwaysOpaque:
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .surface
                appearance.shadowColor = .surface
            case .alwaysTransparent:
                appearance.configureWithTransparentBackground()
            case .fullyHidden:
                break
            }
            
            appearance.titleTextAttributes = [.foregroundColor : UIColor.tint]
            appearance.largeTitleTextAttributes = [.foregroundColor : UIColor.tint]
            return appearance
        }
        
        var scrollEdgeAppearance: UINavigationBarAppearance {
            let appearance = UINavigationBarAppearance()
            
            switch self {
            case .alwaysOpaque:
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .surface
                appearance.shadowColor = .surface
            case .opaqueWhenScrolling, .alwaysTransparent:
                appearance.configureWithTransparentBackground()
            case .fullyHidden:
                break
            }
            
            appearance.titleTextAttributes = [.foregroundColor : UIColor.tint]
            appearance.largeTitleTextAttributes = [.foregroundColor : UIColor.tint]
            return appearance
        }
    }
    
    static func configureUniversally(titleStyle: UINavigationBar.TitleStyle, appearance: UINavigationBar.DisplayStyle) {
        UINavigationBar.configuration = NavigationBarConfiguration(titleStyle: titleStyle, appearance: appearance)
    }
}
