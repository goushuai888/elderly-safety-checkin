//
//  AddElderlyView.swift
//  死了么
//
//  Created by shuai on 2026/1/16.
//

import SwiftUI
import CoreLocation

struct AddElderlyView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var isPresented: Bool
    let elderly: Elderly? // 编辑模式时传入，添加模式为 nil

    @State private var name: String
    @State private var phone: String
    @State private var address: String
    @State private var checkTime: Date
    @State private var homeCoordinate: CLLocationCoordinate2D? = nil
    @State private var showingMapPicker = false

    // 初始化方法，根据是否为编辑模式设置初始值
    init(isPresented: Binding<Bool>, elderly: Elderly?) {
        self._isPresented = isPresented
        self.elderly = elderly

        // 根据是否有 elderly 数据来初始化状态
        if let elderly = elderly {
            // 编辑模式：使用现有数据
            self._name = State(initialValue: elderly.name)
            self._phone = State(initialValue: elderly.phone)
            self._address = State(initialValue: elderly.address)

            // 解析时间字符串
            let timeComponents = elderly.checkTime.split(separator: ":").compactMap { Int($0) }
            if timeComponents.count == 2 {
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month, .day], from: Date())
                components.hour = timeComponents[0]
                components.minute = timeComponents[1]
                if let time = calendar.date(from: components) {
                    self._checkTime = State(initialValue: time)
                } else {
                    self._checkTime = State(initialValue: Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date())
                }
            } else {
                self._checkTime = State(initialValue: Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date())
            }

            // 加载坐标
            if let lat = elderly.homeLatitude, let lon = elderly.homeLongitude {
                self._homeCoordinate = State(initialValue: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
        } else {
            // 添加模式：使用默认值
            self._name = State(initialValue: "")
            self._phone = State(initialValue: "")
            self._address = State(initialValue: "")
            self._checkTime = State(initialValue: Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date())
        }
    }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var isEditMode: Bool {
        elderly != nil
    }

    var body: some View {
        let _ = print("AddElderlyView body - 姓名: \(name), 电话: \(phone), 编辑模式: \(isEditMode)")
        return NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("编辑老人信息")
                        .font(.title)
                        .padding()

                    VStack(alignment: .leading, spacing: 16) {
                        Text("姓名")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("请输入姓名", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("电话")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("请输入电话", text: $phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)

                        Text("住址")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("请输入住址", text: $address)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("提醒时间")
                            .font(.caption)
                            .foregroundColor(.gray)
                        DatePicker(
                            "",
                            selection: $checkTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                    }
                    .padding(.horizontal)

                    Button(action: saveElderly) {
                        Text("保存信息")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.5)
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle(isEditMode ? "编辑老人信息" : "添加老人信息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                    .foregroundColor(.gray)
                }
            }
        }
    }

    private func saveElderly() {
        // 将 Date 转换为 "HH:mm" 格式
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: checkTime)

        let updatedElderly = Elderly(
            id: elderly?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            phone: phone.trimmingCharacters(in: .whitespaces),
            address: address.trimmingCharacters(in: .whitespaces),
            homeLatitude: homeCoordinate?.latitude,
            homeLongitude: homeCoordinate?.longitude,
            checkTime: timeString
        )

        if isEditMode {
            dataManager.updateElderly(updatedElderly)
        } else {
            dataManager.addElderly(updatedElderly)
        }

        isPresented = false
    }
}

#Preview {
    AddElderlyView(isPresented: .constant(true), elderly: nil)
        .environmentObject(DataManager.shared)
}
