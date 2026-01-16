//
//  CheckInMapView.swift
//  死了么
//
//  Created by Claude on 2026/1/16.
//

import SwiftUI
import MapKit

// MARK: - Map Annotation Item

/// 地图标注数据模型
struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let color: Color
}

// MARK: - Check In Map View

/// 签到记录地图视图
struct CheckInMapView: View {
    let elderly: Elderly
    let record: CheckInRecord

    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074), // 北京
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    private var annotations: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []

        // 添加家庭住址标记
        if elderly.hasHomeLocation,
           let homeLat = elderly.homeLatitude,
           let homeLon = elderly.homeLongitude {
            items.append(MapAnnotationItem(
                coordinate: CLLocationCoordinate2D(latitude: homeLat, longitude: homeLon),
                title: "家庭住址",
                color: AppTheme.Colors.success
            ))
        }

        // 添加签到位置标记
        if record.hasLocation,
           let checkInLat = record.latitude,
           let checkInLon = record.longitude {
            items.append(MapAnnotationItem(
                coordinate: CLLocationCoordinate2D(latitude: checkInLat, longitude: checkInLon),
                title: "签到位置",
                color: AppTheme.Colors.primary
            ))
        }

        return items
    }

    private var hasMapData: Bool {
        !annotations.isEmpty
    }

    private var distance: String? {
        guard elderly.hasHomeLocation,
              record.hasLocation,
              let homeLat = elderly.homeLatitude,
              let homeLon = elderly.homeLongitude,
              let checkInLat = record.latitude,
              let checkInLon = record.longitude else {
            return nil
        }

        let homeLocation = CLLocation(latitude: homeLat, longitude: homeLon)
        let checkInLocation = CLLocation(latitude: checkInLat, longitude: checkInLon)
        let distanceInMeters = homeLocation.distance(from: checkInLocation)

        if distanceInMeters < 1000 {
            return String(format: "%.0f米", distanceInMeters)
        } else {
            return String(format: "%.1f公里", distanceInMeters / 1000)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // 标题
            Text("位置信息")
                .font(AppTheme.Typography.bodyBold)
                .foregroundColor(AppTheme.Colors.text)
                .padding(.horizontal, AppTheme.Spacing.xxs)

            if hasMapData {
                VStack(spacing: 0) {
                    // 地图
                    Map(coordinateRegion: $region, annotationItems: annotations) { item in
                        MapAnnotation(coordinate: item.coordinate) {
                            MapPinView(title: item.title, color: item.color)
                        }
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))

                    // 距离信息
                    if let distance = distance {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "ruler.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.Colors.textMuted)

                            Text("距离家庭住址：\(distance)")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.textMuted)

                            Spacer()
                        }
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(AppTheme.Colors.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                        .fill(AppTheme.Colors.card)
                        .shadow(
                            color: AppTheme.Colors.shadowLight,
                            radius: 6,
                            x: 0,
                            y: 2
                        )
                )
            } else {
                EmptyMapPlaceholder()
            }
        }
        .onAppear {
            updateRegion()
        }
    }

    // MARK: - Private Methods

    private func updateRegion() {
        guard hasMapData else { return }

        // 计算包含所有标记的区域
        var minLat = Double.greatestFiniteMagnitude
        var maxLat = -Double.greatestFiniteMagnitude
        var minLon = Double.greatestFiniteMagnitude
        var maxLon = -Double.greatestFiniteMagnitude

        for annotation in annotations {
            minLat = min(minLat, annotation.coordinate.latitude)
            maxLat = max(maxLat, annotation.coordinate.latitude)
            minLon = min(minLon, annotation.coordinate.longitude)
            maxLon = max(maxLon, annotation.coordinate.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.5, 0.01),
            longitudeDelta: max((maxLon - minLon) * 1.5, 0.01)
        )

        region = MKCoordinateRegion(center: center, span: span)
    }
}

// MARK: - Map Pin View

/// 地图标记视图
struct MapPinView: View {
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            // 标记图标
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)
                    .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 2)

                Image(systemName: title == "家庭住址" ? "house.fill" : "mappin")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }

            // 标签
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(color)
                )
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - Empty Map Placeholder

/// 空状态占位符
struct EmptyMapPlaceholder: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "map.fill")
                .font(.system(size: 32))
                .foregroundColor(AppTheme.Colors.textMuted)

            Text("暂无位置信息")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textMuted)

            Text("签到时未记录位置或家庭住址")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                .fill(AppTheme.Colors.card)
                .shadow(
                    color: AppTheme.Colors.shadowLight,
                    radius: 6,
                    x: 0,
                    y: 2
                )
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        CheckInMapView(
            elderly: Elderly(
                name: "张奶奶",
                phone: "13800138000",
                address: "北京市朝阳区",
                homeLatitude: 39.9042,
                homeLongitude: 116.4074
            ),
            record: CheckInRecord(
                elderlyId: UUID(),
                latitude: 39.9050,
                longitude: 116.4080
            )
        )
        .padding()
    }
    .background(AppTheme.Colors.background)
}
