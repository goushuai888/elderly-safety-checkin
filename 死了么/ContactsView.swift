//
//  ContactsView.swift
//  死了么
//
//  Created by shuai on 2026/1/16.
//

import SwiftUI

struct ContactsView: View {
    let elderly: Elderly
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @State private var showingAddContact = false

    var contacts: [EmergencyContact] {
        dataManager.getContacts(for: elderly.id)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    if contacts.isEmpty {
                        EmptyStateView(
                            icon: "person.2.crop.square.stack",
                            title: "暂无紧急联系人",
                            subtitle: "添加紧急联系人，在需要时可以快速联系",
                            buttonTitle: "添加联系人",
                            buttonColor: AppTheme.Colors.pink,
                            action: { showingAddContact = true }
                        )
                        .padding(.horizontal, AppTheme.Spacing.pagePadding)
                        .padding(.top, AppTheme.Spacing.xxxl)
                    } else {
                        ForEach(contacts) { contact in
                            ContactCard(contact: contact, onDelete: {
                                withAnimation(AppTheme.Animation.standard) {
                                    dataManager.deleteContact(contact)
                                }
                            })
                            .padding(.horizontal, AppTheme.Spacing.pagePadding)
                        }
                    }
                }
                .padding(.vertical, AppTheme.Spacing.md)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("紧急联系人")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(AppTheme.Colors.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddContact = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppTheme.Colors.pink)
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                AddContactView(elderly: elderly, isPresented: $showingAddContact)
            }
        }
    }
}

// MARK: - Contact Card
/// 联系人卡片
struct ContactCard: View {
    let contact: EmergencyContact
    let onDelete: () -> Void
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // 顶部：姓名和关系
            HStack {
                HStack(spacing: AppTheme.Spacing.sm) {
                    // 头像
                    SoftIconCircle(
                        icon: relationshipIcon,
                        color: relationshipColor,
                        size: 48,
                        iconSize: 22
                    )

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                        Text(contact.name)
                            .font(AppTheme.Typography.bodyBold)
                            .foregroundColor(AppTheme.Colors.text)

                        if !contact.relationship.isEmpty {
                            StatusBadge(
                                text: contact.relationship,
                                color: relationshipColor,
                                showDot: false
                            )
                        }
                    }
                }

                Spacer()

                // 删除按钮
                IconButton(
                    icon: "trash.circle.fill",
                    color: AppTheme.Colors.danger,
                    size: 40,
                    iconSize: 22
                ) {
                    showDeleteAlert = true
                }
            }

            DividerLine()

            // 联系方式
            VStack(spacing: AppTheme.Spacing.sm) {
                InfoRowView(
                    icon: "phone.fill",
                    label: "电话",
                    value: contact.phone,
                    color: AppTheme.Colors.success
                )

                if !contact.email.isEmpty {
                    InfoRowView(
                        icon: "envelope.fill",
                        label: "邮箱",
                        value: contact.email,
                        color: AppTheme.Colors.primary
                    )
                }
            }
        }
        .cardStyle()
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                HapticFeedback.warning()
                onDelete()
            }
        } message: {
            Text("确定要删除 \(contact.name) 吗？")
        }
    }

    private var relationshipColor: Color {
        switch contact.relationship {
        case "儿子", "女儿":
            return AppTheme.Colors.primary
        case "配偶":
            return AppTheme.Colors.pink
        case "兄弟", "姐妹":
            return AppTheme.Colors.purple
        case "邻居":
            return AppTheme.Colors.success
        case "朋友":
            return AppTheme.Colors.warning
        case "护工":
            return AppTheme.Colors.cyan
        default:
            return AppTheme.Colors.textMuted
        }
    }

    private var relationshipIcon: String {
        switch contact.relationship {
        case "儿子", "女儿":
            return "figure.2.and.child.holdinghands"
        case "配偶":
            return "heart.fill"
        case "兄弟", "姐妹":
            return "person.2.fill"
        case "邻居":
            return "house.fill"
        case "朋友":
            return "person.fill"
        case "护工":
            return "cross.case.fill"
        default:
            return "person.circle.fill"
        }
    }
}

// MARK: - Add Contact View
/// 添加联系人视图
struct AddContactView: View {
    let elderly: Elderly
    @EnvironmentObject var dataManager: DataManager
    @Binding var isPresented: Bool

    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var relationship = "儿子"

    let relationshipOptions = ["儿子", "女儿", "配偶", "兄弟", "姐妹", "邻居", "朋友", "护工", "其他"]

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.sectionSpacing) {
                    // 头像
                    GradientIconCircle(
                        icon: "person.fill.badge.plus",
                        colors: [AppTheme.Colors.pink, AppTheme.Colors.danger],
                        size: AppTheme.Size.avatarXLarge,
                        iconSize: 36
                    )
                    .padding(.top, AppTheme.Spacing.lg)

                    // 表单
                    VStack(spacing: AppTheme.Spacing.md) {
                        FormField(
                            icon: "person.fill",
                            label: "姓名",
                            placeholder: "请输入联系人姓名",
                            text: $name,
                            color: AppTheme.Colors.pink
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
                            icon: "envelope.fill",
                            label: "邮箱（选填）",
                            placeholder: "请输入邮箱地址",
                            text: $email,
                            keyboardType: .emailAddress,
                            color: AppTheme.Colors.primary
                        )

                        // 关系选择器
                        RelationshipPicker(
                            selectedRelationship: $relationship,
                            options: relationshipOptions
                        )
                    }
                    .padding(.horizontal, AppTheme.Spacing.pagePadding)

                    // 保存按钮
                    Button(action: saveContact) {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                            Text("保存联系人")
                        }
                        .font(AppTheme.Typography.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Size.buttonLarge)
                        .background(
                            ZStack {
                                LinearGradient.pink
                                LinearGradient.softOverlay
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                        .shadow(
                            color: AppTheme.Colors.pink.opacity(0.35),
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
            .navigationTitle("添加紧急联系人")
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

    private func saveContact() {
        HapticFeedback.success()
        let contact = EmergencyContact(
            elderlyId: elderly.id,
            name: name.trimmingCharacters(in: .whitespaces),
            phone: phone.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            relationship: relationship
        )
        dataManager.addContact(contact)
        isPresented = false
    }
}

// MARK: - Relationship Picker
/// 关系选择器
struct RelationshipPicker: View {
    @Binding var selectedRelationship: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.purple)

                Text("关系")
                    .font(AppTheme.Typography.captionBold)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: { selectedRelationship = option }) {
                        HStack {
                            Text(option)
                            if selectedRelationship == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedRelationship)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.text)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textPlaceholder)
                }
                .padding(AppTheme.Spacing.md)
                .frame(minHeight: AppTheme.Size.inputHeight)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                        .fill(AppTheme.Colors.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                                .stroke(AppTheme.Colors.border, lineWidth: 1)
                        )
                )
            }
        }
    }
}

#Preview {
    ContactsView(elderly: Elderly(
        name: "张奶奶",
        phone: "13800138000",
        address: "北京市朝阳区"
    ))
    .environmentObject(DataManager.shared)
}
