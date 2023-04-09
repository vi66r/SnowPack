import Nuke
import NukeExtensions
import UIKit

public class ViewContainerCollectionReusableView<T: UIView & Hydratable>: UICollectionReusableView {

    public var model: T.ModelType? {
        didSet {
            guard let model = model else { return }
            hydrate(with: model)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mainView)
        mainView.edgesToSuperview()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("nope try again")
    }
    
    public lazy var mainView: T = {
        let view = T()
        return view
    }()
    
    public func hydrate(with model: T.ModelType) {
        mainView.hydrate(with: model)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        let imageViews = mainView.allSubviews.compactMap { view in
            if let view = view as? UIImageView {
                return view
            }
            return nil
        }
        imageViews.forEach({
            NukeExtensions.cancelRequest(for: $0)
        })
    }
}
