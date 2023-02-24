import UIKit

public struct SimpleTableViewSection<T: UIView & Hydratable> {
    public let header: (any UIView & Hydratable)?
    public let footer: (any UIView & Hydratable)?
    public let elements: [T.ModelType]
    
    public init(header: (any UIView & Hydratable)? = nil,
         footer: (any UIView & Hydratable)? = nil,
         elements: [T.ModelType]
    ) {
        self.header = header
        self.footer = footer
        self.elements = elements
    }
}
