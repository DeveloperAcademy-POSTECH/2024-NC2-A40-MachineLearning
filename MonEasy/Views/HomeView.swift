//
//  HomeView.swift
//  NC2
//
//  Created by DevJonny on 2024/6/17.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @ObservedObject var homeViewModel = HomeViewModel()
    @State private var selectedTransaction: Transaction?
    @State private var isEditMode = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 상단바 영역
                ZStack {
                    HStack {
                        Spacer().frame(width: 10)
                        Image(.icon)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 35, alignment: .center)
                            .clipped()
                        Spacer()
                    }
                    // 월 변경 및 표시
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation {
                                homeViewModel.isWeeklyView = false
                                homeViewModel.currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: homeViewModel.currentMonth) ?? homeViewModel.currentMonth
                                if isCurrentMonth(date: homeViewModel.currentMonth) {
                                    homeViewModel.selectedDate = Date()
                                } else {
                                    homeViewModel.selectedDate = getLastDate(of: homeViewModel.currentMonth)
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.black)
                                .padding(.horizontal)
                        }
                        Text(monthYearFormatter.string(from: homeViewModel.currentMonth))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.blue)
                        
                        Button(action: {
                            withAnimation {
                                homeViewModel.isWeeklyView = false
                                homeViewModel.currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: homeViewModel.currentMonth) ?? homeViewModel.currentMonth
                                if isCurrentMonth(date: homeViewModel.currentMonth) {
                                    let now = Date()

                                    var calendar = Calendar.current
                                    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
                                    calendar.timeZone = TimeZone.current
                                    let timeZoneOffset = TimeZone.current.secondsFromGMT()

                                    var components = calendar.dateComponents([.year, .month, .day], from: now)
                                    components.day = components.day! - 1
                                    components.hour = 15 + (timeZoneOffset / 3600)
                                    components.minute = 0
                                    components.second = 0

                                    if let newDate = Calendar.current.date(from: components) {
                                        print(newDate)
                                        homeViewModel.selectedDate = newDate
                                    } else {
                                        print("Date creation failed")
                                    }
                                } else {
                                    homeViewModel.selectedDate = getLastDate(of: homeViewModel.currentMonth)
                                    print(getLastDate(of: homeViewModel.currentMonth))
                                }
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(isFutureMonth(date: Calendar.current.date(byAdding: .month, value: 1, to: homeViewModel.currentMonth) ?? homeViewModel.currentMonth) ? Color.gray : .black)
                                .padding(.horizontal)
                        }
                        .disabled(isFutureMonth(date: Calendar.current.date(byAdding: .month, value: 1, to: homeViewModel.currentMonth) ?? homeViewModel.currentMonth))
                    }
                    .padding(.horizontal)
                }
                // 커스텀 캘린더 뷰
                Divider()
                    .padding(.horizontal, 26)
                    .padding(.vertical, 10)
                // 요일 표시
                HStack(spacing: 0) {
                    ForEach([
                        NSLocalizedString("일", comment: ""),
                        NSLocalizedString("월", comment: ""),
                        NSLocalizedString("화", comment: ""),
                        NSLocalizedString("수", comment: ""),
                        NSLocalizedString("목", comment: ""),
                        NSLocalizedString("금", comment: ""),
                        NSLocalizedString("토", comment: "")], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 12, weight: .medium))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 5)
                .padding(.horizontal, 20)
                CalendarView(isWeeklyView: $homeViewModel.isWeeklyView, currentMonth: $homeViewModel.currentMonth, selectedDate: $homeViewModel.selectedDate, transactions: homeViewModel.transactions)
                    .gesture(
                        DragGesture().onEnded { value in
                            let today = Date()
                            
                            if value.translation.height < -50 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    homeViewModel.isWeeklyView = true
                                }
                            } else if value.translation.height > 50 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    homeViewModel.isWeeklyView = false
                                }
                            } else if value.translation.width > 50 {
                                // 스크롤 왼쪽으로 (이전 달 또는 이전 주)
                                withAnimation {
                                    if homeViewModel.isWeeklyView {
                                        let previousWeek = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: homeViewModel.selectedDate) ?? homeViewModel.selectedDate
                                        if Calendar.current.isDate(today, equalTo: previousWeek, toGranularity: .weekOfYear) {
                                            homeViewModel.selectedDate = today
                                        } else {
                                            homeViewModel.selectedDate = previousWeek
                                            if !Calendar.current.isDate(homeViewModel.selectedDate, equalTo: homeViewModel.currentMonth, toGranularity: .month) {
                                                homeViewModel.currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: homeViewModel.currentMonth) ?? homeViewModel.currentMonth
                                                homeViewModel.selectedDate = getLastDate(of: homeViewModel.currentMonth)
                                            }
                                        }
                                    } else {
                                        homeViewModel.currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: homeViewModel.currentMonth) ?? homeViewModel.currentMonth
                                        homeViewModel.selectedDate = isCurrentMonth(date: homeViewModel.currentMonth) ? today : getLastDate(of: homeViewModel.currentMonth)
                                    }
                                }
                            } else if value.translation.width < -50 {
                                // 스크롤 오른쪽으로 (다음 달 또는 다음 주)
                                withAnimation {
                                    if homeViewModel.isWeeklyView {
                                        let nextWeek = Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: homeViewModel.selectedDate) ?? homeViewModel.selectedDate
                                        if nextWeek > today {
                                            homeViewModel.selectedDate = today
                                        } else {
                                            homeViewModel.selectedDate = nextWeek
                                            if !Calendar.current.isDate(homeViewModel.selectedDate, equalTo: homeViewModel.currentMonth, toGranularity: .month) {
                                                homeViewModel.currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: homeViewModel.currentMonth) ?? homeViewModel.currentMonth
                                                homeViewModel.selectedDate = startOfMonth(for: homeViewModel.currentMonth)
                                            }
                                        }
                                    } else {
                                        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: homeViewModel.currentMonth) ?? homeViewModel.currentMonth
                                        if nextMonth > today {
                                            homeViewModel.selectedDate = today
                                        } else {
                                            homeViewModel.currentMonth = nextMonth
                                            homeViewModel.selectedDate = isCurrentMonth(date: homeViewModel.currentMonth) ? today : getLastDate(of: homeViewModel.currentMonth)
                                        }
                                    }
                                }
                            }
                        }
                    )
                    .padding(.bottom, 4)
                HStack {
                    Spacer()
                    VStack {
                        HStack(spacing: 0) {
                            Text(monthFormatter.string(from: homeViewModel.currentMonth) + NSLocalizedString("월", comment: "") + " ").font(.system(size: 12, weight: .light))
                            Text("지출").font(.system(size: 12, weight: .light)).foregroundColor(.red)
                        }
                        .padding(.bottom, 1)
                        Text("\(homeViewModel.totalOutcome(for: homeViewModel.currentMonth)) 엔").font(.system(size: 16, weight: .medium)).foregroundColor(.gray)
                    }
                    Spacer()
                    Divider()
                        .frame(height: 60)
                        .background(Color.gray)
                    Spacer()
                    VStack {
                        HStack(spacing: 0) {
                            Text(monthFormatter.string(from: homeViewModel.currentMonth) + NSLocalizedString("월", comment: "") + " ").font(.system(size: 12, weight: .light))
                            Text("수입").font(.system(size: 12, weight: .light)).foregroundColor(.green)
                        }
                        .padding(.bottom, 1)
                        Text("\(homeViewModel.totalIncome(for: homeViewModel.currentMonth)) 엔").font(.system(size: 16, weight: .medium)).foregroundColor(.green)
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 26)
                .padding(.bottom, 10)
//                .offset(y: homeViewModel.isWeeklyView ? -40 : 0)
                .frame(height: homeViewModel.isWeeklyView ? 0 : nil)
                .opacity(homeViewModel.isWeeklyView ? 0 : 1)
                .animation(.easeInOut(duration: 0.3), value: homeViewModel.isWeeklyView)
                Spacer()
                
                TransactionListView(homeViewModel: homeViewModel, selectedTransaction: $selectedTransaction, isEditMode: $isEditMode)
                    .padding(.horizontal, 26)
            }
            VStack {
                // 플로팅 버튼
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        self.selectedTransaction = Transaction(
                            place: "",
                            amount: 0,
                            transactionType: .outcome,
                            displayDate: homeViewModel.selectedDate,
                            createDate: Date(),
                            category: .none,
                            memo: ""
                        )
                        self.isEditMode = false
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
        }
        .dontAdaptsToKeyboard()
        .onOpenURL { url in
            if url.scheme == "NC2" && url.host == "openDetailSheet" {
                self.selectedTransaction = Transaction(
                    place: "",
                    amount: 0,
                    transactionType: .outcome,
                    displayDate: homeViewModel.selectedDate,
                    createDate: Date(),
                    category: .none,
                    memo: ""
                )
            }
        }
        .sheet(item: $selectedTransaction) { transaction in
            DetailSheet(homeViewModel: homeViewModel, transaction: transaction, isEdit: isEditMode)
                .onDisappear {
                    homeViewModel.fetchItem()
                }
        }
    }
}

