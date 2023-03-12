import UIKit

public class LocalNotification {
    
    public static func schedule(notification: UNMutableNotificationContent,
                                for date: Date,
                                repeating: Bool = false) async throws {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute],
                                                             from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                    repeats: repeating)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: notification,
                                            trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        try await notificationCenter.add(request)
    }
    
    public static  func schedule(notification: UNMutableNotificationContent,
                                 for dates: [Date],
                                 repeating: Bool = false) async throws {
        
        let dateComponents = dates.map({
            Calendar.current.dateComponents([.hour, .minute], from: $0)
        })
        
        let triggers = dateComponents.map({
            UNCalendarNotificationTrigger(dateMatching: $0, repeats: repeating)
        })
        
        let uuids = triggers.map({ _ in UUID().uuidString })
        
        let requests = (0..<dates.count).map({
            UNNotificationRequest(identifier: uuids[$0],
                                  content: notification,
                                  trigger: triggers[$0])
        })
        
        let notificationCenter = UNUserNotificationCenter.current()
        for request in requests {
            try await notificationCenter.add(request)
        }
    }
    
}

public extension UNMutableNotificationContent {
    func create(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        return content
    }
}
