import Foundation

@propertyWrapper
public struct Dependency<T> {
    public var wrappedValue: T
    public init() {
        wrappedValue = DependencyResolver.resolve()
    }
}
