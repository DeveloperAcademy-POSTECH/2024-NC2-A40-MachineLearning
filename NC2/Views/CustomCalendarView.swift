import SwiftUI

struct CustomCalendarView: View {
    @State private var isWeeklyView: Bool = false
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        VStack {
            // 월 변경 및 표시
            HStack {
                Button(action: {
                    withAnimation {
                        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        selectedDate = getLastDate(of: currentMonth)
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .padding()
                }
                Spacer()
                Text(monthYearFormatter.string(from: currentMonth))
                    .font(.headline)
                Spacer()
                Button(action: {
                    withAnimation {
                        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        selectedDate = getLastDate(of: currentMonth)
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .padding()
                }
            }
            .padding(.horizontal)
            
            // 커스텀 캘린더 뷰
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
            
            // 리스트 뷰
            ListView()
                .gesture(
                    DragGesture().onChanged { value in
                        if value.translation.height > 50 {
                            withAnimation {
                                isWeeklyView = false
                            }
                        }
                    }
                )
        }
    }
    
    private func getLastDate(of date: Date) -> Date {
        var components = Calendar.current.dateComponents([.year, .month], from: date)
        components.day = Calendar.current.range(of: .day, in: .month, for: date)?.count
        return Calendar.current.date(from: components) ?? date
    }
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
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        let daysInMonthRange = Calendar.current.range(of: .day, in: .month, for: currentMonth)!
        
        // Previous month's padding
        if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            let daysInPreviousMonth = Calendar.current.range(of: .day, in: .month, for: previousMonth)!.count
            for day in (daysInPreviousMonth - firstWeekday + 1)...daysInPreviousMonth {
                var components = Calendar.current.dateComponents([.year, .month], from: previousMonth)
                components.day = day
                if let date = Calendar.current.date(from: components) {
                    days.append(date)
                }
            }
        }
        
        // Current month's days
        for day in daysInMonthRange {
            var components = Calendar.current.dateComponents([.year, .month], from: currentMonth)
            components.day = day
            if let date = Calendar.current.date(from: components) {
                days.append(date)
            }
        }
        
        // Next month's padding
        let remainingDays = 7 - (days.count % 7)
        if remainingDays < 7, let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            for day in 1...remainingDays {
                var components = Calendar.current.dateComponents([.year, .month], from: nextMonth)
                components.day = day
                if let date = Calendar.current.date(from: components) {
                    days.append(date)
                }
            }
        }
        
        return days
    }
    
    var body: some View {
        ZStack {
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
        }
        .frame(height: isWeeklyView ? dayCellHeight : CGFloat(weeksInMonth.count) * dayCellHeight)
        .padding()
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
                            .font(.system(size: 16))
                        Text("+3000")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                        Text("-3000")
                            .font(.system(size: 10))
                            .foregroundColor(.red)
                    } else {
                        Text("")
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: dayCellHeight)
                .background(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.blue.opacity(0.3) : Color.clear)
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .frame(height: dayCellHeight)
        .background(Color(.white))
    }
}

struct ListView: View {
    var body: some View {
        List(0..<20) { item in
            Text("Item \(item)")
        }
    }
}

//struct ContentView: View {
//    var body: some View {
//        CustomCalendarView()
//    }
//}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

// Date formatters
private let monthYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}()

private let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter
}()
