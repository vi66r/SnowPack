import UIKit

public extension UIViewController {
    
    func presentOnTop(_ destinationViewController: UIViewController, animated: Bool) {
        if let presentedViewController = presentedViewController {
            presentedViewController.presentOnTop(destinationViewController, animated: animated)
        } else {
            present(destinationViewController, animated: animated)
        }
    }
    
    func addDoneButtonOnKeyboard(title: String = "Done", to textField: UITextField, tapped: @escaping () -> Void = {}) {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(primaryAction: UIAction(title: "Done", handler: { _ in
            textField.resignFirstResponder()
            tapped()
        }))
        
        done.style = .done
        done.tintColor = .gray
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        textField.inputAccessoryView = doneToolbar
    }
    
    func presentAsMediumDetent(
        _ viewController: UIViewController,
        preferredDefaultHeight: CGFloat? = nil,
        preferredMaximumHeight: CGFloat? = nil,
        displayDragIndicator: Bool = true,
        springOnDisplay: Bool = false,
        useAutomaticContentInsets: Bool = true
    ) {
        let presentationContainer = DetentedModalContainerController(
            viewController,
            preferredDefaultHeight,
            preferredMaximumHeight,
            displayDragIndicator,
            springOnDisplay,
            useAutomaticContentInsets
        )
        presentationContainer.modalPresentationStyle = .overCurrentContext
        self.present(presentationContainer, animated: false)
    }
    
    func dismissMediumDetentIfPresent(_ done: Action? = nil) {
        guard let presentationContainer = presentedViewController as? DetentedModalContainerController else {
            done?()
            return
        }
        presentationContainer.animateDismissView(done)
    }
    
    var dismiss: UIAction {
        UIAction { [weak self] action in
            if let parent = self?.parent {
                parent.dismiss(animated: true)
            } else {
                self?.dismiss(animated: true)
            }
        }
    }
}
