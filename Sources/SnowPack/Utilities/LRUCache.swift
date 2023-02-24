import Foundation

public class LRUCache<T: Hashable, U> {
    
    /// Total capacity of the LRU cache.
    private(set) var capacity: UInt
    /// LinkedList will store elements that are most accessed at the head and least accessed at the tail.
    private(set) var linkedList = DoublyLinkedList<CachePayload<T, U>>()
    /// Dictionary that will store the element, T, at the specified key.
    private(set) var dictionary = AsyncDictionary<T, Node<CachePayload<T, U>>>()

    /// LRUCache requires a capacity which must be greater than 0
    public required init(capacity: UInt) {
        self.capacity = capacity
    }

    /// Sets the specified value at the specified key in the cache.
    public func setObject(_ value: U, for key: T) {
        let element = CachePayload(key: key, value: value)
        let node = Node(value: element)

        if let existingNode = dictionary[key] {
            // move the existing node to head
            linkedList.moveToHead(node: existingNode)
            linkedList.head?.payload.value = value
            dictionary[key] = node
        } else {
            if linkedList.count == capacity {
                if let leastAccessedKey = linkedList.tail?.payload.key {
                    dictionary[leastAccessedKey] = nil
                }
                linkedList.removeLast()
            }
            linkedList.insert(node: node, at: 0)
            dictionary[key] = node
        }
    }

    /// Returns the element at the specified key. Nil if it doesn't exist.
    public func retrieveObject(for key: T) -> U? {
        guard let existingNode = dictionary[key] else {
            return nil
        }

        linkedList.moveToHead(node: existingNode)
        return existingNode.payload.value
    }
}
