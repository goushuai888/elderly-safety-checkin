//
//  HistoryView.swift
//  死了么
//
//  Created by shuai on 2026/1/16.
//

import SwiftUI

struct HistoryView: View {
    let elderly: Elderly
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @State private var currentMonth = Date()
    @State private var selectedDate: Date?

    var history: [CheckInRecord] {
        dataManager.getCheckInHistory(for: elderly.id, limit: 9999)
    }

    var stats: (total: Int, last7Days: Int, last30Days: Int) {
        dataManager.getCheckInStats(for: elderly.id)
    }

    // 获取当前月份的签到日期集合
    var checkedInDates: Set<String> {
        Set(history.map { record in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: record.checkInTime)
        })
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 统计卡片
                    VStack(spacing: 15) {
                        Text("签到统计")
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 15) {
                            StatsCard(title: "总签到", value: "\(stats.total)", color: .blue)
                            StatsCard(title: "最近7天", value: "\(stats.last7Days)", color: .green)
                            StatsCard(title: "最近30天", value: "\(stats.last30Days)", color: .orange)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // 月历视图
                    CalendarView(
                        currentMonth: $currentMonth,
                        selectedDate: $selectedDate,
                        checkedInDates: checkedInDates
                    )
                    .padding(.horizontal)

                    // 选中日期的详细信息
                    if let selected = selectedDate,
                       let record = getRecord(for: selected) {
                        CheckInDetailCard(record: record)
                            .padding(.horizontal)

                        // 地图显示
                        CheckInMapView(elderly: elderly, record: record)
                            .padding(.horizontal)
                            .padding(.bottom, AppTheme.Spacing.md)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("签到记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func getRecord(for date: Date) -> CheckInRecord? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        return history.first { record in
            formatter.string(from: record.checkInTime) == dateString
        }
    }
}

// 统计卡片
struct StatsCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: color.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// 月历视图
struct CalendarView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date?
    let checkedInDates: Set<String>

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        return formatter.string(from: currentMonth)
    }

    private var days: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else { return [] }

        let startDate = monthFirstWeek.start
        let endDate = monthLastWeek.end
        var dates: [Date] = []
        var currentDate = startDate

        while currentDate < endDate {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return dates
    }

    var body: some View {
        VStack(spacing: 15) {
            // 月份选择器
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal)

            // 星期标题
            HStack(spacing: 0) {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // 日历网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 5) {
                ForEach(days, id: \.self) { date in
                    CalendarDayCell(
                        date: date,
                        currentMonth: currentMonth,
                        isCheckedIn: isCheckedIn(date),
                        isSelected: isSameDay(date, selectedDate),
                        isToday: isSameDay(date, Date())
                    )
                    .onTapGesture {
                        if isCheckedIn(date) {
                            selectedDate = date
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }

    private func isCheckedIn(_ date: Date) -> Bool {
        checkedInDates.contains(dateFormatter.string(from: date))
    }

    private func isSameDay(_ date1: Date, _ date2: Date?) -> Bool {
        guard let date2 = date2 else { return false }
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    private func previousMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        currentMonth = newMonth
        selectedDate = nil
    }

    private func nextMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        currentMonth = newMonth
        selectedDate = nil
    }
}

// 日历单元格
struct CalendarDayCell: View {
    let date: Date
    let currentMonth: Date
    let isCheckedIn: Bool
    let isSelected: Bool
    let isToday: Bool

    private let calendar = Calendar.current

    private var day: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private var isInCurrentMonth: Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(day)
                .font(.system(size: 16, weight: isToday ? .bold : .regular))
                .foregroundColor(textColor)

            // 签到指示器
            if isCheckedIn {
                Circle()
                    .fill(isSelected ? Color.blue : Color.green)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
        )
    }

    private var textColor: Color {
        if !isInCurrentMonth {
            return .gray.opacity(0.3)
        } else if isSelected {
            return .white
        } else {
            return .primary
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return .blue.opacity(0.8)
        } else if isCheckedIn {
            return .green.opacity(0.1)
        } else {
            return .clear
        }
    }
}

// 签到详情卡片
struct CheckInDetailCard: View {
    let record: CheckInRecord

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("签到详情")
                .font(.headline)
                .foregroundColor(.primary)

            HStack(spacing: 15) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)

                VStack(alignment: .leading, spacing: 8) {
                    Text(dateFormatter.string(from: record.checkInTime))
                        .font(.title3)
                        .fontWeight(.semibold)

                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("签到时间: \(timeFormatter.string(from: record.checkInTime))")
                            .font(.subheadline)
                    }

                    if !record.note.isEmpty {
                        HStack(alignment: .top) {
                            Image(systemName: "note.text")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text(record.note)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.green.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
}


#Preview {
    HistoryView(elderly: Elderly(
        name: "张奶奶",
        phone: "13800138000",
        address: "北京市朝阳区"
    ))
    .environmentObject(DataManager.shared)
}
