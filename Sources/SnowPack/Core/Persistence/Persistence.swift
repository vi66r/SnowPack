import CoreData
import UIKit

public protocol Container {
    var persistentContainer: NSPersistentContainer { get }
    var primaryContext: NSManagedObjectContext? { get }
}

public extension Container {
    var primaryContext: NSManagedObjectContext? {
        persistentContainer.viewContext
    }
}

@propertyWrapper
public struct ManagedRequest<T: NSManagedObject> {
    public let sortDescriptors: [NSSortDescriptor]
    
    public var wrappedValue: NSFetchRequest<T> {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.sortDescriptors = sortDescriptors
        return fetchRequest
    }
    
    public init(sortDescriptors: [NSSortDescriptor] = []) {
        self.sortDescriptors = sortDescriptors
    }
}

@propertyWrapper
public struct Managed<T: NSManagedObject> {
    var context: NSManagedObjectContext
    var sortDescriptors: [NSSortDescriptor]
    
    public var wrappedValue: [T]? {
        @ManagedRequest<T>(sortDescriptors: sortDescriptors) var request
        let results = try? context.fetch(request)
        return results
    }
    
    public init(context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor] = []) {
        self.sortDescriptors = sortDescriptors
        self.context = context
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
