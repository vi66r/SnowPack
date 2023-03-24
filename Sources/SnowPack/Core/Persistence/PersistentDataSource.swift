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
    
    private(set) var data: [T] = []
    
    public init(pageSize: Int, manager: PersistenceManager<T>) {
        self.pageSize = pageSize
        self.manager = manager
    }
    
    public func fetch(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) async throws -> [T] {
        guard fetchedAllAvailableRecords else { throw PersistentDataSourceError.allResultsLoaded }
        let results = try await manager.fetch(predicate: predicate, sortDescriptors: sortDescriptors, limit: pageSize, offset: offset)
        if results.count < pageSize { fetchedAllAvailableRecords = true }
        offset += results.count
        data.append(contentsOf: results)
        return results
    }
}
