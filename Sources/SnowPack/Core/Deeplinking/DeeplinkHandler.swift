import Combine
import UIKit

protocol DeepLinkHandling {
    func handle(notification: UNNotification)
    func handle(userInfo: [AnyHashable : Any])
    @discardableResult
    func handle(url: URL) -> Bool
}

final class DeepLinkHandler: DeepLinkHandling {
    private var cancellables = Set<AnyCancellable>()

    @discardableResult
    func handle(userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL
        else { return false }
        return handle(url: url)
    }
    
    func handle(userInfo: [AnyHashable : Any]) {
        guard let data = (userInfo["custom"] as? [String: Any])?["a"] as? [String : String],
              let postId = data["post"]
        else { return }
        
        handle(postID: postId)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func handle(notification: UNNotification) {
        handleInSession(notification: notification)
    }
        
    private func handleInSession(notification: UNNotification) {
        guard let postId = notification.request.content.userInfo["postId"] as? String else {
            return
        }
        handle(postID: postId)
    }
    
    @discardableResult
    func handle(url: URL) -> Bool {
        return handleInSession(url: url)
    }

    private func handleInSession(url: URL) -> Bool {
        // check to see if pointed at post or group
        // handle accordingly
        let targetID = url.lastPathComponent
        let targetTypeURL = url.deletingLastPathComponent()
        let targetType = targetTypeURL.lastPathComponent
        
        print(targetType, targetID)
        
        switch targetType {
        case "post":
            handle(postID: targetID)
        default:
            return false
        }
        return true
    }
    
    func handle(postID: String) {

    }
}
