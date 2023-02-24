import UIKit

/// Requires an `identifier` String property, typically used for dequeuing reusable views like UITableViewCell
public protocol ReuseIdentifiable {
    static var identifier: String { get }
}

public extension ReuseIdentifiable where Self: UIView {
    static var identifier: String {
       String(describing: self)
   }
}

extension UITableViewCell: ReuseIdentifiable { }
extension UICollectionReusableView: ReuseIdentifiable { }
extension UITableViewHeaderFooterView: ReuseIdentifiable { }
