import CoreData
import UIKit

public enum CoreDataError: Error {
    case noContext
    case saveError(Error)
}

public protocol Container {
    var persistentContainer: NSPersistentContainer { get }
    var primaryContext: NSManagedObjectContext? { get }
    func save(context: NSManagedObjectContext?) throws
}

public extension Container {
    var primaryContext: NSManagedObjectContext? {
        persistentContainer.viewContext
    }
    
    func save(context: NSManagedObjectContext? = nil) throws {
        let context = context ?? primaryContext
        guard let context = context else { throw CoreDataError.noContext }
        if context.hasChanges {
            try context.save()
        }
    }
}

@propertyWrapper
public struct ManagedRequest<T: NSManagedObject> {
    public let sortDescriptors: [NSSortDescriptor]?
    public let searchPredicate: NSPredicate?
    public let limit: Int?
    public let offset: Int?
    public let returnAsFaults: Bool
    
    public var wrappedValue: NSFetchRequest<T> {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = searchPredicate
        if let limit = limit, let offset = offset {
            fetchRequest.fetchBatchSize = limit
            fetchRequest.fetchOffset = offset
        }
        fetchRequest.returnsObjectsAsFaults = returnAsFaults
        return fetchRequest
    }
    
    public init(sortDescriptors: [NSSortDescriptor]? = nil,
                predicate: NSPredicate? = nil,
                limit: Int? = nil,
                offset: Int? = nil,
                returnAsFaults: Bool = false) {
        self.sortDescriptors = sortDescriptors
        self.searchPredicate = predicate
        self.limit = limit
        self.offset = offset
        self.returnAsFaults = returnAsFaults
    }
}

@propertyWrapper
public struct Managed<T: NSManagedObject> {
    var context: NSManagedObjectContext
    var sortDescriptors: [NSSortDescriptor]
    var searchPredicate: NSPredicate?
    
    public var wrappedValue: [T]? {
        @ManagedRequest<T>(sortDescriptors: sortDescriptors, predicate: searchPredicate) var request
        let results = try? context.fetch(request)
        return results
    }
    
    public init(context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor] = [], searchPredicate: NSPredicate? = nil) {
        self.sortDescriptors = sortDescriptors
        self.searchPredicate = searchPredicate
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

//class Persistence: NSPersistentContainer {
//    func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
//        let context = backgroundContext ?? viewContext
//        guard context.hasChanges else { return }
//        do {
//            try context.save()
//        } catch let error as NSError {
//            print("Error: \(error), \(error.userInfo)")
//        }
//    }
//}
