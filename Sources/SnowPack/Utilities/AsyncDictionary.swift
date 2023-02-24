import Foundation

public class AsyncDictionary<M: Hashable,N>: Collection {

    private var dictionary: [M: N]
    private let concurrentQueue = DispatchQueue(label: "obamna",
                                                attributes: .concurrent)
    public var startIndex: Dictionary<M, N>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.startIndex
        }
    }

    public var endIndex: Dictionary<M, N>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.endIndex
        }
    }

    public init(dict: [M: N] = [M:N]()) {
        self.dictionary = dict
    }
    // this is because it is an apple protocol method
    // swiftlint:disable identifier_name
    public func index(after i: Dictionary<M, N>.Index) -> Dictionary<M, N>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.index(after: i)
        }
    }
    // swiftlint:enable identifier_name
    public subscript(key: M) -> N? {
        set(newValue) {
            self.concurrentQueue.async(flags: .barrier) {[weak self] in
                self?.dictionary[key] = newValue
            }
        }
        get {
            self.concurrentQueue.sync {
                return self.dictionary[key]
            }
        }
    }

    // has implicity get
    public subscript(index: Dictionary<M, N>.Index) -> Dictionary<M, N>.Element {
        self.concurrentQueue.sync {
            return self.dictionary[index]
        }
    }
    
    public func removeValue(forKey key: M) {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }

    public func removeAll() {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeAll()
        }
    }

}
