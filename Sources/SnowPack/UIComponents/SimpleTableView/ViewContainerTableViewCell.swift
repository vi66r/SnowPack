import UIKit

public class ViewContainerTableViewCell<T: UIView & Hydratable>: UITableViewCell {

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
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(mainView)
        mainView.edgesToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func hydrate(with model: T.ModelType) {
        mainView.hydrate(with: model)
    }
}
