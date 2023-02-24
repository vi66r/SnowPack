import Combine
import Foundation

public protocol Session {
    // what does a session even have? - everything about a current app session
}

public final class SessionImplementation: Session {
    private var cancellables = Set<AnyCancellable>()
}
