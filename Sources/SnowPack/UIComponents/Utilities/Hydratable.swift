import Foundation

public protocol Hydratable {
    associatedtype ModelType
    func hydrate(with model: ModelType)
}
