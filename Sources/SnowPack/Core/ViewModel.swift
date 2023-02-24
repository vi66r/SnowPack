import Combine
import UIKit

/// Base class that implements common functionality of all ViewModels
open class ViewModel {
    @Dependency public var session: Session
    public let initialLoadEvent = PassthroughSubject<Void, Never>()
    public let refreshEvent = PassthroughSubject<Void, Never>()
    public let navigationEvent = PassthroughSubject<UIViewController, Never>()
    public var cancellablse = Set<AnyCancellable>()
    open init()
}
