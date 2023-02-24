import UIKit

public struct Route: RawRepresentable, Equatable {
    public typealias RawValue = String
    public var rawValue: String
    
    public var shouldPresentModally: Bool = false
    public var attachments: [String: AnyObject]?
    
    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public init?(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}
