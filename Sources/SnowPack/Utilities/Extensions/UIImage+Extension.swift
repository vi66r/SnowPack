import Nuke
import UIKit

public extension UIImage {
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    static func colored(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        UIImage(color: color, size: size)
    }
    
    static func load(from url: URL,
                     processors: [ImageProcessing] = [],
                     priority: ImageRequest.Priority = .high,
                     options: ImageRequest.Options = []
    ) async throws -> UIImage {
        let pipeline = ImagePipeline.shared
        let request = ImageRequest(url: url, processors: processors, priority: priority, options: options)
        let response = try await pipeline.image(for: request)
        return response.image
    }
    
    var base64Representation: String? {
        self.jpegData(compressionQuality: 1.0)?.base64EncodedString()
    }
    
    static func fromBase64(_ string: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: string),
              let image = UIImage(data: imageData)
        else { return nil }
        return image
    }
    
    func save(with id: String) {
        guard let base64 = base64Representation else { return }
        UserDefaults.standard.set(base64, forKey: "snowpack.savedimage."+id)
    }
    
    static func from(savedId: String) -> UIImage? {
        guard let base64 = UserDefaults.standard.string(forKey: "snowpack.savedimage"+savedId),
              let image = fromBase64(base64)
        else { return nil }
        return image
    }
    
    func imageByScalingAndCroppingForSizeAtCenter(targetSize: CGSize) -> UIImage? {
        let widthFactor = targetSize.width / size.width
        let heightFactor = targetSize.height / size.height

        let scaleFactor = max(widthFactor, heightFactor)

        let scaledWidth = size.width * scaleFactor
        let scaledHeight = size.height * scaleFactor
        let scaledSize = CGSize(width: scaledWidth, height: scaledHeight)

        let originX = (targetSize.width - scaledWidth) / 2
        let originY = (targetSize.height - scaledHeight) / 2
        let thumbnailPoint = CGPoint(x: originX, y: originY)

        let thumbnailRect = CGRect(origin: thumbnailPoint, size: scaledSize)

        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)

        draw(in: thumbnailRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return newImage
    }
    
    func imageByScalingAndCroppingForSize(targetSize: CGSize) -> UIImage? {
        let widthFactor = targetSize.width / size.width
        let heightFactor = targetSize.height / size.height

        let scaleFactor = max(widthFactor, heightFactor)

        let scaledWidth = size.width * scaleFactor
        let scaledHeight = size.height * scaleFactor
        let scaledSize = CGSize(width: scaledWidth, height: scaledHeight)

        let thumbnailPoint = CGPoint(x: 0, y: 0)

        let thumbnailRect = CGRect(origin: thumbnailPoint, size: scaledSize)

        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)

        draw(in: thumbnailRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return newImage
    }
}
