import Combine
import UIKit

open class TextView: UITextView {
    public var pausedTypingAction: RemoteAction?
    
    var cancellables = Set<AnyCancellable>()
    public var pauseTime: Int = 1000
    
    public func observePauseInTyping() {
        let publisher = NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification, object: self)
        publisher
            .debounce(for: .milliseconds(pauseTime), scheduler: RunLoop.main)
            .sink(receiveValue: { (value) in
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    self?.pausedTypingAction?()
                }
            }).store(in: &cancellables)
    }
}
