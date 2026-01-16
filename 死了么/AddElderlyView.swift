//
//  AddElderlyView.swift
//  死了么
//
//  Created by shuai on 2026/1/16.
//

import SwiftUI

struct AddElderlyView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var isPresented: Bool

    @State private var name = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var checkTime = "20:00"

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.sectionSpacing) {
                    // 头像占位符
                    AvatarPlaceholder()
                        .padding(.top, AppTheme.Spacing.lg)

                    // 表单区域
                    VStack(spacing: AppTheme.Spacing.md) {
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

                        FormField(
                            icon: "house.fill",
                            label: "住址",
                            placeholder: "请输入住址（选填）",
                            text: $address,
                            color: AppTheme.Colors.warning
                        )

                        FormField(
                            icon: "clock.fill",
                            label: "每日提醒时间",
                            placeholder: "HH:MM（如 20:00）",
                            text: $checkTime,
                            color: AppTheme.Colors.purple
                        )
                    }
                    .padding(.horizontal, AppTheme.Spacing.pagePadding)

                    // 提示信息
                    TipCard(
                        icon: "info.circle.fill",
                        message: "系统将在设定的时间提醒老人进行签到，请确保老人能在该时间段操作手机",
                        color: AppTheme.Colors.primary
                    )
                    .padding(.horizontal, AppTheme.Spacing.pagePadding)

                    // 保存按钮
                    Button(action: saveElderly) {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                            Text("保存信息")
                        }
                        .font(AppTheme.Typography.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Size.buttonLarge)
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
                    .padding(.top, AppTheme.Spacing.xs)

                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
                .padding(.vertical, AppTheme.Spacing.md)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("添加老人信息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
    }

    private func saveElderly() {
        HapticFeedback.success()
        let elderly = Elderly(
            name: name.trimmingCharacters(in: .whitespaces),
            phone: phone.trimmingCharacters(in: .whitespaces),
            address: address.trimmingCharacters(in: .whitespaces),
            checkTime: checkTime
        )
        dataManager.addElderly(elderly)
        isPresented = false
    }
}

// MARK: - Avatar Placeholder
/// 头像占位符
struct AvatarPlaceholder: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.Colors.textPlaceholder, AppTheme.Colors.textMuted],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: AppTheme.Size.avatarXLarge, height: AppTheme.Size.avatarXLarge)

            Image(systemName: "person.fill")
                .font(.system(size: 36, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .shadow(color: AppTheme.Colors.shadow, radius: 12, x: 0, y: 4)
    }
}

#Preview {
    AddElderlyView(isPresented: .constant(true))
        .environmentObject(DataManager.shared)
}
