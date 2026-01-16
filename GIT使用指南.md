# Git 使用指南 - 死了么项目

## 快速开始

项目已初始化 Git 仓库，当前提交: `1130b55 - 初始提交：完整的签到应用`

## 日常开发流程

### 1. 修改代码前

```bash
# 查看当前状态
git status

# 查看当前分支
git branch
```

### 2. 修改代码后

```bash
# 查看修改了什么
git status                    # 查看修改的文件
git diff                      # 查看具体修改内容

# 提交修改
git add .                     # 添加所有修改
git commit -m "描述你的修改"   # 提交

# 查看提交历史
git log --oneline
```

### 3. 回滚操作

#### 场景1: 刚修改文件，还没 add（撤销工作区修改）

```bash
git checkout -- CheckInView.swift    # 撤销单个文件
git checkout -- .                    # 撤销所有修改
```

#### 场景2: 已经 add，还没 commit（撤销暂存）

```bash
git reset HEAD CheckInView.swift     # 取消暂存单个文件
git reset HEAD .                     # 取消所有暂存
git checkout -- CheckInView.swift    # 然后撤销修改
```

#### 场景3: 已经 commit（回退提交）

```bash
# 先查看历史，找到要回退的版本
git log --oneline

# 软回退：保留代码修改，只撤销 commit
git reset --soft HEAD~1              # 回退1次提交
git reset --soft abc123              # 回退到指定提交

# 混合回退：保留代码修改，撤销 commit 和 add
git reset --mixed HEAD~1             # 默认模式

# 硬回退：完全删除修改（危险！慎用！）
git reset --hard HEAD~1              # 回退1次，删除所有修改
git reset --hard abc123              # 回退到指定版本

# 安全回退：创建新提交来撤销（推荐）
git revert HEAD                      # 撤销最后一次提交
git revert abc123                    # 撤销指定提交
```

## 常用命令速查

### 查看状态和历史

```bash
git status                           # 查看文件状态
git log --oneline                    # 简洁历史
git log --oneline --graph            # 图形化历史
git log -p CheckInView.swift         # 查看文件修改历史
git show abc123                      # 查看某次提交的内容
git diff                            # 查看未暂存的修改
git diff --staged                   # 查看已暂存的修改
```

### 暂存工作（临时保存修改）

```bash
git stash                           # 暂存当前修改
git stash list                      # 查看暂存列表
git stash pop                       # 恢复最近的暂存
git stash drop                      # 删除最近的暂存
```

### 分支操作

```bash
git branch                          # 查看所有分支
git branch feature-name             # 创建新分支
git checkout feature-name           # 切换分支
git checkout -b feature-name        # 创建并切换分支
git merge feature-name              # 合并分支到当前分支
git branch -d feature-name          # 删除分支
```

### 比较版本

```bash
git diff HEAD~1 HEAD                # 比较最近两次提交
git diff abc123 def456              # 比较两个提交
git diff master feature-name        # 比较两个分支
```

## 推荐的开发流程

### 开发新功能

```bash
# 1. 创建功能分支
git checkout -b feature-notification

# 2. 开发并提交
# ... 修改代码 ...
git add .
git commit -m "添加通知功能"

# 3. 合并回主分支
git checkout master
git merge feature-notification

# 4. 删除功能分支
git branch -d feature-notification
```

### 修复Bug

```bash
# 1. 创建修复分支
git checkout -b fix-signin-button

# 2. 修复并提交
# ... 修改代码 ...
git add .
git commit -m "修复签到按钮点击问题"

# 3. 合并回主分支
git checkout master
git merge fix-signin-button

# 4. 删除修复分支
git branch -d fix-signin-button
```

## 紧急情况处理

### 误删文件

```bash
git checkout -- 文件名              # 恢复单个文件
git checkout -- .                  # 恢复所有文件
```

### 想回到某个历史版本

```bash
# 1. 查看历史
git log --oneline

# 2. 创建新分支基于历史版本（安全）
git checkout -b restore-from-history abc123

# 3. 或直接重置（危险）
git reset --hard abc123
```

### 不小心 commit 了不该提交的文件

```bash
# 撤销最后一次提交，保留修改
git reset --soft HEAD~1

# 重新 add 正确的文件
git add 正确的文件
git commit -m "修正后的提交"
```

## 最佳实践

1. **经常提交**：小步提交，每个提交只做一件事
2. **描述清晰**：提交信息要描述"做了什么"，不是"改了什么文件"
3. **提交前检查**：使用 `git status` 和 `git diff` 确认修改
4. **使用分支**：新功能用新分支，主分支保持稳定
5. **定期查看历史**：`git log --oneline --graph` 了解项目进展

## 提交信息规范

```bash
# 好的提交信息示例
git commit -m "优化签到按钮尺寸，提升老年人可用性"
git commit -m "修复联系人列表显示问题"
git commit -m "添加签到统计图表功能"

# 不好的示例
git commit -m "修改"
git commit -m "更新文件"
git commit -m "fix bug"
```

## 常见问题

### Q: 如何撤销最近的提交？
A: `git reset --soft HEAD~1` (保留修改) 或 `git reset --hard HEAD~1` (删除修改)

### Q: 如何查看某个文件的修改历史？
A: `git log -p CheckInView.swift`

### Q: 如何恢复删除的文件？
A: `git checkout -- 文件名`

### Q: 如何暂时保存修改但不提交？
A: `git stash` (保存) 和 `git stash pop` (恢复)

### Q: 如何撤销某个历史提交？
A: `git revert 提交号` (创建新提交撤销) 或 `git reset --hard 提交号` (强制回退)
