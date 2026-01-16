//
//  SettingsView.swift
//  死了么
//
//  Created by shuai on 2026/1/16.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddElderly = false
    @State private var showingEditElderly = false
    @State private var elderlyToEdit: Elderly?
    @State private var elderlyToDelete: Elderly?
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 老人信息卡片
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("老人信息")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "0F172A"))

                        Spacer()

                        Button(action: { showingAddElderly = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                Text("添加")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "0891B2"))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    if dataManager.elderly.isEmpty {
                        EmptyElderlyView(action: { showingAddElderly = true })
                            .padding(.horizontal, 20)
                    } else {
                        ForEach(dataManager.elderly) { person in
                            ElderlyCard(
                                elderly: person,
                                onEdit: {
                                    elderlyToEdit = person
                                    showingEditElderly = true
                                },
                                onDelete: {
                                    elderlyToDelete = person
                                    showDeleteConfirmation = true
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                }

                // 应用信息
                VStack(alignment: .leading, spacing: 16) {
                    Text("关于应用")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "0F172A"))
                        .padding(.horizontal, 20)

                    VStack(spacing: 12) {
                        InfoRow(icon: "info.circle.fill", label: "版本", value: "1.0.0", color: Color(hex: "0891B2"))
                        InfoRow(icon: "app.fill", label: "应用名称", value: "死了么", color: Color(hex: "059669"))
                        InfoRow(icon: "doc.text.fill", label: "应用描述", value: "独居老人安全签到系统", color: Color(hex: "F59E0B"))
                    }
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 20)
            }
            .padding(.vertical, 16)
        }
        .background(Color(hex: "F8FAFC"))
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAddElderly) {
            AddElderlyView(isPresented: $showingAddElderly)
        }
        .sheet(isPresented: $showingEditElderly) {
            if let elderly = elderlyToEdit {
                EditElderlyView(elderly: elderly, isPresented: $showingEditElderly)
            }
        }
        .alert("确认删除", isPresented: $showDeleteConfirmation) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let elderly = elderlyToDelete {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dataManager.deleteElderly(elderly)
                    }
                }
            }
        } message: {
            if let elderly = elderlyToDelete {
                Text("确定要删除 \(elderly.name) 的信息吗？此操作无法撤销。")
            }
        }
    }
}

// 空状态视图
struct EmptyElderlyView: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 56))
                .foregroundColor(Color(hex: "94A3B8"))

            Text("暂无老人信息")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "64748B"))

            Button(action: action) {
                Text("添加第一位老人")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "0891B2"), Color(hex: "0E7490")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

// 老人信息卡片
struct ElderlyCard: View {
    let elderly: Elderly
    let onEdit: () -> Void
    let onDelete: () -> Void
    @EnvironmentObject var dataManager: DataManager
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 顶部：姓名和状态
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "0891B2"), Color(hex: "06B6D4")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)

                        Text(String(elderly.name.prefix(1)))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(elderly.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "0F172A"))

                        if dataManager.hasCheckedInToday(elderlyId: elderly.id) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color(hex: "059669"))
                                    .frame(width: 8, height: 8)
                                Text("今日已签到")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "059669"))
                            }
                        } else {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color(hex: "F59E0B"))
                                    .frame(width: 8, height: 8)
                                Text("待签到")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "F59E0B"))
                            }
                        }
                    }
                }

                Spacer()

                Menu {
                    Button(action: onEdit) {
                        Label("编辑信息", systemImage: "pencil")
                    }

                    Button(role: .destructive, action: onDelete) {
                        Label("删除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "94A3B8"))
                }
            }

            // 分割线
            Divider()
                .background(Color(hex: "E2E8F0"))

            // 详细信息
            VStack(spacing: 12) {
                InfoDetailRow(icon: "phone.fill", label: "电话", value: elderly.phone, color: Color(hex: "0891B2"))

                if !elderly.address.isEmpty {
                    InfoDetailRow(icon: "house.fill", label: "住址", value: elderly.address, color: Color(hex: "059669"))
                }

                InfoDetailRow(icon: "clock.fill", label: "提醒时间", value: "每日 \(elderly.checkTime)", color: Color(hex: "F59E0B"))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

// 详细信息行
struct InfoDetailRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "94A3B8"))

                Text(value)
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "0F172A"))
            }

            Spacer()
        }
    }
}

// 信息行（关于部分）
struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "64748B"))

                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "0F172A"))
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// 编辑老人信息视图
struct EditElderlyView: View {
    let elderly: Elderly
    @EnvironmentObject var dataManager: DataManager
    @Binding var isPresented: Bool

    @State private var name: String
    @State private var phone: String
    @State private var address: String
    @State private var checkTime: String

    init(elderly: Elderly, isPresented: Binding<Bool>) {
        self.elderly = elderly
        self._isPresented = isPresented
        self._name = State(initialValue: elderly.name)
        self._phone = State(initialValue: elderly.phone)
        self._address = State(initialValue: elderly.address)
        self._checkTime = State(initialValue: elderly.checkTime)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 头像
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "0891B2"), Color(hex: "06B6D4")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Text(String(name.prefix(1)))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    // 表单
                    VStack(spacing: 16) {
                        FormField(
                            icon: "person.fill",
                            label: "姓名",
                            placeholder: "请输入姓名",
                            text: $name,
                            color: Color(hex: "0891B2")
                        )

                        FormField(
                            icon: "phone.fill",
                            label: "电话",
                            placeholder: "请输入电话",
                            text: $phone,
                            keyboardType: .phonePad,
                            color: Color(hex: "059669")
                        )

                        FormField(
                            icon: "house.fill",
                            label: "住址",
                            placeholder: "请输入住址（选填）",
                            text: $address,
                            color: Color(hex: "F59E0B")
                        )

                        FormField(
                            icon: "clock.fill",
                            label: "提醒时间",
                            placeholder: "HH:MM (如 20:00)",
                            text: $checkTime,
                            color: Color(hex: "8B5CF6")
                        )
                    }
                    .padding(.horizontal, 20)

                    // 保存按钮
                    Button(action: saveChanges) {
                        Text("保存修改")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "0891B2"), Color(hex: "0E7490")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color(hex: "0891B2").opacity(0.3), radius: 10, x: 0, y: 4)
                    }
                    .disabled(name.isEmpty || phone.isEmpty)
                    .opacity(name.isEmpty || phone.isEmpty ? 0.5 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .padding(.vertical, 16)
            }
            .background(Color(hex: "F8FAFC"))
            .navigationTitle("编辑信息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
        }
    }

    private func saveChanges() {
        var updatedElderly = elderly
        updatedElderly.name = name
        updatedElderly.phone = phone
        updatedElderly.address = address
        updatedElderly.checkTime = checkTime

        dataManager.updateElderly(updatedElderly)
        isPresented = false
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(DataManager.shared)
    }
}


