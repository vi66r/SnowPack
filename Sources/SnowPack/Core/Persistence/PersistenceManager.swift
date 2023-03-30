import CoreData
import UIKit

public protocol PersistenceManaging {
    
    associatedtype T: NSManagedObject
    
    func fetch(predicate: NSPredicate?,
               sortDescriptors: [NSSortDescriptor]?,
               limit: Int,
               offset: Int) async throws -> [T]

    func new(configured: @escaping ((T) -> T), saveOnCreation: Bool) throws -> T

    func save() async throws
}

public class PersistenceManager<T: NSManagedObject>: PersistenceManaging {
    
    enum PersistenceManagerError: Error {
        case deinitialized
    }
    
    @Dependency var container: Container
    
    var primaryContext: NSManagedObjectContext? {
        container.primaryContext
    }
    
    var paginated: Bool = false
    
    lazy var backgroundContext: NSManagedObjectContext = { // zoooooweeeeee mama
        let context = container.persistentContainer.newBackgroundContext()
        return context
    }()
    
    public init(paginated: Bool) {
        self.paginated = paginated
    }
    
    public func fetch(predicate: NSPredicate? = nil,
                      sortDescriptors: [NSSortDescriptor]? = nil,
                      limit: Int = 0,
                      offset: Int = 0) async throws -> [T] {
        guard let primaryContext = primaryContext else { throw CoreDataError.noContext }
        return try await withCheckedThrowingContinuation({ continuation in
            primaryContext.perform {
                let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
                fetchRequest.predicate = predicate
                fetchRequest.sortDescriptors = sortDescriptors
                fetchRequest.returnsObjectsAsFaults = false
                if self.paginated {
                    fetchRequest.fetchBatchSize = limit
                    fetchRequest.fetchOffset = offset
                }
                
                do {
                    let results = try primaryContext.fetch(fetchRequest)
                    continuation.resume(returning: results)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        })
    }
    
    public func fetchInBackground(predicate: NSPredicate? = nil,
                                  sortDescriptors: [NSSortDescriptor]? = nil,
                                  limit: Int = 0,
                                  offset: Int = 0) async throws -> [T] {
        
        guard let primaryContext = primaryContext else { throw CoreDataError.noContext }
        let context = backgroundContext
        
        return try await withCheckedThrowingContinuation { [unowned self] continuation in
            context.perform {
                
                let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
                fetchRequest.predicate = predicate
                fetchRequest.sortDescriptors = sortDescriptors
                fetchRequest.returnsObjectsAsFaults = false
                if self.paginated {
                    fetchRequest.fetchBatchSize = limit
                    fetchRequest.fetchOffset = offset
                }
                
                do {
                    let results = try context.fetch(fetchRequest)
                    primaryContext.perform {
                        let mainThreadObjects = results.map { object -> T in
                            let mainThreadObject = primaryContext.object(with: object.objectID) as! T
                            return mainThreadObject
                        }
                        continuation.resume(returning: mainThreadObjects)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func fetch(predicate: NSPredicate? = nil,
                      sortDescriptors: [NSSortDescriptor]? = nil,
                      limit: Int = 0,
                      offset: Int = 0,
                      completion: @escaping (Result<[T], Error>) -> Void) {
        
        guard let primaryContext = primaryContext else {
            completion(.failure(CoreDataError.noContext))
            return
        }
        let context = backgroundContext
        
        context.perform {
            
            let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.returnsObjectsAsFaults = false
            if self.paginated {
                fetchRequest.fetchLimit = limit
                fetchRequest.fetchOffset = offset
            }
            
            do {
                let results = try context.fetch(fetchRequest)
                primaryContext.perform {
                    let mainThreadObjects = results.map { object -> T in
                        let mainThreadObject = primaryContext.object(with: object.objectID) as! T
                        return mainThreadObject
                    }
                    completion(.success(mainThreadObjects))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func new(configured: @escaping ((T) -> T) = { _ in }, saveOnCreation: Bool = true) throws -> T {
        guard let context = primaryContext else { throw CoreDataError.noContext }
        var object = T(context: context)
        object = configured(object)
        if saveOnCreation {
            Task { try? await save() }
        }
        return object
    }
    
    public func save() async throws {
        guard let primaryContext = primaryContext else { throw CoreDataError.noContext }
        
        try await withCheckedThrowingContinuation { continuation in
            primaryContext.perform {
                do {
                    if primaryContext.hasChanges { try primaryContext.save() }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: CoreDataError.saveError(error))
                }
            }
        }
    }
    
    public func delete(object: NSManagedObject) async throws {
        guard let primaryContext = primaryContext else { throw CoreDataError.noContext }
        try object.validateForDelete()
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else { return }
            primaryContext.perform {
                primaryContext.delete(object)
                Task { try await self.save() }
                continuation.resume()
            }
        }
    }
}
