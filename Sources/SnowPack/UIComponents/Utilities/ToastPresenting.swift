import Shuttle
import UIKit

protocol ToastPresenting {
    func presentToast(_ toast: Toast)
}

extension ToastPresenting where Self: UIViewController {
    
    func presentToast(_ toast: Toast) {
        
        var safeAreaHeight: CGFloat
        switch toast.position {
        case .top:
            safeAreaHeight = UIDevice.current.safeAreaInsets.top
        case .bottom:
            safeAreaHeight = UIDevice.current.safeAreaInsets.bottom
        }
        
        let totalPredictedHeight = safeAreaHeight + toast.estimatedContentHeight + 8.0
        
        var frame: CGRect
        switch toast.position {
        case .top:
            frame = .init(x: 0,
                          y: -totalPredictedHeight,
                          width: view.bounds.width,
                          height: totalPredictedHeight)
        case .bottom:
            frame = .init(x: 0,
                          y: view.bounds.height + totalPredictedHeight,
                          width: view.bounds.width,
                          height: totalPredictedHeight)
        }
        toast.frame = frame
        toast.requestDismissalAction = {
            dismissToast()
        }
        if toast.cornerStyle == .rounded {
            toast.applyRoundedCorners(totalPredictedHeight < 50 ? totalPredictedHeight/2.0 : 25.0, curve: .continuous)
        }
        view.addSubview(toast)
        
        
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            switch toast.position {
            case .top:
                toast.transform = CGAffineTransformMakeTranslation(0, toast.bounds.height)
            case .bottom:
                toast.transform = CGAffineTransformMakeTranslation(0, -toast.bounds.height)
            }
        })
        
        switch toast.kind {
        case .ephemeral(let duration):
            @Delayed(duration + 300) var dismissal = { // duration + animation duration
                dismissToast()
            }
            dismissal()
        case .persistent:
            break
        }
        
        
        func dismissToast() {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                toast.transform = .identity
            }, completion: { done in
                toast.removeFromSuperview()
            })
        }
    }
    
}
