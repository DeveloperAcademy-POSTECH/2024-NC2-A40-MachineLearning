//
//  HomeView.swift
//  NC2
//
//  Created by DevJonny on 2024/6/17.
//

import SwiftUI

struct HomeView: View {
    @State private var isWeeklyView: Bool = false
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var showingSheet = false
    
    var body: some View {
        ZStack {
            // 플로팅 버튼
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        self.showingSheet.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(color: .gray, radius: 4, x: 2, y: 2)
                    }
                    .padding()
                }
            }
            VStack (spacing: 0) {
                // 상단바 영역
                ZStack {
                    HStack {
                        Spacer().frame(width: 10)
                        Image(.icon)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 35, alignment: .center) // 이미지의 위 아래 여백을 없애기 위해서 height는 35로 지정함 (원본 이미지에 여백 존재)
                            .clipped()
                        Spacer()
                    }
                    // 월 변경 및 표시
                    HStack (spacing: 0) {
                        Button(action: {
                            withAnimation {
                                isWeeklyView = false
                                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                                if isCurrentMonth(date: currentMonth) {
                                    selectedDate = Date()
                                } else {
                                    selectedDate = getLastDate(of: currentMonth)
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.SemiBold16)
                                .foregroundStyle(.black)
                                .padding(.horizontal)
                        }
                        Text(monthYearFormatter.string(from: currentMonth))
                            .font(.SemiBold18)
                            .foregroundStyle(.blue)
                        
                        Button(action: {
                            withAnimation {
                                isWeeklyView = false
                                currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                                if isCurrentMonth(date: currentMonth) {
                                    selectedDate = Date()
                                } else {
                                    selectedDate = getLastDate(of: currentMonth)
                                }
                            }
                            
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.SemiBold16)
                                .foregroundStyle(isFutureMonth(date: Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth) ? Color.darkGray : .black)
                                .padding(.horizontal)
                        }
                        .disabled(isFutureMonth(date: Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth))
                    }
                    .padding(.horizontal)
                }
                //커스텀 캘린더 뷰
                Divider()
                    .padding(.horizontal, 26)
                    .padding(.vertical, 10)
                // 요일 표시
                HStack(spacing: 0) {
                    ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                        Text(day)
                            .font(.Medium12)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 5)
                .padding(.horizontal, 20)
                CalendarView(isWeeklyView: $isWeeklyView, currentMonth: $currentMonth, selectedDate: $selectedDate)
                    .gesture(
                        DragGesture().onChanged { value in
                            if value.translation.height < -50 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isWeeklyView = true
                                }
                            } else if value.translation.height > 50 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isWeeklyView = false
                                }
                            }
                        }
                    )
                    .padding(.bottom, 12)
                HStack {
                    Spacer()
                    VStack {
                        HStack (spacing: 0) {
                            Text(monthFormatter.string(from: currentMonth) + "월 ").font(.Light12)
                            Text("지출").font(.Light12).foregroundColor(.customRed)
                        }
                        .padding(.bottom, 1)
                        Text("230,000").font(.Medium16).foregroundColor(.darkGray)
                    }
                    Spacer()
                    Divider()
                        .frame(height: 60)
                        .background(Color.darkGray)
                    Spacer()
                    VStack {
                        HStack (spacing: 0) {
                            Text(monthFormatter.string(from: currentMonth) + "월 ").font(.Light12)
                            Text("수입").font(.Light12).foregroundColor(.customGreen)
                        }
                        .padding(.bottom, 1)
                        Text("230,000").font(.Medium16).foregroundColor(.customGreen)
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(Color.lightGray)
                .cornerRadius(10)
                .padding(.horizontal, 26)
                Spacer()
                
            }
        }
        .sheet(isPresented: $showingSheet) {
            DetailSheet()
        }
    }
}

#Preview {
    HomeView()
}


struct CalendarView: View {
    @Binding var isWeeklyView: Bool
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    
    @State var dayCellHeight: CGFloat = 60
    
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
                    WeekView(week: week, selectedDate: $selectedDate, isWeeklyView: $isWeeklyView, dayCellHeight: $dayCellHeight)
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
    
    var body: some View {
        HStack (spacing: 0) {
            ForEach(week, id: \.self) { date in
                VStack (spacing: 0) {
                    if Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month) {
                        Text(dayFormatter.string(from: date))
                            .font(.Medium16)
                            .foregroundColor(isPastOrToday(date: date) ? (Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white : .black) : .darkGray)
                            .frame(width: 30, height: 30) // 원의 크기 설정
                            .background(
                                Circle()
                                    .fill(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .customBlue : Color.clear)
                            )
                        Text("+3000")
                            .font(.Medium10)
                            .foregroundColor(.customGreen)
                        Text("-3000")
                            .font(.Medium10)
                            .foregroundColor(.darkGray)
                    } else {
                        Text("")
                            .frame(maxWidth: .infinity)
                    }
                }
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
}

// Helper functions
private func isPastOrToday(date: Date) -> Bool {
    return Calendar.current.compare(date, to: Date(), toGranularity: .day) != .orderedDescending
}

private func isFutureMonth(date: Date) -> Bool {
    return Calendar.current.compare(date, to: Date(), toGranularity: .month) == .orderedDescending
}

private func isCurrentMonth(date: Date) -> Bool {
    return Calendar.current.compare(date, to: Date(), toGranularity: .month) == .orderedSame
}

// Date formatters
private let monthYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 M월"
    return formatter
}()

private let monthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M"
    return formatter
}()

private let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter
}()

private func getLastDate(of date: Date) -> Date {
    var components = Calendar.current.dateComponents([.year, .month], from: date)
    components.day = Calendar.current.range(of: .day, in: .month, for: date)?.count
    return Calendar.current.date(from: components) ?? date
}
