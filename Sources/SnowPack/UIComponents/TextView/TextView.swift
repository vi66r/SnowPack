import Combine
import UIKit

class TextView: UITextView {
    var pausedTypingAction: RemoteAction?
    
    var cancellables = Set<AnyCancellable>()
    var pauseTime: Int = 1000
    
    
    func observePauseInTyping() {
        let publisher = NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification, object: self)
        publisher
            .map({ ($0.object as! UITextField).text })
            .debounce(for: .milliseconds(pauseTime), scheduler: RunLoop.main)
            .sink(receiveValue: { (value) in
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    self?.pausedTypingAction?()
                }
            }).store(in: &cancellables)
    }
    
}
