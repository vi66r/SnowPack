@_exported import Combine
@_exported import Nuke
@_exported import NukeExtensions
@_exported import PhoneNumberKit
@_exported import TinyConstraints
@_exported import UIKit

public struct SnowPack {
    public private(set) var text = "Hello, World!"

    public init() {
        print("SnowPack Loaded. ❄️ \nLet's roll. ☃️")
    }
}

public struct SnowPackUI {
    
    static var topSafeAreaMetric: CGFloat? {
        SnowPackUI.currentWindow?.safeAreaInsets.top
    }
    
    static var bottomSafeAreaMetric: CGFloat? {
        SnowPackUI.currentWindow?.safeAreaInsets.bottom
    }
    
    static var mainScreen: UIScreen? {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen
    }
    
    static var currentScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first
    }
    
    static var currentWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow})
            .first
    }
    
    static func interfaceIsDarkMode() -> Bool {
        guard let screen = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen else { return false }
        return screen.traitCollection.userInterfaceStyle == .dark
    }
    
    static var shouldApplyColorSystemUniversally = false
    
    public static func applyColorSystemUniversally() {
        SnowPackUI.shouldApplyColorSystemUniversally = true
        UILabel.appearance(whenContainedInInstancesOf: [UIView.self]).textColor = .textBackground
        UIButton.appearance(whenContainedInInstancesOf: [UIView.self]).setTitleColor(.textBackground, for: .normal)
        UIButton.appearance(whenContainedInInstancesOf: [UIView.self]).tintColor = .tint
        UIImageView.appearance(whenContainedInInstancesOf: [UIView.self]).tintColor = .tint
    }
    
    public static func applyFontSystemUniversally() {
        UILabel.appearance(whenContainedInInstancesOf: [UIView.self]).font = .body
        UIButton.appearance(whenContainedInInstancesOf: [UIView.self]).titleLabel?.font = .body
        UITextField.appearance(whenContainedInInstancesOf: [UIView.self]).font = .body
    }
}
