import UIKit

public struct SimpleTableViewSection<T: UIView & Hydratable> {
    public var header: (any UIView & Hydratable)?
    public var footer: (any UIView & Hydratable)?
    public var elements: [T.ModelType]
    
    public init(header: (any UIView & Hydratable)? = nil,
         footer: (any UIView & Hydratable)? = nil,
         elements: [T.ModelType]
    ) {
        self.header = header
        self.footer = footer
        self.elements = elements
    }
}
