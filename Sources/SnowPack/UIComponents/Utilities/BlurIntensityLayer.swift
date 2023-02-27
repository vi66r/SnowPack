import QuartzCore

class BlurIntensityLayer: CALayer {
    
    @NSManaged var intensity: CGFloat
    
    override init(layer: Any) {
        super.init(layer: layer)
        
        if let layer = layer as? BlurIntensityLayer {
            self.intensity = layer.intensity
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        key == #keyPath(intensity) ? true : super.needsDisplay(forKey: key)
    }
    
    override func action(forKey event: String) -> CAAction? {
        guard event == #keyPath(intensity) else {
            return super.action(forKey: event)
        }
        
        let animation = CABasicAnimation(keyPath: event)
        animation.toValue = nil
        animation.fromValue = (self.presentation() ?? self).intensity
        return animation
    }
}
