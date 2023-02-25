import Nuke
import NukeExtensions
import UIKit

public extension UIImageView {
    
    static func loadingImage(from url: URL) -> UIImageView {
        let imageView = UIImageView()
        var options = ImageLoadingOptions()
        options.pipeline = ImagePipeline.shared
        options.transition = .fadeIn(duration: 0.25)
        
        NukeExtensions.loadImage(with: url, options: options, into: imageView)
        return imageView
    }
    
    func loadImage(from url: URL) {
        var options = ImageLoadingOptions()
        options.pipeline = ImagePipeline.shared
        options.transition = .fadeIn(duration: 0.25)
        
        NukeExtensions.loadImage(with: url, options: options, into: self)
    }
    
}
