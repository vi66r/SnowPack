import Nuke
import UIKit

public extension UIImage {
    
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
    
    func fromBase64(_ string: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: string),
              let image = UIImage(data: imageData)
        else { return nil }
        return image
    }
}
