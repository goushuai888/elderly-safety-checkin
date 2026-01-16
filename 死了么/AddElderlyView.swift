//
//  AddElderlyView.swift
//  死了么
//
//  Created by shuai on 2026/1/16.
//

import SwiftUI
import CoreLocation

struct AddElderlyView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var isPresented: Bool
    let elderly: Elderly? // 编辑模式时传入，添加模式为 nil

    @State private var name: String
    @State private var phone: String
    @State private var address: String
    @State private var checkTime: Date
    @State private var homeCoordinate: CLLocationCoordinate2D? = nil
    @State private var showingMapPicker = false

    // 初始化方法，根据是否为编辑模式设置初始值
    init(isPresented: Binding<Bool>, elderly: Elderly?) {
        self._isPresented = isPresented
        self.elderly = elderly

        // 根据是否有 elderly 数据来初始化状态
        if let elderly = elderly {
            // 编辑模式：使用现有数据
            self._name = State(initialValue: elderly.name)
            self._phone = State(initialValue: elderly.phone)
            self._address = State(initialValue: elderly.address)

            // 解析时间字符串
            let timeComponents = elderly.checkTime.split(separator: ":").compactMap { Int($0) }
            if timeComponents.count == 2 {
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month, .day], from: Date())
                components.hour = timeComponents[0]
                components.minute = timeComponents[1]
                if let time = calendar.date(from: components) {
                    self._checkTime = State(initialValue: time)
                } else {
                    self._checkTime = State(initialValue: Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date())
                }
            } else {
                self._checkTime = State(initialValue: Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date())
            }

            // 加载坐标
            if let lat = elderly.homeLatitude, let lon = elderly.homeLongitude {
                self._homeCoordinate = State(initialValue: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
        } else {
            // 添加模式：使用默认值
            self._name = State(initialValue: "")
            self._phone = State(initialValue: "")
            self._address = State(initialValue: "")
            self._checkTime = State(initialValue: Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date())
        }
    }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var isEditMode: Bool {
        elderly != nil
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 表单区域
                VStack(spacing: AppTheme.Spacing.sm) {
                    FormField(
                        icon: "person.fill",
                        label: "姓名",
                        placeholder: "请输入老人姓名",
                        text: $name,
                        color: AppTheme.Colors.primary
                    )

                    FormField(
                        icon: "phone.fill",
                        label: "电话",
                        placeholder: "请输入联系电话",
                        text: $phone,
                        keyboardType: .phonePad,
                        color: AppTheme.Colors.success
                    )

                    // 地址选择（点击打开地图）
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.Colors.warning)
                            Text("住址")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.textMuted)
                        }

                        Button(action: { showingMapPicker = true }) {
                            HStack {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.warning)
                                Text(address.isEmpty ? "在地图上选择位置" : address)
                                    .font(.system(size: 15))
                                    .foregroundColor(address.isEmpty ? AppTheme.Colors.textMuted : AppTheme.Colors.text)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.textMuted)
                            }
                            .padding(AppTheme.Spacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                    .fill(AppTheme.Colors.backgroundSecondary)
                            )
                        }
                    }

                    // 时间选择器（紧凑样式）
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.Colors.purple)
                            Text("每日提醒时间")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.textMuted)
                        }

                        DatePicker(
                            "",
                            selection: $checkTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: AppTheme.Size.touchTarget)
                        .padding(AppTheme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .fill(AppTheme.Colors.backgroundSecondary)
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.pagePadding)
                .padding(.top, AppTheme.Spacing.md)

                Spacer()

                // 保存按钮（固定在底部）
                Button(action: saveElderly) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(AppTheme.Typography.bodyLarge)
                        Text("保存信息")
                    }
                    .font(AppTheme.Typography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: AppTheme.Size.touchTargetLarge)
                    .background(
                        ZStack {
                            LinearGradient.primary
                            LinearGradient.softOverlay
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                    .shadow(
                        color: AppTheme.Colors.primary.opacity(0.35),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.5)
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, AppTheme.Spacing.pagePadding)
                .padding(.bottom, AppTheme.Spacing.md)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(isEditMode ? "编辑老人信息" : "添加老人信息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .sheet(isPresented: $showingMapPicker) {
                MapPickerView(
                    selectedCoordinate: $homeCoordinate,
                    selectedAddress: $address
                )
            }
        }
    }

    private func saveElderly() {
        HapticFeedback.success()

        // 将 Date 转换为 "HH:mm" 格式
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: checkTime)

        let updatedElderly = Elderly(
            id: elderly?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            phone: phone.trimmingCharacters(in: .whitespaces),
            address: address.trimmingCharacters(in: .whitespaces),
            homeLatitude: homeCoordinate?.latitude,
            homeLongitude: homeCoordinate?.longitude,
            checkTime: timeString
        )

        if isEditMode {
            dataManager.updateElderly(updatedElderly)
        } else {
            dataManager.addElderly(updatedElderly)
        }

        isPresented = false
    }
}

#Preview {
    AddElderlyView(isPresented: .constant(true), elderly: nil)
        .environmentObject(DataManager.shared)
}
