@_exported import Nuke
@_exported import NukeExtensions
@_exported import TinyConstraints
@_exported import UIKit

public struct SnowPack {
    public private(set) var text = "Hello, World!"

    public init() {
        print("SnowPack Loaded. ❄️ \nLet's roll. ☃️")
    }
    
    static func interfaceIsDarkMode() -> Bool {
        guard let window = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow})
            .first
        else { return false }
        
        return window.traitCollection.userInterfaceStyle == .dark
    }
    
    static func applyColorSystemUniversally() {
        UILabel.appearance(whenContainedInInstancesOf: [UIView.self]).textColor = .textBrand
        UIButton.appearance(whenContainedInInstancesOf: [UIView.self]).setTitleColor(.textBrand, for: .normal)
        UINavigationBar.appearance(whenContainedInInstancesOf: [UIView.self]).backgroundColor = .brand
        UINavigationBar.appearance(whenContainedInInstancesOf: [UIView.self]).titleTextAttributes = [.foregroundColor : UIColor.textBrand]
    }
}
