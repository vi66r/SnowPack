import Nuke
import NukeExtensions
import UIKit

public extension UIImageView {
    
    static func loadingImage(from url: URL, placeholder: UIImage? = nil) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = placeholder
        var options = ImageLoadingOptions()
        options.pipeline = ImagePipeline.shared
        options.transition = .fadeIn(duration: 0.25)
        
        NukeExtensions.loadImage(with: url, options: options, into: imageView)
        return imageView
    }
    
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        self.image = placeholder
        var options = ImageLoadingOptions()
        options.pipeline = ImagePipeline.shared
        options.transition = .fadeIn(duration: 0.25)
        
        NukeExtensions.loadImage(with: url, options: options, into: self)
    }
    
}
