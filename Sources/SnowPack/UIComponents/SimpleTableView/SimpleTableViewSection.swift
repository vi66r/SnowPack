import UIKit

public struct SimpleTableViewSection<T: UIView & Hydratable> {
    let header: (any UIView & Hydratable)?
    let footer: (any UIView & Hydratable)?
    let elements: [T.ModelType]
    
    init(header: (any UIView & Hydratable)? = nil,
         footer: (any UIView & Hydratable)? = nil,
         elements: [T.ModelType]
    ) {
        self.header = header
        self.footer = footer
        self.elements = elements
    }
}
