import Combine
import UIKit

public protocol Loading {
    var isLoading: CurrentValueSubject<Bool, Never> { get }
    func showBasicLoader(with loadingText: String)
    func hideBasicLoader()
}

public extension Loading where Self: AnyObject {
    
    var defaultWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow})
            .first
    }
    
    func hideBasicLoader() {
        isLoading.value = false
    }
    
    @MainActor
    func showBasicLoader(with loadingText: String) {
        guard let window = defaultWindow else { return }
        
        isLoading.value = true
        
        let basicLoadingView = BasicLoadingView()
        basicLoadingView.loadingText = loadingText
        basicLoadingView.alpha = 0.0
        basicLoadingView.frame = window.bounds
        window.addSubview(basicLoadingView)
        basicLoadingView.layoutSubviews()
        
        basicLoadingView.bind(self)
        
        UIView.animate(withDuration: 0.25) {
            basicLoadingView.alpha = 1.0
        }
        
        basicLoadingView.cleanupLoading = {
            UIView.animate(withDuration: 0.25) {
                basicLoadingView.alpha = 0.0
            } completion: { _ in
                basicLoadingView.removeFromSuperview()
            }
        }
    }
}
