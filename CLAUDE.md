# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

"死了么"是一款专为独居老人设计的安全签到iOS应用,使用SwiftUI构建。通过每日签到机制确保老人安全,如果老人未按时签到,系统会发送本地通知提醒。

## 构建和运行

### 开发环境要求
- Xcode 15.0+
- iOS 15.0+
- Swift 5.9+
- macOS (用于iOS开发)

### 构建项目
```bash
# 在Xcode中打开项目
open 死了么.xcodeproj

# 或使用xcodebuild命令行构建
xcodebuild -project 死了么.xcodeproj -scheme 死了么 -configuration Debug
```

### 运行项目
- 在Xcode中选择模拟器或真机
- 按 Cmd+R 运行项目
- 首次运行时应用会请求通知权限

### 测试
目前项目没有单元测试。如需添加测试:
```bash
xcodebuild test -project 死了么.xcodeproj -scheme 死了么 -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 架构设计

### 核心架构模式

项目采用 **MVVM (Model-View-ViewModel)** 架构,结合 SwiftUI 的响应式特性:

1. **单例数据管理器**
   - `DataManager.shared` 是全局单例,管理所有应用数据
   - 使用 `@Published` 属性实现响应式数据绑定
   - 通过 `.environmentObject()` 注入到视图层次结构中

2. **数据持久化策略**
   - 使用 `UserDefaults` 存储所有数据(老人信息、联系人、签到记录、通知记录)
   - 所有模型遵循 `Codable` 协议,使用 `JSONEncoder/JSONDecoder` 序列化
   - 数据在 `DataManager` 初始化时自动加载,修改后立即保存

3. **通知系统架构**
   - 使用 `UserNotifications` 框架实现本地通知
   - 每位老人有独立的每日定时通知(基于 `UNCalendarNotificationTrigger`)
   - 通知标识符格式: `"check-{elderlyId}"`
   - 修改老人信息时会自动取消旧通知并创建新通知

### 数据模型关系

```
Elderly (老人)
  ├── id: UUID
  ├── name, phone, address
  ├── checkTime: String (格式 "HH:mm")
  └── 关联数据:
      ├── EmergencyContact[] (多个紧急联系人,通过 elderlyId 关联)
      ├── CheckInRecord[] (签到记录,通过 elderlyId 关联)
      └── NotificationRecord[] (通知记录,通过 elderlyId 关联)
```

### 设计系统 (Theme.swift)

项目实现了完整的设计系统,专为老年人优化:

- **AppTheme.Colors**: 完整的颜色系统(主色、成功、警告、危险等)
- **AppTheme.Typography**: 字体系统,使用 `.rounded` 设计,最小16pt确保可读性
- **AppTheme.Spacing**: 标准化间距系统(从4pt到40pt)
- **AppTheme.Radius**: 圆角系统(从8pt到full circle)
- **AppTheme.Shadows**: 阴影预设
- **AppTheme.Animation**: 动画预设(使用spring动画)
- **AppTheme.Size**: 尺寸规范,触控目标最小48pt(WCAG建议)

所有UI组件应使用 `AppTheme` 中的值,避免硬编码。

### 可重用UI组件 (Extensions.swift)

项目包含大量可重用组件,新功能应优先使用这些组件:

- `FormField`: 表单输入字段,带图标和聚焦状态
- `IconButton`: 圆形图标按钮
- `GradientIconCircle` / `SoftIconCircle`: 图标容器
- `StatusBadge`: 状态徽章
- `InfoRowView`: 信息展示行
- `EmptyStateView`: 空状态视图
- `SectionHeader`: 区块标题
- `AvatarView`: 头像视图
- `TipCard`: 提示卡片
- `LoadingIndicator`: 加载指示器

View扩展方法:
- `.cardStyle()`: 卡片样式
- `.primaryButtonStyle()`: 主要按钮样式
- `.secondaryButtonStyle()`: 次要按钮样式
- `.accessibleButton()`: 无障碍按钮
- `.seniorFriendlyTouchTarget()`: 老年人友好触控区域

### 视图层结构

主要视图和职责:

- `ContentView`: 主界面,显示老人列表
- `AddElderlyView`: 添加/编辑老人信息表单
- `CheckInView`: 签到界面,包含大型签到按钮
- `ContactsView`: 紧急联系人管理
- `HistoryView`: 签到记录和统计
- `SettingsView`: 应用设置

所有视图通过 `@EnvironmentObject var dataManager: DataManager` 访问数据。

## 开发指南

### 添加新功能时的注意事项

1. **数据持久化**: 如果添加新的数据模型,必须:
   - 使模型遵循 `Codable`, `Identifiable`, `Hashable`
   - 在 `DataManager` 中添加 `@Published` 属性
   - 在 `loadData()` 和 `saveData()` 方法中添加序列化逻辑

2. **UI设计原则**:
   - 使用 `AppTheme` 中的设计token,不要硬编码颜色、字体、间距
   - 确保触控目标至少48x48pt(老年人友好)
   - 使用大字体(最小16pt)和高对比度颜色
   - 添加触觉反馈 (`HapticFeedback` 工具类)
   - 考虑无障碍支持(使用 `.accessibleButton()` 等)

3. **通知相关**:
   - 修改通知逻辑时注意要先取消旧通知(`cancelNotifications`)
   - 通知标识符必须唯一且可追溯
   - 测试通知权限请求和拒绝场景

4. **代码风格**:
   - 使用 `// MARK: -` 组织代码区块
   - 视图组件使用 `struct` 而不是 `class`
   - 优先使用 SwiftUI 内置组件和修饰符
   - 动画使用 `AppTheme.Animation` 预设

### 常见任务

**添加新的数据字段**:
1. 在 `Models.swift` 中更新模型定义
2. 在相关视图中添加UI控件
3. 更新 `DataManager` 的相关方法
4. 测试数据保存和加载是否正常

**修改设计样式**:
1. 优先在 `Theme.swift` 中调整设计token
2. 如果需要新的组件,在 `Extensions.swift` 中实现可重用组件
3. 确保修改不影响老年人的可读性和可用性

**调试通知**:
- 在模拟器中测试通知可能不稳定,建议使用真机
- 检查系统设置中的通知权限
- 使用 `UNUserNotificationCenter.current().getPendingNotificationRequests()` 检查待处理通知

## 项目特点

### 老年人友好设计

这是本应用的核心设计理念,所有改动必须考虑:
- **大字体**: 最小16pt,关键按钮使用26pt
- **高对比度**: 使用深色文本配浅色背景
- **大触控区域**: 最小48x48pt,签到按钮达到88pt
- **清晰的视觉层次**: 使用颜色和大小区分重要性
- **简单的操作流程**: 避免多步骤操作,减少认知负担
- **友好的反馈**: 使用触觉反馈和清晰的视觉提示

### 数据安全和隐私

- 所有数据存储在本地设备上,不涉及网络传输
- 使用 `UserDefaults` 存储,受iOS沙箱保护
- 未来如需添加云同步,必须:
  - 实现端到端加密
  - 遵守隐私法规(GDPR, 个人信息保护法等)
  - 添加明确的用户同意流程
