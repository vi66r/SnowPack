import CoreData
import UIKit

protocol PersistenceRegisgtrar {
    var persistentContainer: NSPersistentContainer { get }
    var primaryContext: NSManagedObjectContext? { get }
}

extension PersistenceRegisgtrar {
    
    var primaryContext: NSManagedObjectContext? {
        persistentContainer.viewContext
    }
    
}

@propertyWrapper
public struct Managed<T: NSManagedObject> {
    public var wrappedValue: T?
    
    public init() {
        wrappedValue = nil
    }
    
    public var request: NSFetchRequest<NSFetchRequestResult> {
        T.fetchRequest()
    }
}

@propertyWrapper
public struct ImageConvertible {
    var _data: Data?
    public var wrappedValue: UIImage? {
        guard let data = _data else { return nil }
        return UIImage(data: data)
    }
    
    public init(_ data: Data? = nil) {
        _data = data
    }
}

protocol Persisting {
    
}

class Persistence: NSPersistentContainer {
    func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
        let context = backgroundContext ?? viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }
}
