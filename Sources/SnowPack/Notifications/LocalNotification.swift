import UIKit

public class LocalNotification {
    
    static let allLocalNotificationsKey = "Snowpack.LocalNotification.All"
    
    static var hasPermissions: Bool = false
    
    static func setNotificationIDs(_ ids: [String]) {
        let defaults = UserDefaults.standard
        defaults.set(ids, forKey: allLocalNotificationsKey)
    }
    
    public static func requestNotificationPermission() async throws -> Bool {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await notificationCenter.requestAuthorization(options: options)
    }
    
    // Call this function before scheduling notifications to ensure permission is granted
    public static func checkAndRequestNotificationPermission() async throws {
        let notificationCenter = UNUserNotificationCenter.current()
        let settings = await notificationCenter.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined, .denied:
            LocalNotification.hasPermissions = try await requestNotificationPermission()
        default:
            LocalNotification.hasPermissions = true
        }
    }
    
    public static func clearAll() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    public static func clearAllRegisteredNotifications() {
        let defaults = UserDefaults.standard
        guard let ids = defaults.object(forKey: allLocalNotificationsKey) as? [String] else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    public static func schedule(notification: UNMutableNotificationContent,
                                for date: Date,
                                repeating: Bool = false) async throws {
        if !hasPermissions {
            try await checkAndRequestNotificationPermission()
        }
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
        if !hasPermissions {
            try await checkAndRequestNotificationPermission()
        }
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
        
        setNotificationIDs(uuids)
    }
    
    public static func schedule(notification: UNMutableNotificationContent,
                                for timeFromNow: TimeInterval) async throws {
        if !hasPermissions {
            try await checkAndRequestNotificationPermission()
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeFromNow, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: notification,
                                            trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        try await notificationCenter.add(request)
    }
    
    public static func schedule(notification: UNMutableNotificationContent,
                                every timeInterval: TimeInterval,
                                repeating: Bool = false) async throws {
        if !hasPermissions {
            try await checkAndRequestNotificationPermission()
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeating)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: notification,
                                            trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        try await notificationCenter.add(request)
    }
    
    public static func schedule(notification: UNMutableNotificationContent,
                                every timeInterval: Int,
                                between startingHour: Int,
                                and endingHour: Int,
                                repeating: Bool = false) async throws {
        if !hasPermissions {
            try await checkAndRequestNotificationPermission()
        }
//        let calendar = Calendar.current
        let startHour = startingHour
        let endHour = endingHour
        let intervalMinutes = timeInterval
        
        for hour in stride(from: startHour, to: endHour, by: intervalMinutes / 60) {
            for minute in stride(from: 0, to: 60, by: intervalMinutes % 60) {
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                let identifier = UUID().uuidString
                let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: trigger)
                
                let notificationCenter = UNUserNotificationCenter.current()
                try await notificationCenter.add(request)
            }
        }
    }
    
    public static func scheduleFromNow(notification: UNMutableNotificationContent,
                                       every timeInterval: Int,
                                       between startingHour: Int,
                                       and endingHour: Int,
                                       repeating: Bool = false) async throws {
        if !hasPermissions {
            try await checkAndRequestNotificationPermission()
        }
        let calendar = Calendar.current
        let startHour = startingHour
        let endHour = endingHour
        let intervalMinutes = timeInterval
        
        let now = Date()
        let nowHour = calendar.component(.hour, from: now)
        let nowMinute = calendar.component(.minute, from: now)
        
        if nowHour >= startHour, nowHour < endHour {
            var dateComponents = DateComponents()
            dateComponents.hour = nowHour
            dateComponents.minute = nowMinute
            
            var nextTriggerDate = calendar.nextDate(after: now,
                                                   matching: dateComponents,
                                                   matchingPolicy: .nextTime,
                                                   direction: .forward)!
            
            while calendar.component(.hour, from: nextTriggerDate) >= startHour,
                  calendar.component(.hour, from: nextTriggerDate) < endHour {
                let triggerDateComponents = calendar.dateComponents([.hour, .minute], from: nextTriggerDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: true)
                
                let identifier = UUID().uuidString
                let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: trigger)
                
                let notificationCenter = UNUserNotificationCenter.current()
                try await notificationCenter.add(request)
                
                dateComponents.minute = intervalMinutes
                nextTriggerDate = calendar.date(byAdding: dateComponents, to: nextTriggerDate)!
            }
        } else {
            print("Not scheduling custom notifications, as it is outside the given start and end window.")
        }
    }
}

public extension UNMutableNotificationContent {
    static func create(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        return content
    }
}
