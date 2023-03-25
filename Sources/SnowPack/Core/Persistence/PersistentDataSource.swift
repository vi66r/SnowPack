import CoreData
import UIKit

public final class PersistentDataSource<T: NSManagedObject> {
    enum PersistentDataSourceError: Error {
        case allResultsLoaded
    }
    
    var pageSize: Int
    
    var offset = 0
    var fetchedAllAvailableRecords = false
    let manager: PersistenceManager<T>
    
    public var data: [T] = []
    
    public init(pageSize: Int, manager: PersistenceManager<T>) {
        self.pageSize = pageSize
        self.manager = manager
    }
    
    public func fetch(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) async throws -> [T] {
        guard !fetchedAllAvailableRecords else { throw PersistentDataSourceError.allResultsLoaded }
        
        return try await withCheckedThrowingContinuation({ continuation in
            manager.fetch(predicate: predicate, sortDescriptors: sortDescriptors, limit: pageSize, offset: offset) { [weak self] result in
                guard let self = self else {
                    continuation.resume(throwing: CoreDataError.noContext)
                    return
                }
                switch result {
                case .success(let success):
                    self.offset += success.count
                    self.data.append(contentsOf: success)
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        })
    }
}
