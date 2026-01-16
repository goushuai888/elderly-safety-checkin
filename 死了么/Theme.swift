//
//  Theme.swift
//  死了么
//
//  Created by shuai on 2026/1/16.
//  Design System - 统一的设计规范
//

import SwiftUI

// MARK: - App Theme
/// 应用主题设计系统
/// 基于老年人友好设计原则：高对比度、大字体、柔和色彩、清晰层次
struct AppTheme {

    // MARK: - Colors 颜色系统
    struct Colors {
        // 主色调 - 平静蓝色系，传达信任和安全感
        static let primary = Color(hex: "3B82F6")           // 主色
        static let primaryLight = Color(hex: "60A5FA")      // 浅主色
        static let primaryDark = Color(hex: "2563EB")       // 深主色
        static let primarySoft = Color(hex: "DBEAFE")       // 柔和主色背景

        // 成功色 - 健康绿色，代表签到完成
        static let success = Color(hex: "10B981")           // 成功色
        static let successLight = Color(hex: "34D399")      // 浅成功色
        static let successDark = Color(hex: "059669")       // 深成功色
        static let successSoft = Color(hex: "D1FAE5")       // 柔和成功色背景

        // 警告色 - 温暖橙色，代表待办提醒
        static let warning = Color(hex: "F59E0B")           // 警告色
        static let warningLight = Color(hex: "FBBF24")      // 浅警告色
        static let warningDark = Color(hex: "D97706")       // 深警告色
        static let warningSoft = Color(hex: "FEF3C7")       // 柔和警告色背景

        // 危险色 - 用于删除等危险操作
        static let danger = Color(hex: "EF4444")            // 危险色
        static let dangerLight = Color(hex: "F87171")       // 浅危险色
        static let dangerDark = Color(hex: "DC2626")        // 深危险色
        static let dangerSoft = Color(hex: "FEE2E2")        // 柔和危险色背景

        // 紫色 - 用于设置等次要功能
        static let purple = Color(hex: "8B5CF6")            // 紫色
        static let purpleLight = Color(hex: "A78BFA")       // 浅紫色
        static let purpleSoft = Color(hex: "EDE9FE")        // 柔和紫色背景

        // 青色 - 用于信息展示
        static let cyan = Color(hex: "0891B2")              // 青色
        static let cyanLight = Color(hex: "22D3EE")         // 浅青色
        static let cyanSoft = Color(hex: "CFFAFE")          // 柔和青色背景

        // 粉色 - 用于紧急联系人等
        static let pink = Color(hex: "EC4899")              // 粉色
        static let pinkLight = Color(hex: "F472B6")         // 浅粉色
        static let pinkSoft = Color(hex: "FCE7F3")          // 柔和粉色背景

        // 中性色 - 文本和背景
        static let text = Color(hex: "1E293B")              // 主文本 - 高对比度
        static let textSecondary = Color(hex: "475569")     // 次要文本
        static let textMuted = Color(hex: "64748B")         // 弱化文本
        static let textPlaceholder = Color(hex: "94A3B8")   // 占位符文本

        // 背景色
        static let background = Color(hex: "F8FAFC")        // 页面背景
        static let backgroundSecondary = Color(hex: "F1F5F9") // 次要背景
        static let card = Color.white                        // 卡片背景
        static let cardHover = Color(hex: "F8FAFC")         // 卡片悬停

        // 边框色
        static let border = Color(hex: "E2E8F0")            // 默认边框
        static let borderLight = Color(hex: "F1F5F9")       // 浅边框
        static let borderFocus = Color(hex: "3B82F6")       // 聚焦边框

        // 阴影色
        static let shadow = Color.black.opacity(0.08)       // 卡片阴影
        static let shadowLight = Color.black.opacity(0.04)  // 浅阴影
        static let shadowMedium = Color.black.opacity(0.12) // 中等阴影
    }

    // MARK: - Typography 字体系统
    struct Typography {
        // 大标题 - 用于欢迎页等
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)

