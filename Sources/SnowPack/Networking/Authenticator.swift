import Combine
import Foundation

open protocol Authenticating {
    var authenticationAvailablePublisher: PassthroughSubject<Bool, Never> { get }
    var bearerToken: String? { get set }
    var refreshToken: String? { get set }
}

open final class Authenticator: Authenticating {
    public let authenticationAvailablePublisher = PassthroughSubject<Bool, Never>()
    public var bearerToken: String? {
        didSet {
            authenticationAvailablePublisher.send(bearerToken != nil)
        }
    }
    public var refreshToken: String?
}
