//
//  Models.swift
//  死了么
//
//  Created by shuai on 2026/1/16.
//

import Foundation

// 老人信息模型
struct Elderly: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var phone: String
    var address: String
    var homeLatitude: Double? // 家庭住址纬度
    var homeLongitude: Double? // 家庭住址经度
    var checkTime: String = "20:00" // 每日检查时间 格式: "HH:mm"
    var createdAt: Date = Date()

    // 是否有家庭位置信息
    var hasHomeLocation: Bool {
        homeLatitude != nil && homeLongitude != nil
    }
}

// 紧急联系人模型
struct EmergencyContact: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var elderlyId: UUID
    var name: String
    var phone: String
    var email: String = ""
    var relationship: String // 关系：儿子、女儿、邻居等
}

// 签到记录模型
struct CheckInRecord: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var elderlyId: UUID
    var checkInTime: Date = Date()
    var note: String = ""
    var latitude: Double? // 签到时的纬度
    var longitude: Double? // 签到时的经度

    // 日期字符串，用于判断是否当天签到
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: checkInTime)
    }

    // 是否有签到位置信息
    var hasLocation: Bool {
        latitude != nil && longitude != nil
    }
}

// 通知记录模型
struct NotificationRecord: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var elderlyId: UUID
    var contactId: UUID
    var sentAt: Date = Date()
    var message: String
    var status: String = "sent" // sent, failed
}

// 位置分享记录模型
struct LocationShareRecord: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var elderlyId: UUID
    var sharedAt: Date = Date()
    var latitude: Double
    var longitude: Double
    var address: String = ""
    var sharedWith: [UUID] = [] // 分享给的紧急联系人ID列表

    // 是否有位置信息
    var hasLocation: Bool {
        true // LocationShareRecord 总是包含位置
    }
}
