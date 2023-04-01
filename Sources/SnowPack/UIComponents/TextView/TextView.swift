import Combine
import UIKit

open class TextView: UITextView {
    @MainThreaded public var pausedTypingAction = {}
    @MainThreaded public var textChanged = {}
    
    var cancellables = Set<AnyCancellable>()
    public var pauseTime: Int = 1000
    
    public func automaticallyScrollToCursor() {
        let publisher = NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification, object: self)
        publisher
            .sink(receiveValue: { (value) in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.scrollToCursor()
                }
            }).store(in: &cancellables)
    }
    
    public func scrollToCursor() {
        let caret = caretRect(for: selectedTextRange!.start)
        scrollRectToVisible(caret, animated: true)
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
    
    public func observeTextChange() {
        let publisher = NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification, object: self)
        publisher
            .sink(receiveValue: { (value) in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.textChanged()
                }
            }).store(in: &cancellables)
    }
}
