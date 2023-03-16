import CoreData
import UIKit

@propertyWrapper
public struct ImageConvertible {
    public var wrappedValue: UIImage?
    
    public init(_ data: Data) {
        self.wrappedValue = UIImage(data: data)
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
