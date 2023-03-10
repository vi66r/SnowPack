import Combine
import UIKit

/// Base class that implements common functionality of all ViewModels
open class ViewModel {
    public let initialLoadEvent = PassthroughSubject<Void, Never>()
    public let refreshEvent = PassthroughSubject<Void, Never>()
    public let navigationEvent = PassthroughSubject<UIViewController, Never>()
    public var cancellablse = Set<AnyCancellable>()
    public init() {}
    
    public func requestRefresh() {
        refreshEvent.send()
    }
    
    public func requestInitialLoad() {
        initialLoadEvent.send()
    }
}
