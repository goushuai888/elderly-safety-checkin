//
//  CheckInView.swift
//  死了么
//
//  Created by shuai on 2026/1/16.
//

import SwiftUI

struct CheckInView: View {
    // MARK: - Constants
    private enum Layout {
        static let buttonHeight: CGFloat = 76
        static let buttonFontSize: CGFloat = 24
        static let buttonIconSize: CGFloat = 28
        static let toolbarIconSize: CGFloat = 22
        static let checkInDelay: TimeInterval = 0.15
    }

    // MARK: - Properties
    let elderly: Elderly
    @EnvironmentObject var dataManager: DataManager
    @State private var showingContacts = false
    @State private var showingHistory = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private var hasCheckedIn: Bool {
        dataManager.hasCheckedInToday(elderlyId: elderly.id)
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // 顶部状态卡片
            StatusCard(hasCheckedIn: hasCheckedIn)
                .padding(.horizontal, AppTheme.Spacing.pagePadding)
                .padding(.top, AppTheme.Spacing.xs)

            // 主签到按钮区域
            checkInButtonSection
                .padding(.horizontal, AppTheme.Spacing.pagePadding)

            // 统计区域
            StatsSection(elderly: elderly)
                .padding(.horizontal, AppTheme.Spacing.pagePadding)

            Spacer()
        }
        .background(AppTheme.Colors.background)
        .navigationTitle(elderly.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarButtons
            }
        }
        .sheet(isPresented: $showingContacts) {
            ContactsView(elderly: elderly)
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(elderly: elderly)
        }
        .alert("提示", isPresented: $showAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - View Components
    private var checkInButtonSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            if hasCheckedIn {
                CheckedInButton()
            } else {
                CheckInButton(isPressed: $isPressed, action: performCheckIn)
            }
        }
    }

    private var toolbarButtons: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ToolbarIconButton(
                icon: "person.2.circle.fill",
                color: AppTheme.Colors.pink,
                label: "紧急联系人"
            ) {
                showingContacts = true
            }

            ToolbarIconButton(
                icon: "chart.bar.xaxis",
                color: AppTheme.Colors.success,
                label: "签到记录"
            ) {
                showingHistory = true
            }
        }
    }

    // MARK: - Actions
    private func performCheckIn() {
        HapticFeedback.medium()

        withAnimation(AppTheme.Animation.bouncy) {
            isPressed = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Layout.checkInDelay) {
            dataManager.checkIn(for: elderly.id)
            HapticFeedback.success()
            alertMessage = "签到成功！"
            showAlert = true

            withAnimation(AppTheme.Animation.bouncy) {
                isPressed = false
            }
        }
    }
}

// MARK: - Toolbar Icon Button
/// 工具栏图标按钮
private struct ToolbarIconButton: View {
    let icon: String
    let color: Color
    let label: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticFeedback.light()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
        }
        .accessibilityLabel(label)
    }
}

// MARK: - Status Card
/// 状态卡片 - 显示签到状态
struct StatusCard: View {
    let hasCheckedIn: Bool

    private var iconConfig: (name: String, colors: [Color]) {
        hasCheckedIn
            ? ("checkmark.seal.fill", [AppTheme.Colors.success, AppTheme.Colors.successDark])
            : ("clock.badge.exclamationmark.fill", [AppTheme.Colors.warning, AppTheme.Colors.warningDark])
    }

    private var textConfig: (title: String, subtitle: String) {
        hasCheckedIn
            ? ("今日已签到", "感谢您的签到，明天见")
            : ("待签到", "请完成今日签到")
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            GradientIconCircle(
                icon: iconConfig.name,
                colors: iconConfig.colors,
                size: 48,
                iconSize: 24
            )

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(textConfig.title)
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(AppTheme.Colors.text)

                Text(textConfig.subtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textMuted)
            }

            Spacer()

            if hasCheckedIn {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AppTheme.Colors.success)
            }
        }
        .padding(AppTheme.Spacing.md)
        .cardBackground()
    }
}

// MARK: - Check In Button
/// 签到按钮 - 大尺寸老年人友好设计
struct CheckInButton: View {
    @Binding var isPressed: Bool
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button(action: action) {
            CheckInButtonContent(
                icon: "hand.tap.fill",
                text: "点击签到"
            )
            .foregroundColor(.white)
            .background(
                ZStack {
                    LinearGradient.primary
                    LinearGradient.softOverlay
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
            .shadow(
                color: AppTheme.Colors.primary.opacity(isPressed ? 0.2 : 0.4),
                radius: isPressed ? 8 : 16,
                x: 0,
                y: isPressed ? 4 : 8
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(reduceMotion ? nil : AppTheme.Animation.bouncy, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibleButton(label: "点击签到", hint: "双击完成今日签到")
    }
}

// MARK: - Checked In Button
/// 已签到状态按钮
struct CheckedInButton: View {
    var body: some View {
        CheckInButtonContent(
            icon: "checkmark.circle.fill",
            text: "今日已签到"
        )
        .foregroundColor(AppTheme.Colors.success)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.xl)
                .fill(AppTheme.Colors.successSoft)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.xl)
                        .stroke(AppTheme.Colors.success.opacity(0.3), lineWidth: 2)
                )
        )
        .accessibilityLabel("今日已签到")
    }
}

// MARK: - Check In Button Content
/// 签到按钮内容 - 共享布局
private struct CheckInButtonContent: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))

            Text(text)
                .font(.system(size: 24, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 76)
    }
}

// MARK: - Stats Section
/// 统计区域
struct StatsSection: View {
    let elderly: Elderly
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        let stats = dataManager.getCheckInStats(for: elderly.id)

        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("签到统计")
                .font(AppTheme.Typography.bodyBold)
                .foregroundColor(AppTheme.Colors.text)
                .padding(.horizontal, AppTheme.Spacing.xxs)

            HStack(spacing: AppTheme.Spacing.itemSpacing) {
                StatCard(
                    label: "总次数",
                    value: "\(stats.total)",
                    icon: "chart.bar.fill",
                    color: AppTheme.Colors.primary
                )

                StatCard(
                    label: "近7天",
                    value: "\(stats.last7Days)",
                    icon: "calendar",
                    color: AppTheme.Colors.success
                )

                StatCard(
                    label: "近30天",
                    value: "\(stats.last30Days)",
                    icon: "calendar.badge.clock",
                    color: AppTheme.Colors.warning
                )
            }
        }
    }
}

// MARK: - Stat Card
/// 统计卡片
struct StatCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.Colors.text)

            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.md)
        .cardBackground()
    }
}

// MARK: - Card Background Modifier
/// 统一的卡片背景样式
private extension View {
    func cardBackground() -> some View {
        background(
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

#Preview {
    NavigationView {
        CheckInView(elderly: Elderly(
            name: "张奶奶",
            phone: "13800138000",
            address: "北京市朝阳区"
        ))
        .environmentObject(DataManager.shared)
    }
}
