import Combine
import UIKit

/// Base class that implements common functionality of all ViewModels
open class ViewModel {
    public let sharingViaMessageEvent = PassthroughSubject<TextableMessage, Never>()
    public let initialLoadEvent = PassthroughSubject<Void, Never>()
    public let refreshEvent = PassthroughSubject<Void, Never>()
    public let navigationEvent = PassthroughSubject<UIViewController, Never>()
    public var cancellables = Set<AnyCancellable>()
    
    public init() {}
    
    public func requestRefresh() {
        refreshEvent.send()
    }
    
    public func requestInitialLoad() {
        initialLoadEvent.send()
    }
    
    public func openWebpage(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let webViewController = SimpleWebViewController(url)
        navigationEvent.send(webViewController)
    }
}
