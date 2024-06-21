//
//  HomeViewModel.swift
//  NC2
//
//  Created by DevJonny on 2024/6/18.
//

import SwiftUI
import SwiftData

class HomeViewModel: ObservableObject {
    private let dataSource: TransactionDataManager
    @Published var transactions: [Transaction] = []
    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date = Date()
    @Published var isWeeklyView: Bool = false
    
    init(dataSource: TransactionDataManager = TransactionDataManager.shared) {
        self.dataSource = dataSource
        transactions = dataSource.fetchItems()
    }
    
    func fetchItem() {
        transactions = dataSource.fetchItems()
    }
    
    func appendItem(transaction: Transaction) {
        dataSource.appendItem(transaction: transaction)
        fetchItem()
    }
    
    func updateTransaction(_ transaction: Transaction) {
        dataSource.updateItem(transaction: transaction)
        fetchItem()
    }
    
    func removeItem(_ transaction: Transaction) {
        dataSource.removeItem(transaction)
        fetchItem()
    }
    
    func transactions(for date: Date) -> [Transaction] {
        let calendar = Calendar.current
        return transactions.filter { calendar.isDate($0.displayDate, inSameDayAs: date) }
    }
    
    func totalOutcome(for month: Date) -> Int {
        let calendar = Calendar.current
        return transactions.filter { transaction in
            calendar.isDate(transaction.displayDate, equalTo: month, toGranularity: .month) && transaction.transactionType == .outcome
        }.reduce(0) { $0 + $1.amount }
    }
    
    func totalIncome(for month: Date) -> Int {
        let calendar = Calendar.current
        return transactions.filter { transaction in
            calendar.isDate(transaction.displayDate, equalTo: month, toGranularity: .month) && transaction.transactionType == .income
        }.reduce(0) { $0 + $1.amount }
    }
}
