import Foundation
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleWaterReminder(plantName: String, intervalHours: Int = 4) {
        let content = UNMutableNotificationContent()
        content.title = "\(plantName)渴了"
        content.body = "快来给\(plantName)浇水吧！水分不足了。"
        content.sound = .default
        content.categoryIdentifier = "PLANT_CARE"

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(intervalHours * 3600),
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "water_reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleLightReminder(plantName: String) {
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "早晨的阳光"
        content.body = "别忘了给\(plantName)一些光照哦！"
        content.sound = .default
        content.categoryIdentifier = "PLANT_CARE"

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "light_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleSicknessAlert(plantName: String) {
        let content = UNMutableNotificationContent()
        content.title = "\(plantName)生病了"
        content.body = "\(plantName)看起来不太好，快来治疗吧！"
        content.sound = .default
        content.categoryIdentifier = "PLANT_CARE"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false)
        let request = UNNotificationRequest(identifier: "sickness_alert", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleHabitReminder(taskTitle: String, hour: Int, minute: Int) {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "习惯提醒"
        content.body = "今天「\(taskTitle)」完成了吗？完成可以获得养分哦！"
        content.sound = .default
        content.categoryIdentifier = "HABIT_REMINDER"

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "habit_\(taskTitle)_reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func sendEvolutionCelebration(plantName: String, newStage: String) {
        let content = UNMutableNotificationContent()
        content.title = "\(plantName)进化了！"
        content.body = "\(plantName)成长到了「\(newStage)」阶段！快来看看吧！"
        content.sound = .default
        content.categoryIdentifier = "EVOLUTION"

        let request = UNNotificationRequest(identifier: "evolution_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    func sendSpriteEvolutionCelebration(spriteName: String, newLevel: Int) {
        let content = UNMutableNotificationContent()
        content.title = "\(spriteName)升级了！"
        content.body = "\(spriteName)进化到了等级\(newLevel)！快来看看新模样！"
        content.sound = .default
        content.categoryIdentifier = "SPRITE_EVOLUTION"

        let request = UNNotificationRequest(identifier: "sprite_evolution_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func cancelReminder(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}