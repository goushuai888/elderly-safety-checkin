//
//  Extensions.swift
//  死了么
//
//  Created by shuai on 2026/1/16.
//  共享组件和扩展
//

import SwiftUI
import UIKit

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Form Field Component
/// 优化的表单字段组件 - 老年人友好设计
struct FormField: View {
    let icon: String
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    let color: Color
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            // 标签区域
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)

                Text(label)
                    .font(AppTheme.Typography.captionBold)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            // 输入框
            TextField(placeholder, text: $text)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.text)
                .padding(AppTheme.Spacing.md)
                .frame(minHeight: AppTheme.Size.inputHeight)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                        .fill(AppTheme.Colors.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                                .stroke(
                                    isFocused ? color : AppTheme.Colors.border,
                                    lineWidth: isFocused ? 2 : 1
                                )
                        )
                        .shadow(
                            color: isFocused ? color.opacity(0.15) : Color.clear,
                            radius: 8,
                            x: 0,
                            y: 2
                        )
                )
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .sentences)
                .focused($isFocused)
                .animation(AppTheme.Animation.fast, value: isFocused)
        }
    }
}

// MARK: - Icon Button Component
/// 带图标的圆形按钮
struct IconButton: View {
    let icon: String
    let color: Color
    var size: CGFloat = 44
    var iconSize: CGFloat = 20
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(color)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(color.opacity(0.12))
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Gradient Icon Circle
/// 渐变背景的图标圆圈
struct GradientIconCircle: View {
    let icon: String
    let colors: [Color]
    var size: CGFloat = 56
    var iconSize: CGFloat = 28

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Soft Icon Circle
/// 柔和背景的图标圆圈
struct SoftIconCircle: View {
    let icon: String
    let color: Color
    var size: CGFloat = 48
    var iconSize: CGFloat = 22

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: size, height: size)

            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(color)
        }
    }
}

// MARK: - Status Badge
/// 状态徽章组件
struct StatusBadge: View {
    let text: String
    let color: Color
    var showDot: Bool = true

    var body: some View {
        HStack(spacing: 6) {
            if showDot {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
            Text(text)
                .font(AppTheme.Typography.small)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
        )
    }
}

// MARK: - Info Row Component
/// 信息行组件 - 用于展示标签和值
struct InfoRowView: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            SoftIconCircle(icon: icon, color: color, size: 40, iconSize: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppTheme.Typography.small)
                    .foregroundColor(AppTheme.Colors.textPlaceholder)

                Text(value)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.text)
            }

            Spacer()
        }
    }
}

// MARK: - Empty State View
/// 空状态视图组件
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var buttonTitle: String? = nil
    var buttonColor: Color = AppTheme.Colors.primary
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64, weight: .light))
                .foregroundColor(AppTheme.Colors.textPlaceholder)
                .padding(.bottom, AppTheme.Spacing.xs)

            VStack(spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(AppTheme.Colors.text)

                Text(subtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                        Text(buttonTitle)
                    }
                    .font(AppTheme.Typography.buttonSmall)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(
                        LinearGradient(
                            colors: [buttonColor, buttonColor.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: buttonColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.top, AppTheme.Spacing.xs)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xxxl)
        .padding(.horizontal, AppTheme.Spacing.xl)
        .cardStyle()
    }
}

// MARK: - Section Header
/// 区块标题组件
struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionLabel: String? = nil
    var actionIcon: String = "plus.circle.fill"
    var actionColor: Color = AppTheme.Colors.primary

    var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.Colors.text)

            Spacer()

            if let action = action, let actionLabel = actionLabel {
                Button(action: action) {
                    HStack(spacing: 6) {
                        Image(systemName: actionIcon)
                            .font(.system(size: 14))
                        Text(actionLabel)
                            .font(AppTheme.Typography.captionBold)
                    }
                    .foregroundColor(actionColor)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.pagePadding)
    }
}

// MARK: - Divider Line
/// 分割线组件
struct DividerLine: View {
    var color: Color = AppTheme.Colors.border

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 1)
    }
}

// MARK: - Scale Button Style
/// 缩放按钮样式 - 点击时有缩放效果
struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(AppTheme.Animation.fast, value: configuration.isPressed)
    }
}

// MARK: - Press Button Style
/// 按压按钮样式 - 带阴影变化
struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(AppTheme.Animation.fast, value: configuration.isPressed)
    }
}

// MARK: - Loading Indicator
/// 加载指示器
struct LoadingIndicator: View {
    var color: Color = AppTheme.Colors.primary
    var size: CGFloat = 24

    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: color))
            .scaleEffect(size / 20)
    }
}

// MARK: - Tip Card
/// 提示卡片组件
struct TipCard: View {
    let icon: String
    let message: String
    var color: Color = AppTheme.Colors.primary

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)

            Text(message)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .lineSpacing(3)

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                .fill(color.opacity(0.08))
        )
    }
}

// MARK: - Avatar View
/// 头像视图组件
struct AvatarView: View {
    let name: String
    var size: CGFloat = 48
    var colors: [Color] = [AppTheme.Colors.primary, AppTheme.Colors.primaryDark]

    private var initial: String {
        String(name.prefix(1))
    }

    private var fontSize: CGFloat {
        size * 0.45
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            Text(initial)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Haptic Feedback Helper
/// 触觉反馈辅助类
struct HapticFeedback {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Accessibility Helpers
extension View {
    /// 添加无障碍标签和提示
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }

    /// 为老年人优化的触控区域
    func seniorFriendlyTouchTarget() -> some View {
        self
            .frame(minWidth: AppTheme.Size.touchTarget, minHeight: AppTheme.Size.touchTarget)
            .contentShape(Rectangle())
    }
}
