import Combine
import Foundation
import UIKit

@propertyWrapper
public struct Event<T> {
    public var wrappedValue: PassthroughSubject<T, Never>
    public init() { wrappedValue = PassthroughSubject<T, Never>() }
}

extension Event where T == Void {
    init() { wrappedValue = PassthroughSubject<Void, Never>() }
}

@propertyWrapper
public struct StreamingEvent<T> {
    public var wrappedValue: CurrentValueSubject<T, Never>
    public init(value: T) { wrappedValue = CurrentValueSubject<T, Never>(value) }
}