struct TransactionListView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @Binding var selectedTransaction: Transaction?
    @Binding var isEditMode: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(filteredTransactions, id: \.key) { date, transactions in
                        VStack(alignment: .leading, spacing: 0) {
                            Divider()
                            Section(header: Text(dateHeader(for: date))
                                .font(.Medium12)
                                .padding(.top, 6)
                                .padding(.bottom, 10)) {
                                    ForEach(transactions.sorted(by: { $0.createDate > $1.createDate }), id: \.id) { transaction in
                                        TransactionRow(transaction: transaction) {
                                            selectedTransaction = transaction
                                            isEditMode = true
                                        }
                                        .id(transaction.displayDate)
                                    }
                                }
                        }
                    }
                    Spacer().frame(height: 60)
                }
                .onChange(of: homeViewModel.selectedDate) { _, newValue in
                    withAnimation {
                        proxy.scrollTo(newValue, anchor: .top)
                    }
                }
            }
            .simultaneousGesture(
                DragGesture().onChanged({
                    let isScrollUp = 0 > $0.translation.height
                    withAnimation {
                        if isScrollUp {
                            homeViewModel.isWeeklyView = true
                        }
                    }
                }))
        }
    }
    
    private var filteredTransactions: [(key: Date, value: [Transaction])] {
        let filtered = Dictionary(grouping: homeViewModel.transactions.filter { transaction in
            Calendar.current.isDate(transaction.displayDate, equalTo: homeViewModel.selectedDate, toGranularity: .month)
        }) { transaction in
            Calendar.current.startOfDay(for: transaction.displayDate)
        }
        return filtered.sorted { $0.key > $1.key }
    }
    
    private func dateHeader(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return NSLocalizedString("오늘", comment: "")
        } else {
            return dateFormatter.string(from: date)
        }
    }
}



struct TransactionRow: View {
    var transaction: Transaction
    var onTap: () -> Void
    
    var body: some View {
        HStack {
            Image(categoryIcon(transaction.category))
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.trailing, 4)
            Text(transaction.place)
                .font(.Light16)
            Spacer()
            if (transaction.transactionType == .income) {
                Text("+\(transaction.amount)엔")
                    .font(.Medium20)
                    .foregroundColor(.customGreen)
            } else {
                Text("-\(transaction.amount)엔")
                    .font(.Medium20)
            }
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle()) // 전체 영역을 터치 가능하게 설정
        .onTapGesture {
            onTap()
        }
    }
}





let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = NSLocalizedString("d일 EEEE", comment: "")
    formatter.locale = Locale(identifier: NSLocalizedString("ko_KR", comment: ""))
    return formatter
}()

private func startOfWeek(for date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
    return calendar.date(from: components) ?? date
}

private func endOfWeek(for date: Date) -> Date {
    let calendar = Calendar.current
    var components = DateComponents()
    components.weekOfYear = 1
    components.second = -1
    return calendar.date(byAdding: components, to: startOfWeek(for: date)) ?? date
}

#Preview {
    HomeView()
}
