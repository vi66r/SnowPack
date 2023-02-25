import Nuke
import UIKit

extension UIImage {
    
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
    
}
