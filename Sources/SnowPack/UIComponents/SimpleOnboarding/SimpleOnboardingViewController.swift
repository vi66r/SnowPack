import Combine
import UIKit


open class SimpleOnboardingViewController: ViewController {
    
    public var onboardingStages: [ViewController]
    
    lazy var container: LinearFlowViewController = {
        let container = LinearFlowViewController(stages: onboardingStages, axis: .horizontal)
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
    }
}
