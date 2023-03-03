import Combine
import UIKit


open class SimpleOnboardingViewController: ViewController {
    
    public var onboardingStages: [ViewController] {
        didSet {
            container.stages = onboardingStages
        }
    }
    
    lazy var container: LinearFlowViewController = {
        let container = LinearFlowViewController(stages: onboardingStages, axis: .horizontal, options: [.spineLocation : UIPageViewController.SpineLocation.min])
        addChild(container)
        return container
    }()
    
    public init(onboardingStages: [ViewController]) {
        self.onboardingStages = onboardingStages
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        addSubview(container.view)
        container.view.edgesToSuperview()
        
        container.flowStateUpdateAction = { [weak self] flowStage in
            guard let flowStage = flowStage else { return }
            self?.handleFlowStage(flowStage)
        }
    }
    
    public func next() {
        container.next()
    }
    
    public func previous() {
        container.previous()
    }
    
    open func handleFlowStage(_ flowStage: LinearFlowViewController.FlowStage) {
        
    }
}
