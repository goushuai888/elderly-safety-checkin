//
//  LocationSharingHelper.swift
//  死了么
//
//  Created by Claude on 2026/1/16.
//

import Foundation
import CoreLocation
import SwiftUI
import UIKit

// MARK: - Location Sharing Helper

/// 位置分享辅助类
class LocationSharingHelper {

    // MARK: - Share Content Generation

    /// 生成位置分享内容
    static func generateShareContent(
        elderly: Elderly,
        latitude: Double,
        longitude: Double,
        address: String?
    ) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        let timeString = timeFormatter.string(from: Date())

        var content = """
        【位置分享】

        老人：\(elderly.name)
        时间：\(timeString)

        """

        if let addr = address, !addr.isEmpty {
            content += "地址：\(addr)\n\n"
        }

        // 添加坐标
        content += "坐标：\(String(format: "%.6f", latitude)), \(String(format: "%.6f", longitude))\n\n"

        // 添加地图链接（支持多个地图应用）
        content += "查看位置：\n"

        // 高德地图
        let amapURL = "https://uri.amap.com/marker?position=\(longitude),\(latitude)&name=\(elderly.name)的位置"
        content += "• 高德地图：\(amapURL)\n"

        // 百度地图
        let baiduURL = "http://api.map.baidu.com/marker?location=\(latitude),\(longitude)&title=\(elderly.name)的位置&output=html"
        content += "• 百度地图：\(baiduURL)\n"

        // Apple 地图
        let appleURL = "http://maps.apple.com/?q=\(latitude),\(longitude)"
        content += "• Apple地图：\(appleURL)\n"

        content += "\n来自\"死了么\"应用"

        return content
    }

    /// 生成紧急位置分享内容（带紧急标记）
    static func generateEmergencyShareContent(
        elderly: Elderly,
        latitude: Double,
        longitude: Double,
        address: String?
    ) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        let timeString = timeFormatter.string(from: Date())

        var content = """
        ⚠️【紧急位置分享】⚠️

        老人：\(elderly.name)
        电话：\(elderly.phone)
        时间：\(timeString)

        """

        if let addr = address, !addr.isEmpty {
            content += "地址：\(addr)\n\n"
        }

        content += "坐标：\(String(format: "%.6f", latitude)), \(String(format: "%.6f", longitude))\n\n"

        content += "查看位置：\n"
        let amapURL = "https://uri.amap.com/marker?position=\(longitude),\(latitude)&name=紧急位置"
        content += "• 高德地图：\(amapURL)\n"

        let appleURL = "http://maps.apple.com/?q=\(latitude),\(longitude)"
        content += "• Apple地图：\(appleURL)\n"

        content += "\n请尽快联系或前往查看！\n来自\"死了么\"应用"

        return content
    }

    /// 生成短信分享内容（精简版）
    static func generateSMSContent(
        elderly: Elderly,
        latitude: Double,
        longitude: Double,
        address: String?
    ) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: Date())

        var content = "\(elderly.name)的位置(\(timeString))："

        if let addr = address, !addr.isEmpty {
            content += "\n\(addr)"
        }

        // 使用高德地图链接（国内使用较多）
        let mapURL = "https://uri.amap.com/marker?position=\(longitude),\(latitude)"
        content += "\n查看地图：\(mapURL)"

        return content
    }

    // MARK: - Helper Methods

    /// 计算两个位置之间的距离（单位：米）
    static func distance(
        from: (latitude: Double, longitude: Double),
        to: (latitude: Double, longitude: Double)
    ) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }

    /// 格式化距离显示
    static func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return String(format: "%.0f米", meters)
        } else {
            return String(format: "%.1f公里", meters / 1000)
        }
    }

    /// 格式化时间显示（相对时间）
    static func formatRelativeTime(_ date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)

        if seconds < 60 {
            return "刚刚"
        } else if seconds < 3600 {
            let minutes = Int(seconds / 60)
            return "\(minutes)分钟前"
        } else if seconds < 86400 {
            let hours = Int(seconds / 3600)
            return "\(hours)小时前"
        } else {
            let days = Int(seconds / 86400)
            return "\(days)天前"
        }
    }
}

// MARK: - Share Sheet

/// SwiftUI 分享表单
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let activities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: activities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 不需要更新
    }
}
