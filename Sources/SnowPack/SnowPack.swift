@_exported import Nuke
@_exported import NukeExtensions
@_exported import TinyConstraints
@_exported import UIKit

public struct SnowPack {
    public private(set) var text = "Hello, World!"

    public init() {
        print("SnowPack Loaded. ❄️ \nLet's roll. ☃️")
    }
}

public struct SnowPackUI {
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
}
