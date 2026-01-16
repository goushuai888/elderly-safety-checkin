//
//  DataManager.swift
//  死了么
//
//  Created by shuai on 2026/1/16.
//

import Foundation
import Combine
import UserNotifications

class DataManager: ObservableObject {
    static let shared = DataManager()

    // 发布的数据属性
    @Published var elderly: [Elderly] = []
    @Published var contacts: [EmergencyContact] = []
    @Published var checkIns: [CheckInRecord] = []
    @Published var notifications: [NotificationRecord] = []
    @Published var locationShares: [LocationShareRecord] = []

    private init() {
        loadData()
        requestNotificationPermission()
    }

    // MARK: - 数据持久化

    private func loadData() {
        if let elderlyData = UserDefaults.standard.data(forKey: "elderly"),
           let decoded = try? JSONDecoder().decode([Elderly].self, from: elderlyData) {
            elderly = decoded
        }

        if let contactsData = UserDefaults.standard.data(forKey: "contacts"),
           let decoded = try? JSONDecoder().decode([EmergencyContact].self, from: contactsData) {
            contacts = decoded
        }

        if let checkInsData = UserDefaults.standard.data(forKey: "checkIns"),
           let decoded = try? JSONDecoder().decode([CheckInRecord].self, from: checkInsData) {
            checkIns = decoded
        }

        if let notificationsData = UserDefaults.standard.data(forKey: "notifications"),
           let decoded = try? JSONDecoder().decode([NotificationRecord].self, from: notificationsData) {
            notifications = decoded
        }

        if let locationSharesData = UserDefaults.standard.data(forKey: "locationShares"),
           let decoded = try? JSONDecoder().decode([LocationShareRecord].self, from: locationSharesData) {
            locationShares = decoded
        }
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(elderly) {
            UserDefaults.standard.set(encoded, forKey: "elderly")
        }

        if let encoded = try? JSONEncoder().encode(contacts) {
            UserDefaults.standard.set(encoded, forKey: "contacts")
        }

        if let encoded = try? JSONEncoder().encode(checkIns) {
            UserDefaults.standard.set(encoded, forKey: "checkIns")
        }

        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: "notifications")
        }

        if let encoded = try? JSONEncoder().encode(locationShares) {
            UserDefaults.standard.set(encoded, forKey: "locationShares")
        }
    }

    // MARK: - 老人管理

    func addElderly(_ person: Elderly) {
        elderly.append(person)
        saveData()
        scheduleCheckNotification(for: person)
    }

    func updateElderly(_ person: Elderly) {
        if let index = elderly.firstIndex(where: { $0.id == person.id }) {
            elderly[index] = person
            saveData()
            scheduleCheckNotification(for: person)
        }
    }

    func deleteElderly(_ person: Elderly) {
        elderly.removeAll { $0.id == person.id }
        contacts.removeAll { $0.elderlyId == person.id }
        checkIns.removeAll { $0.elderlyId == person.id }
        locationShares.removeAll { $0.elderlyId == person.id }
        saveData()
        cancelNotifications(for: person.id)
    }

    // MARK: - 紧急联系人管理

    func addContact(_ contact: EmergencyContact) {
        contacts.append(contact)
        saveData()
    }

    func updateContact(_ contact: EmergencyContact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
            saveData()
        }
    }

    func deleteContact(_ contact: EmergencyContact) {
        contacts.removeAll { $0.id == contact.id }
        saveData()
    }

    func getContacts(for elderlyId: UUID) -> [EmergencyContact] {
        return contacts.filter { $0.elderlyId == elderlyId }
    }

    // MARK: - 签到管理

    func checkIn(for elderlyId: UUID, note: String = "", latitude: Double? = nil, longitude: Double? = nil) {
        let today = todayDateString()

        // 检查今天是否已经签到
        if checkIns.contains(where: { $0.elderlyId == elderlyId && $0.dateString == today }) {
            return
        }

        let record = CheckInRecord(
            elderlyId: elderlyId,
            note: note,
            latitude: latitude,
            longitude: longitude
        )
        checkIns.append(record)
        saveData()

        // 取消今天的提醒通知
        cancelTodayNotification(for: elderlyId)
    }

    func hasCheckedInToday(elderlyId: UUID) -> Bool {
        let today = todayDateString()
        return checkIns.contains(where: { $0.elderlyId == elderlyId && $0.dateString == today })
    }

    func getCheckInHistory(for elderlyId: UUID, limit: Int = 30) -> [CheckInRecord] {
        return checkIns
            .filter { $0.elderlyId == elderlyId }
            .sorted { $0.checkInTime > $1.checkInTime }
            .prefix(limit)
            .map { $0 }
    }

    func getCheckInStats(for elderlyId: UUID) -> (total: Int, last7Days: Int, last30Days: Int) {
        let allCheckins = checkIns.filter { $0.elderlyId == elderlyId }
        let total = allCheckins.count

        let calendar = Calendar.current
        let now = Date()

        let last7Days = allCheckins.filter {
            calendar.dateComponents([.day], from: $0.checkInTime, to: now).day ?? 999 <= 7
        }.count

        let last30Days = allCheckins.filter {
            calendar.dateComponents([.day], from: $0.checkInTime, to: now).day ?? 999 <= 30
        }.count

        return (total, last7Days, last30Days)
    }

    // MARK: - 通知管理

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限已授予")
            } else if let error = error {
                print("请求通知权限失败: \(error.localizedDescription)")
            }
        }
    }

    func scheduleCheckNotification(for person: Elderly) {
        // 先取消旧的通知
        cancelNotifications(for: person.id)

        // 解析检查时间
        let timeComponents = person.checkTime.split(separator: ":").map { Int($0) ?? 0 }
        guard timeComponents.count == 2 else { return }

        var dateComponents = DateComponents()
        dateComponents.hour = timeComponents[0]
        dateComponents.minute = timeComponents[1]

        let content = UNMutableNotificationContent()
        content.title = "签到提醒"
        content.body = "请提醒 \(person.name) 进行今日签到"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "check-\(person.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加通知失败: \(error.localizedDescription)")
            }
        }
    }

    private func cancelNotifications(for elderlyId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["check-\(elderlyId.uuidString)"]
        )
    }

    private func cancelTodayNotification(for elderlyId: UUID) {
        // 实际应用中可以更精细地控制通知
        // 这里简化处理，签到后不取消，让用户每天都能收到提醒
    }

    // MARK: - 工具方法

    private func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
