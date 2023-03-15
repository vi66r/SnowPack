import Combine
import UIKit

@propertyWrapper
public struct MainThreaded {
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

// dunno if this actually works
@propertyWrapper
public struct TaskWrapped {
    var action: RemoteAction?
    
    public var wrappedValue: RemoteAction {
        get {{
            Task { action?() }
        }}
        set { action = newValue }
    }
    
    public init(wrappedValue: @escaping RemoteAction) {
        self.wrappedValue = wrappedValue
    }
}
