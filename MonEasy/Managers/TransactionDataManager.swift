//
//  TransactionDataManager.swift
//  NC2
//
//  Created by DevJonny on 2024/6/19.
//

import Foundation
import SwiftUI
import SwiftData

final class TransactionDataManager {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    @MainActor
    static let shared = TransactionDataManager()
    
    @MainActor
    private init() {
        self.modelContainer = try! ModelContainer(for: Transaction.self)
        self.modelContext = modelContainer.mainContext
    }
    
    func appendItem(transaction: Transaction) {
        modelContext.insert(transaction)
        saveContext()
    }
    
    func fetchItems() -> [Transaction] {
        do {
            return try modelContext.fetch(FetchDescriptor<Transaction>())
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func updateItem(transaction: Transaction) {
        saveContext()
    }
    
    func removeItem(_ transaction: Transaction) {
        modelContext.delete(transaction)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
