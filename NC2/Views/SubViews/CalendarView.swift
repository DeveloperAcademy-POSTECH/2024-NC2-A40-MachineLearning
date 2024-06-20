//
//  CalendarView.swift
//  NC2
//
//  Created by DevJonny on 2024/6/18.
//

import SwiftUI

struct CalendarView: View {
    @Environment (\.modelContext) var context
    
    @Binding var isWeeklyView: Bool
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    
    @State var dayCellHeight: CGFloat = 60
    
    var transactions: [Transaction]
    
    private var weeksInMonth: [[Date]] {
        var weeks: [[Date]] = [[]]
        var currentWeek = 0
        
        for date in daysWithPadding {
            let weekday = Calendar.current.component(.weekday, from: date)
            if weekday == 1 && !weeks[currentWeek].isEmpty {
                currentWeek += 1
                weeks.append([])
            }
            weeks[currentWeek].append(date)
        }
        return weeks
    }
    
    private var daysWithPadding: [Date] {
        var days: [Date] = []
        let calendar = Calendar.current
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        let daysInMonthRange = calendar.range(of: .day, in: .month, for: currentMonth)!
        
        // Previous month's padding
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)!.count
            let startDay = daysInPreviousMonth - firstWeekday + 1
            if startDay > 0 && startDay <= daysInPreviousMonth {
                for day in startDay...daysInPreviousMonth {
                    var components = calendar.dateComponents([.year, .month], from: previousMonth)
                    components.day = day
                    if let date = calendar.date(from: components) {
                        days.append(date)
                    }
                }
            }
        }
        
        // Current month's days
        for day in daysInMonthRange {
            var components = calendar.dateComponents([.year, .month], from: currentMonth)
            components.day = day
            if let date = calendar.date(from: components) {
                days.append(date)
            }
        }
        
        // Next month's padding
        let remainingDays = 7 - (days.count % 7)
        if remainingDays < 7, let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            for day in 1...remainingDays {
                var components = calendar.dateComponents([.year, .month], from: nextMonth)
                components.day = day
                if let date = calendar.date(from: components) {
                    days.append(date)
                }
            }
        }
        
        return days
    }
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(weeksInMonth.indices, id: \.self) { index in
                    let week = weeksInMonth[index]
                    WeekView(week: week, selectedDate: $selectedDate, isWeeklyView: $isWeeklyView, dayCellHeight: $dayCellHeight, transactions: transactions)
                        .zIndex(week.contains(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) }) ? 1 : 0)
                        .offset(y: isWeeklyView ? 0 : CGFloat(index) * dayCellHeight)
                        .animation(.easeInOut(duration: 0.3), value: isWeeklyView)
                }
            }
            Spacer()
        }
        .frame(height: isWeeklyView ? dayCellHeight : CGFloat(weeksInMonth.count) * dayCellHeight)
        .padding(.top, 14)
        .padding(.horizontal, 20)
    }
}

struct WeekView: View {
    var week: [Date] = []
    @Binding var selectedDate: Date
    @Binding var isWeeklyView: Bool
    @Binding var dayCellHeight: CGFloat
    
    var transactions: [Transaction]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(week, id: \.self) { date in
                dayView(for: date)
                    .frame(maxWidth: .infinity)
                    .frame(height: dayCellHeight)
                    .onTapGesture {
                        if isPastOrToday(date: date) {
                            selectedDate = date
                        }
                    }
            }
        }
        .frame(height: dayCellHeight)
        .background(Color(.white))
    }
    
    private func dayView(for date: Date) -> some View {
        let transactionsForDate = transactions(for: date)
        let totalIncome = transactionsForDate.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
        let totalOutcome = transactionsForDate.filter { $0.transactionType == .outcome }.reduce(0) { $0 + $1.amount }
        
        return VStack(spacing: 0) {
            if Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month) {
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isPastOrToday(date: date) ? (Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white : .black) : .gray)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.blue : Color.clear)
                    )
                    .padding(.bottom, 4)
                if totalIncome > 0 {
                    Text("+\(totalIncome)")
                        .font(.Medium8)
                        .foregroundColor(.customGreen)
                }
                if totalOutcome > 0 {
                    Text("-\(totalOutcome)")
                        .font(.Medium8)
                        .foregroundColor(.darkGray)
                }
                Spacer()
            } else {
                VStack (spacing: 0) {
                    Text("")
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
        }
    }
    
    private func transactions(for date: Date) -> [Transaction] {
        let calendar = Calendar.current
        return transactions.filter { calendar.isDate($0.displayDate, inSameDayAs: date) }
    }
}

// Helper functions
func isPastOrToday(date: Date) -> Bool {
    return Calendar.current.compare(date, to: Date(), toGranularity: .day) != .orderedDescending
}

func isFutureMonth(date: Date) -> Bool {
    return Calendar.current.compare(date, to: Date(), toGranularity: .month) == .orderedDescending
}

func isCurrentMonth(date: Date) -> Bool {
    return Calendar.current.compare(date, to: Date(), toGranularity: .month) == .orderedSame
}

// Date formatters
let monthYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = NSLocalizedString("yyyy년 M월", comment: "")
    return formatter
}()

let monthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M"
    return formatter
}()

let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter
}()

func getLastDate(of date: Date) -> Date {
    var components = Calendar.current.dateComponents([.year, .month], from: date)
    components.day = Calendar.current.range(of: .day, in: .month, for: date)?.count
    return Calendar.current.date(from: components) ?? date
}
