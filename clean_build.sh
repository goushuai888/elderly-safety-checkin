#!/bin/bash

# 清理并重建 iOS 项目脚本

PROJECT_DIR="/Users/shuai/wwwroot/死了么"
cd "$PROJECT_DIR"

echo "🧹 开始清理项目..."

# 1. 删除 DerivedData
echo "删除 DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/死了么-*

# 2. 清理构建文件夹
echo "清理构建文件夹..."
rm -rf build/
rm -rf .build/

# 3. 清理 Xcode 缓存
echo "清理 Xcode 缓存..."
rm -rf ~/Library/Caches/com.apple.dt.Xcode

# 4. 重置包缓存
echo "重置 Swift 包缓存..."
rm -rf ~/.swiftpm/

echo "✅ 清理完成！"
echo ""
echo "📝 接下来请在 Xcode 中："
echo "1. 打开项目：open '死了么.xcodeproj'"
echo "2. 按 Shift+Cmd+K 执行 Clean Build Folder"
echo "3. 按 Cmd+B 重新编译"
echo "4. 按 Cmd+R 运行应用"
echo ""
echo "如果还有问题，请关闭 Xcode 后重新打开项目。"
