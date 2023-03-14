import Foundation

public extension Array {
    enum SnowpackArrayError: Error {
        case indexNotFound
        case elementNotFound
    }
    mutating func replace(where predicate:((Element) throws -> Bool), with newElement: Element) throws {
        guard let index = try firstIndex(where: predicate) else { throw SnowpackArrayError.indexNotFound }
        self[index] = newElement
    }
}

public extension Array where Element : AnyObject {
    mutating func replace(_ element: Element, with newElement: Element) throws {
        guard let index = firstIndex(where: { $0 === element }) else { throw SnowpackArrayError.elementNotFound }
        self[index] = newElement
    }
}