        // 标题层级
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 24, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)

        // 正文 - 老年人友好的大字体
        static let bodyLarge = Font.system(size: 18, weight: .regular, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
        static let bodyBold = Font.system(size: 16, weight: .semibold, design: .rounded)

        // 辅助文本
        static let caption = Font.system(size: 14, weight: .regular, design: .rounded)
        static let captionBold = Font.system(size: 14, weight: .semibold, design: .rounded)
        static let small = Font.system(size: 12, weight: .regular, design: .rounded)

        // 按钮文本
        static let buttonLarge = Font.system(size: 20, weight: .bold, design: .rounded)
        static let button = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let buttonSmall = Font.system(size: 15, weight: .semibold, design: .rounded)

        // 签到按钮特大字体
        static let checkInButton = Font.system(size: 26, weight: .bold, design: .rounded)

        // 数字展示
        static let statNumber = Font.system(size: 36, weight: .bold, design: .rounded)
        static let statLabel = Font.system(size: 13, weight: .medium, design: .rounded)
    }

    // MARK: - Spacing 间距系统
    struct Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40

        // 页面内边距
        static let pagePadding: CGFloat = 20

        // 卡片内边距
        static let cardPadding: CGFloat = 20

        // 组件间距
        static let sectionSpacing: CGFloat = 24
        static let itemSpacing: CGFloat = 12
    }

    // MARK: - Radius 圆角系统
    struct Radius {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 28
        static let full: CGFloat = 9999 // 完全圆形
    }

    // MARK: - Shadows 阴影系统
    struct Shadows {
        // 卡片阴影
        static let card = Shadow(color: Colors.shadow, radius: 12, x: 0, y: 4)
        static let cardHover = Shadow(color: Colors.shadowMedium, radius: 16, x: 0, y: 6)

        // 浮动按钮阴影
        static let button = Shadow(color: Colors.shadow, radius: 8, x: 0, y: 4)
        static let buttonPressed = Shadow(color: Colors.shadowLight, radius: 4, x: 0, y: 2)

        // 主要按钮阴影（带颜色）
        static func primaryButton(color: Color) -> Shadow {
            Shadow(color: color.opacity(0.35), radius: 12, x: 0, y: 6)
        }

        // 底部导航栏阴影
        static let tabBar = Shadow(color: Colors.shadow, radius: 20, x: 0, y: -4)
    }

    // MARK: - Animation 动画系统
    struct Animation {
        // 快速交互 - 按钮点击等
        static let fast = SwiftUI.Animation.spring(response: 0.25, dampingFraction: 0.7)

        // 标准交互
        static let standard = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.7)

        // 慢速过渡
        static let slow = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)

        // 弹性动画 - 用于签到按钮等
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)

        // 平滑过渡
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
    }

    // MARK: - Size 尺寸规范
    struct Size {
        // 触控目标最小尺寸 - 老年人友好 (WCAG 建议至少 44x44)
        static let touchTarget: CGFloat = 48
        static let touchTargetLarge: CGFloat = 56

        // 图标尺寸
        static let iconSmall: CGFloat = 16
        static let iconMedium: CGFloat = 20
        static let iconLarge: CGFloat = 24
        static let iconXLarge: CGFloat = 28
        static let iconXXLarge: CGFloat = 32

        // 头像尺寸
        static let avatarSmall: CGFloat = 40
        static let avatarMedium: CGFloat = 48
        static let avatarLarge: CGFloat = 64
        static let avatarXLarge: CGFloat = 80

        // 按钮高度
        static let buttonSmall: CGFloat = 40
        static let buttonMedium: CGFloat = 48
        static let buttonLarge: CGFloat = 56
        static let buttonXLarge: CGFloat = 64

        // 签到按钮
        static let checkInButton: CGFloat = 88

        // 输入框高度
        static let inputHeight: CGFloat = 52
    }
}

// MARK: - Shadow Struct
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions for Theme
extension View {
    /// 应用卡片样式
    func cardStyle(padding: CGFloat = AppTheme.Spacing.cardPadding) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                    .fill(AppTheme.Colors.card)
                    .shadow(
                        color: AppTheme.Shadows.card.color,
                        radius: AppTheme.Shadows.card.radius,
                        x: AppTheme.Shadows.card.x,
                        y: AppTheme.Shadows.card.y
                    )
            )
    }

    /// 应用柔和卡片样式（无阴影）
    func softCardStyle(color: Color, padding: CGFloat = AppTheme.Spacing.cardPadding) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                    .fill(color)
            )
    }

    /// 主要按钮样式
    func primaryButtonStyle(color: Color = AppTheme.Colors.primary) -> some View {
        self
            .font(AppTheme.Typography.button)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Size.buttonLarge)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .shadow(
                color: color.opacity(0.35),
                radius: 12,
                x: 0,
                y: 6
            )
    }

    /// 次要按钮样式
    func secondaryButtonStyle(color: Color = AppTheme.Colors.primary) -> some View {
        self
            .font(AppTheme.Typography.button)
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Size.buttonLarge)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .stroke(color.opacity(0.3), lineWidth: 1.5)
                    )
            )
    }

    /// 图标容器样式
    func iconContainer(size: CGFloat = 48, color: Color) -> some View {
        self
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(color.opacity(0.15))
            )
    }

    /// 渐变图标容器
    func gradientIconContainer(size: CGFloat = 56, colors: [Color]) -> some View {
        self
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }
}

// MARK: - Gradient Presets 渐变预设
extension LinearGradient {
    /// 主色渐变
    static var primary: LinearGradient {
        LinearGradient(
            colors: [AppTheme.Colors.primary, AppTheme.Colors.primaryDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// 成功色渐变
    static var success: LinearGradient {
        LinearGradient(
            colors: [AppTheme.Colors.success, AppTheme.Colors.successDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// 警告色渐变
    static var warning: LinearGradient {
        LinearGradient(
            colors: [AppTheme.Colors.warning, AppTheme.Colors.warningDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// 危险色渐变
    static var danger: LinearGradient {
        LinearGradient(
            colors: [AppTheme.Colors.danger, AppTheme.Colors.dangerDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// 青色渐变
    static var cyan: LinearGradient {
        LinearGradient(
            colors: [AppTheme.Colors.cyan, Color(hex: "0E7490")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// 紫色渐变
    static var purple: LinearGradient {
        LinearGradient(
            colors: [AppTheme.Colors.purple, Color(hex: "7C3AED")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// 粉色渐变
    static var pink: LinearGradient {
        LinearGradient(
            colors: [AppTheme.Colors.pink, Color(hex: "DB2777")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// 柔和叠加渐变（用于按钮光泽效果）
    static var softOverlay: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.25), Color.white.opacity(0)],
            startPoint: .top,
            endPoint: .center
        )
    }
}
