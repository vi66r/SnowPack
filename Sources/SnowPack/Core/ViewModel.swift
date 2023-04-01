import Combine
import Shuttle
import UIKit

/// Base class that implements common functionality of all ViewModels
open class ViewModel: Subscribing {
    open var prefersMainThreadExecution: Bool = false
    
    public var cancellables = Set<AnyCancellable>()
    
    @Event<TextableMessage> public var sharingViaMessageEvent
    @Event public var initialLoadEvent
    @Event public var refreshEvent
    @Event<UIViewController> public var navigationEvent
    
    @EventStream(value: false) public var loading
    
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
