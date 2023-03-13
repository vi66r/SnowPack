import Nuke
import NukeExtensions
import UIKit

public extension UIImageView {
    
    static func loadingImage(from url: URL,
                             placeholder: UIImage? = nil,
                             then: @escaping RemoteTypedAction<UIImage> = { _ in }) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = placeholder
        var options = ImageLoadingOptions()
        options.pipeline = ImagePipeline.shared
        options.transition = .fadeIn(duration: 0.25)
        
        NukeExtensions.loadImage(with: url, options: options, into: imageView) { result in
            if case let .success(imageResponse) = result {
                then(imageResponse.image)
            }
        }
        return imageView
    }
    
    func loadImage(from url: URL,
                   placeholder: UIImage? = nil,
                   then: @escaping RemoteTypedAction<UIImage> = { _ in }) {
        self.image = placeholder
        var options = ImageLoadingOptions()
        options.pipeline = ImagePipeline.shared
        options.transition = .fadeIn(duration: 0.25)
        
        NukeExtensions.loadImage(with: url, options: options, into: self) { result in
            if case let .success(imageResponse) = result {
                then(imageResponse.image)
            }
        }
    }
    
    func fade(to image: UIImage?) {
        UIView.transition(with: self,
                          duration: 0.45,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in self?.image = image },
                          completion: nil)
    }
}
