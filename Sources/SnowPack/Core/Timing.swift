import Combine
import UIKit

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

public func delayed(by milliseconds: Int, perform: @escaping RemoteAction) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds), execute: {
        perform()
    })
}

public func repeatedlyPerform(_ action: @escaping RemoteAction,
                              every delay: Int,
                              until predicate: @escaping (() -> Bool) = { false }) {
    Timer.scheduledTimer(withTimeInterval: TimeInterval(delay), repeats: true) { timer in
        action()
        if predicate() { timer.invalidate() }
    }
}
