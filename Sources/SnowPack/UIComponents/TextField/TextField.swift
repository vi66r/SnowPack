import UIKit

open class TextField: UITextField {
    
    @MainThreaded public var pausedTypingAction = {}
    @MainThreaded public var secondaryPausedTypingAction = {}
    @MainThreaded public var textChanged = {}
    
    var cancellables = Set<AnyCancellable>()
    public var pauseTime: Int = 1000
    public var secondaryPauseTime: Int = 500
    
    public func observePauseInTyping() {
        let publisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
        publisher
            .debounce(for: .milliseconds(pauseTime), scheduler: RunLoop.main)
            .sink(receiveValue: { (value) in
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    self?.pausedTypingAction()
                }
            }).store(in: &cancellables)
    }
    
    public func observeSecondaryPauseInTyping() {
        let publisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
        publisher
            .debounce(for: .milliseconds(secondaryPauseTime), scheduler: RunLoop.main)
            .sink(receiveValue: { (value) in
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    self?.secondaryPausedTypingAction()
                }
            }).store(in: &cancellables)
    }
    
    public func observeTextChange() {
        let publisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
        publisher
            .sink(receiveValue: { (value) in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.textChanged()
                }
            }).store(in: &cancellables)
    }
}
