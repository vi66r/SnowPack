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

@propertyWrapper
public struct UIThreaded {
    var action: RemoteAction?
    
    public var wrappedValue: RemoteAction {
        get {{
            DispatchQueue.main.async { action?() }
        }}
        set { action = newValue }
    }
    
    public init(wrappedValue: @escaping RemoteAction) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
public struct Delayed {
    
    var action: RemoteAction?
    var milliseconds: Int
    
    public var wrappedValue: RemoteAction {
        get {{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds), execute: {
                action?()
            })
        }}
        set { action = newValue }
    }
    
    public init(wrappedValue: @escaping RemoteAction, _ delay: Int) {
        milliseconds = delay
        self.wrappedValue = wrappedValue
    }
    
}
