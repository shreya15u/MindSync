//
//  NotificationService.swift
//  MindSync
//

import Foundation
import UserNotifications

enum NotificationService {
    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }
    
    static func scheduleUrgentReminder(everyHours: Int) {
        guard everyHours > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Urgent Task Reminder"
        content.body = "You have urgent work to complete today."
        content.sound = .default
        
        let interval = TimeInterval(everyHours * 3600)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let request = UNNotificationRequest(identifier: "urgent_hourly", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    static func scheduleLongTermReminder(taskId: UUID, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "Time to follow up on your saved task."
        content.sound = .default
        content.userInfo = ["taskId": taskId.uuidString]
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        let request = UNNotificationRequest(identifier: "task_\(taskId.uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    static func cancelUrgentReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["urgent_hourly"])
    }
    
    static func cancelTaskReminder(taskId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["task_\(taskId.uuidString)"])
    }
}
