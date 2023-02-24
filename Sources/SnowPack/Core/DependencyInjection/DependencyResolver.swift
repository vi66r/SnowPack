import Foundation

public protocol DependencyRegistrar {
    func registerPrimaryDependencies()
    func registerSecondaryDependencies()
}

public class DependencyResolver {
    private var dependencies = [String: AnyObject]()
    private static var shared = DependencyResolver()
    
    /*
     Our implementation of the resolve method is inferring the type that should be resolved.
     This means that the var or let cannot have an implied type, but must have an explicit
     type for the compiler to understand what type should be resolved.
     */
    
    public static func register<T>(_ dependency: T) {
        shared.register(dependency)
    }
    
    public static func resolve<T>() -> T {
        shared.resolve()
    }
    
    private func register<T>(_ dependency: T) {
        let key = String(describing: T.self)
        dependencies[key] = dependency as AnyObject
    }
    
    private func resolve<T>() -> T {
        let key = String(describing: T.self)
        let dependency = dependencies[key] as? T
        
        precondition(dependency != nil, "No dependency found for \(key)! must register a dependency before resolve.")
        
        return dependency!
    }
}
