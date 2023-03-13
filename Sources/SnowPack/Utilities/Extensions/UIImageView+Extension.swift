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
    
    func blur(with radius: CGFloat, usingSnapshot: Bool = true) {
        guard var image = usingSnapshot ? self.snapshot : self.image,
        let ciImage = CIImage(image: image)
        else { return }
        let blurredImage = UIImage(ciImage: ciImage.applyingGaussianBlur(sigma: radius).cropped(to: ciImage.extent))
        let subImageView = UIImageView(image: blurredImage)
        subImageView.accessibilityIdentifier = "Snowpack.Overlay.ImageBlur"
        addSubview(subImageView)
        subImageView.edgesToSuperview()
    }
    
    func unblur() {
        guard let blurredImage = subviews.first(where: {
            $0.accessibilityIdentifier == "Snowpack.Overlay.ImageBlur"
        }) else { return }
        blurredImage.removeFromSuperview()
    }
}
