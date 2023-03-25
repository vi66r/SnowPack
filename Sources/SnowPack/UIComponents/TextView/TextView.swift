import Combine
import UIKit

open class TextView: UITextView {
    @MainThreaded public var pausedTypingAction = {}
    
    var cancellables = Set<AnyCancellable>()
    public var pauseTime: Int = 1000
    
    public func automaticallyScrollToCursor() {
        let publisher = NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification, object: self)
        publisher
            .sink(receiveValue: { (value) in
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    guard let self = self else { return }
                    let caret = self.caretRect(for: self.selectedTextRange!.start)
                    self.scrollRectToVisible(caret, animated: true)
                }
            }).store(in: &cancellables)
    }
    
    public func observePauseInTyping() {
        let publisher = NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification, object: self)
        publisher
            .debounce(for: .milliseconds(pauseTime), scheduler: RunLoop.main)
            .sink(receiveValue: { (value) in
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    self?.pausedTypingAction()
                }
            }).store(in: &cancellables)
    }
}
