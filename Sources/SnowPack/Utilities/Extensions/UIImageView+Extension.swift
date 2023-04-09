import Nuke
import NukeExtensions
import UIKit

public extension UIImageView {
    
    static func loadingImage(from url: URL,
                             placeholder: UIImage? = nil,
                             then: @escaping TypedAction<UIImage> = { _ in }) -> UIImageView {
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
                   then: @escaping TypedAction<UIImage> = { _ in }) {
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
    
    func cancelImageLoad() {
        NukeExtensions.cancelRequest(for: self)
    }
    
    func fade(to image: UIImage?) {
        UIView.transition(with: self,
                          duration: 0.45,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in self?.image = image },
                          completion: nil)
    }
    
    func blur(with percentage: CGFloat,
              usingSnapshot: Bool = true,
              and: @escaping TypedAction<UIImageView> = { _ in }) {
        guard let image = usingSnapshot ? self.snapshot : self.image,
        let ciImage = CIImage(image: image)
        else { return }
        
        // a radius of 10 produces a good value for this size 525 × 810 pixels
        // so let's do some math
        
        // let's start by taking the square root of the edges squared added
        let normalizedArea = sqrt((ciImage.extent.width**2) + (ciImage.extent.height**2))
        let radius = percentage/1000 * normalizedArea
        
        
        // Added "CIAffineClamp" filter
        let affineClampFilter = CIFilter(name: "CIAffineClamp")!
        affineClampFilter.setDefaults()
        affineClampFilter.setValue(ciImage, forKey: kCIInputImageKey)
        let resultClamp = affineClampFilter.value(forKey: kCIOutputImageKey)

        // resultClamp is used as input for "CIGaussianBlur" filter
        let filter: CIFilter = CIFilter(name:"CIGaussianBlur")!
        filter.setDefaults()
        filter.setValue(resultClamp, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)

        let ciContext = CIContext(options: nil)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? CIImage,
              let cgImage = ciContext.createCGImage(result, from: ciImage.extent)
        else { return }

        let blurredImage = UIImage(cgImage: cgImage)
        
        let subImageView = UIImageView(image: blurredImage)
        subImageView.contentMode = contentMode
        subImageView.accessibilityIdentifier = "Snowpack.Overlay.ImageBlur"
        and(subImageView)
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
