import UIKit

extension UIViewController {
    func presentAsMediumDetent(
        _ viewController: UIViewController,
        style: DetentedModalContainerController.Style = .light,
        preferredDefaultHeight: CGFloat? = nil,
        preferredMaximumHeight: CGFloat? = nil,
        displayDragIndicator: Bool = true,
        springOnDisplay: Bool = false,
        useAutomaticContentInsets: Bool = true
    ) {
        let presentationContainer = DetentedModalContainerController(
            viewController,
            style,
            preferredDefaultHeight,
            preferredMaximumHeight,
            displayDragIndicator,
            springOnDisplay,
            useAutomaticContentInsets
        )
        presentationContainer.modalPresentationStyle = .overCurrentContext
        self.present(presentationContainer, animated: false)
    }
    
    func dismissMediumDetentIfPresent(_ done: RemoteAction? = nil) {
        guard let presentationContainer = presentedViewController as? DetentedModalContainerController else {
            done?()
            return
        }
        presentationContainer.animateDismissView(done)
    }
}
