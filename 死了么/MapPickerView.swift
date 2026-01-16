//
//  MapPickerView.swift
//  死了么
//
//  Created by Claude on 2026/1/16.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Map Picker View

/// 地图选点界面
struct MapPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var selectedAddress: String

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074), // 默认北京
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var isLoadingAddress = false
    @State private var currentAddress = "移动地图选择位置"
    @State private var isLoadingLocation = false
    @State private var lastGeocodeTime: Date?

    var body: some View {
        ZStack {
            // 地图
            Map(coordinateRegion: $region)
                .edgesIgnoringSafeArea(.all)

            // 中心准星
            VStack {
                Spacer()
                Image(systemName: "mappin")
                    .font(AppTheme.Typography.statNumber)
                    .foregroundColor(AppTheme.Colors.danger)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(y: -AppTheme.Spacing.lg)
                Spacer()
            }

            // 顶部工具栏
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(AppTheme.Typography.largeTitle)
                            .foregroundColor(AppTheme.Colors.text)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: AppTheme.Size.iconXXLarge, height: AppTheme.Size.iconXXLarge)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .padding()
                    .seniorFriendlyTouchTarget()

                    Spacer()

                    Button(action: useCurrentLocation) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: AppTheme.Size.touchTarget, height: AppTheme.Size.touchTarget)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                            if isLoadingLocation {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "location.fill")
                                    .font(AppTheme.Typography.title2)
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                        }
                    }
                    .padding()
                    .seniorFriendlyTouchTarget()
                    .disabled(isLoadingLocation)
                }
                .padding(.top, AppTheme.Spacing.xxxl + AppTheme.Spacing.md)

                Spacer()
            }

            // 底部控制面板
            VStack {
                Spacer()
                MapControlPanel(
                    address: currentAddress,
                    isLoadingAddress: isLoadingAddress,
                    onRefresh: {
                        reverseGeocode(coordinate: region.center)
                    },
                    onConfirm: confirmSelection,
                    onCancel: { dismiss() }
                )
            }
        }
        .onAppear {
            // 如果已有坐标，使用它
            if let coordinate = selectedCoordinate {
                region.center = coordinate
                reverseGeocode(coordinate: coordinate)
            } else {
                // 否则尝试获取当前位置
                useCurrentLocation()
            }
        }
    }

    // MARK: - Private Methods

    private func useCurrentLocation() {
        isLoadingLocation = true
        HapticFeedback.light()

        LocationManager.shared.requestCurrentLocation { result in
            DispatchQueue.main.async {
                isLoadingLocation = false

                switch result {
                case .success(let location):
                    region.center = location.coordinate
                    HapticFeedback.success()

                case .failure(let error):
                    // 位置获取失败，不显示错误（保持当前位置）
                    print("获取位置失败: \(error.localizedDescription)")
                }
            }
        }
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        isLoadingAddress = true

        LocationManager.shared.reverseGeocode(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        ) { result in
            DispatchQueue.main.async {
                isLoadingAddress = false

                switch result {
                case .success(let address):
                    currentAddress = address

                case .failure:
                    currentAddress = String(format: "纬度: %.6f, 经度: %.6f", coordinate.latitude, coordinate.longitude)
                }
            }
        }
    }

    private func confirmSelection() {
        HapticFeedback.success()
        selectedCoordinate = region.center
        selectedAddress = currentAddress
        dismiss()
    }
}

// MARK: - Map Control Panel

/// 底部控制面板
struct MapControlPanel: View {
    let address: String
    let isLoadingAddress: Bool
    let onRefresh: () -> Void
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // 地址显示区域
            HStack(spacing: AppTheme.Spacing.sm) {
                if isLoadingAddress {
                    ProgressView()
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "mappin.circle.fill")
                        .font(AppTheme.Typography.title2)
                        .foregroundColor(AppTheme.Colors.primary)
                }

                Text(address)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                // 刷新按钮
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(AppTheme.Typography.bodyLarge)
                        .foregroundColor(AppTheme.Colors.primary)
                        .frame(width: AppTheme.Size.iconXXLarge + 4, height: AppTheme.Size.iconXXLarge + 4)
                        .background(
                            Circle()
                                .fill(AppTheme.Colors.backgroundSecondary)
                        )
                }
                .disabled(isLoadingAddress)
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .fill(AppTheme.Colors.card)
            )

            // 按钮组
            HStack(spacing: AppTheme.Spacing.sm) {
                Button(action: onCancel) {
                    Text("取消")
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundColor(AppTheme.Colors.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Size.touchTarget)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .fill(AppTheme.Colors.backgroundSecondary)
                        )
                }
                .seniorFriendlyTouchTarget()

                Button(action: onConfirm) {
                    Text("确认选择")
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Size.touchTarget)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.Colors.primary, AppTheme.Colors.primaryDark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                }
                .seniorFriendlyTouchTarget()
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.xl)
                .fill(.white)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: -4)
        )
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.bottom, AppTheme.Spacing.md)
    }
}

// MARK: - Preview

#Preview {
    MapPickerView(
        selectedCoordinate: .constant(nil),
        selectedAddress: .constant("")
    )
}
