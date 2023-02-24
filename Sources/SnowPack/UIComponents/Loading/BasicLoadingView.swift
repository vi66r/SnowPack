import Combine
import UIKit

open final class BasicLoadingView: UIView {
    
    var cleanupLoading: RemoteAction?
    var source: Loading?
    
    public var loadingText = "loading..." {
        didSet {
            loadingLabel.attributedText = NSAttributedString(string: loadingText, attributes: labelAttributes)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black.withAlphaComponent(0.4)
        return view
    }()
    
    private lazy var labelAttributes: [NSAttributedString.Key : Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14.0, weight: .regular),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle]
        return attributes
    }()
    
    private lazy var loadingLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.attributedText = NSAttributedString(string: loadingText, attributes: labelAttributes)
        label.applyDropShadow()
        return label
    }()
    
    public init() {
        super.init(frame: UIScreen.main.bounds)
        addSubview(backgroundView)
        addSubview(loadingLabel)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    func setupConstraints() {
        backgroundView.edgesToSuperview()
        loadingLabel.centerInSuperview()
    }
    
    func bind(_ source: Loading? = nil) {
        guard let source = source else { return }
        self.source = source
        source.isLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: handle(loading:))
            .store(in: &cancellables)
    }
    
    func handle(loading: Bool) {
        guard !loading else { return }
        cancellables.removeAll()
        cleanupLoading?()
    }
}
