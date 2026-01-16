//
//  ContentView.swift
//  死了么
//
//  Created by shuai on 2026/1/16.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    @State private var showingAddElderly = false

    var body: some View {
        Group {
            if dataManager.elderly.isEmpty {
                // 欢迎页面
                WelcomeView(showingAddElderly: $showingAddElderly)
            } else {
                // 主界面 - 自定义底部导航
                ZStack {
                    // 背景色
                    AppTheme.Colors.background
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        // 内容区域
                        ZStack {
                            if selectedTab == 0 {
                                NavigationView {
                                    if let firstElderly = dataManager.elderly.first {
                                        CheckInView(elderly: firstElderly)
                                    }
                                }
                                .transition(.opacity)
                            } else {
                                NavigationView {
                                    SettingsView()
                                }
                                .transition(.opacity)
                            }
                        }

                        // 自定义底部导航栏
                        CustomTabBar(selectedTab: $selectedTab)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddElderly) {
            AddElderlyView(isPresented: $showingAddElderly)
        }
    }
}

// MARK: - Custom Tab Bar
/// 自定义底部导航栏 - 老年人友好设计
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            // 签到标签
            TabBarButton(
                icon: "checkmark.circle.fill",
                title: "签到",
                isSelected: selectedTab == 0,
                color: AppTheme.Colors.primary,
                namespace: animation
            ) {
                HapticFeedback.selection()
                withAnimation(AppTheme.Animation.standard) {
                    selectedTab = 0
                }
            }

            // 设置标签
            TabBarButton(
                icon: "gearshape.fill",
                title: "设置",
                isSelected: selectedTab == 1,
                color: AppTheme.Colors.purple,
                namespace: animation
            ) {
                HapticFeedback.selection()
                withAnimation(AppTheme.Animation.standard) {
                    selectedTab = 1
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
        .padding(.top, AppTheme.Spacing.sm)
        .padding(.bottom, AppTheme.Spacing.xs)
        .background(
            // 背景模糊效果
            Rectangle()
                .fill(.ultraThinMaterial)
                .shadow(
                    color: AppTheme.Colors.shadow,
                    radius: 20,
                    x: 0,
                    y: -4
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Tab Bar Button
/// 底部导航按钮 - 大触控区域
struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let color: Color
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        // 选中状态的背景
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .fill(color.opacity(0.15))
                            .frame(width: 72, height: 44)
                            .matchedGeometryEffect(id: "TAB_BACKGROUND", in: namespace)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(isSelected ? color : AppTheme.Colors.textPlaceholder)
                }
                .frame(height: 44)

                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? color : AppTheme.Colors.textPlaceholder)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppTheme.Size.touchTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibleButton(label: title, hint: isSelected ? "当前选中" : "双击切换到\(title)")
    }
}

// MARK: - Welcome View
/// 欢迎页面 - 老年人友好的大字体和清晰设计
struct WelcomeView: View {
    @Binding var showingAddElderly: Bool
    @State private var isAnimated = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [
                    AppTheme.Colors.primarySoft,
                    AppTheme.Colors.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xxl) {
                Spacer()

                // Logo 区域
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 动画心形图标
                    ZStack {
                        // 背景光晕
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        AppTheme.Colors.pink.opacity(0.2),
                                        AppTheme.Colors.pink.opacity(0)
                                    ],
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .scaleEffect(isAnimated ? 1.1 : 1.0)
                            .animation(
                                reduceMotion ? nil : Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                                value: isAnimated
                            )

                        // 主图标
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 120, weight: .regular))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.Colors.pink, AppTheme.Colors.danger],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: AppTheme.Colors.pink.opacity(0.3), radius: 20, x: 0, y: 10)
                    }

                    // 标题
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text("欢迎使用")
                            .font(AppTheme.Typography.title2)
                            .foregroundColor(AppTheme.Colors.textSecondary)

                        Text("死了么")
                            .font(AppTheme.Typography.largeTitle)
                            .foregroundColor(AppTheme.Colors.text)
                    }

                    // 副标题
                    Text("独居老人安全签到系统")
                        .font(AppTheme.Typography.bodyLarge)
                        .foregroundColor(AppTheme.Colors.textMuted)
                }

                Spacer()

                // 底部操作区域
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 提示文字
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.Colors.primary)

                        Text("请先添加老人信息开始使用")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(AppTheme.Colors.primarySoft)
                    )

                    // 添加按钮
                    Button(action: {
                        HapticFeedback.medium()
                        showingAddElderly = true
                    }) {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24, weight: .semibold))

                            Text("添加老人信息")
                                .font(AppTheme.Typography.buttonLarge)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Size.buttonXLarge)
                        .background(
                            ZStack {
                                LinearGradient.primary
                                LinearGradient.softOverlay
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                        .shadow(
                            color: AppTheme.Colors.primary.opacity(0.4),
                            radius: 16,
                            x: 0,
                            y: 8
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, AppTheme.Spacing.xxl)
                    .accessibleButton(label: "添加老人信息", hint: "点击添加第一位老人的信息")
                }

                Spacer()
                    .frame(height: AppTheme.Spacing.xxxl)
            }
            .padding(AppTheme.Spacing.pagePadding)
        }
        .onAppear {
            if !reduceMotion {
                isAnimated = true
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager.shared)
}
