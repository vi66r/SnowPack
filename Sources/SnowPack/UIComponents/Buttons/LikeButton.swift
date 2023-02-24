import UIKit

open final class LikeButton: UIButton {
    
    private static var likedImage: UIImage = UIImage(systemName: "heart.fill")!
    private static var notLikedImage: UIImage = UIImage(systemName: "heart")!
    
    public static func setImages(liked: UIImage, notLiked: UIImage) {
        LikeButton.likedImage = liked
        LikeButton.notLikedImage = notLiked
    }
    
    enum State {
        case liked
        case unliked
        
        var image: UIImage? {
            switch self {
            case .liked:
                return LikeButton.likedImage
            case .unliked:
                return LikeButton.notLikedImage
            }
        }
    }
    
    var likeState: State {
        didSet { setImage(likeState.image, for: .normal) }
    }
    
    public var isLiked: Bool {
        didSet {
            likeState = isLiked ? .liked : .unliked
        }
    }
    
    public init(isLiked: Bool = false) {
        self.isLiked = isLiked
        self.likeState = isLiked ? .liked : .unliked
        super.init(frame: .zero)
        
        setImage(likeState.image, for: .normal)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
