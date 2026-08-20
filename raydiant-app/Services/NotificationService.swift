import Foundation
import UserNotifications

enum NotificationService {

    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleSunscreenReminder(in minutes: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["sunscreen_reminder"])

        let content = UNMutableNotificationContent()
        content.title = "Reapply time!"
        content.body = "Your SPF window is up. Reapply sunscreen now to keep your skin protected."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutes * 60), repeats: false)
        let request = UNNotificationRequest(identifier: "sunscreen_reminder", content: content, trigger: trigger)

        center.add(request)
    }

    static func cancelSunscreenReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["sunscreen_reminder"])
    }
}
