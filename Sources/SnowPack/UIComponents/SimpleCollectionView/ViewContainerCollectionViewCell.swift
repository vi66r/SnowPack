import UIKit

public class ViewContainerCollectionViewCell<T: UIView & Hydratable>: UICollectionViewCell {
    
    public var model: T.ModelType? {
        didSet {
            guard let model = model else { return }
            hydrate(with: model)
        }
    }
    
    public lazy var mainView: T = {
        let view = T()
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(mainView)
        mainView.edgesToSuperview(usingSafeArea: false)
    }
    
    public override var isSelected: Bool {
        didSet {
            if var selectableView = mainView as? Selectable {
                selectableView.isSelected = isSelected
            }
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func hydrate(with model: T.ModelType) {
        mainView.tag = tag
        mainView.hydrate(with: model)
    }
}
