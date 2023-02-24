import UIKit

public protocol Haptic {
    func softImpact()
    func mediumImpact()
    func heavyImpact()
    func doubleImpact(_ after: RemoteAction?)
    func errorImpact()
}

public extension Haptic where Self: AnyObject {
    func softImpact() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    func mediumImpact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func heavyImpact() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    func doubleImpact(_ after: RemoteAction? = nil) {
        mediumImpact()
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.075, execute: { [weak self] in
            self?.heavyImpact()
            after?()
        })
    }
    
    func errorImpact() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    func tripleImpact(_ after: RemoteAction? = nil) {
        heavyImpact()
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.085, execute: { [weak self] in
            self?.mediumImpact()
        })
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.17, execute: { [weak self] in
            self?.softImpact()
            after?()
        })
    }
}
