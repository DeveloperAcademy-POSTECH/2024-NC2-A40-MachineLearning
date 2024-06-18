//
//  Transaction.swift
//  NC2
//
//  Created by DevJonny on 2024/6/17.
//

import Foundation
import SwiftData

@Model
struct Transaction: Identifiable {
    @Attribute(.unique) var id = UUID()
    var place: String
    var amount: Int
    var transactionType: TransactionType
    var displayDate: Date
    var createDate: Date
    var category: CategoryType
    var memo: String
    
    init(id: UUID = UUID(), place: String, amount: Int, transactionType: TransactionType, displayDate: Date, createDate: Date, category: CategoryType, memo: String) {
        self.id = id
        self.place = place
        self.amount = amount
        self.transactionType = transactionType
        self.displayDate = displayDate
        self.createDate = createDate
        self.category = category
        self.memo = memo
    }
}

enum TransactionType {
    case income
    case outcome
}

enum CategoryType: String, CaseIterable {
    case none
    case food
    case education
    case drink
    case cafe
    case store
    case shopping
    case hospital
    case travel
}

func categoryIcon(_ category: CategoryType) -> String {
    switch category {
    case .food:
        return "food"
    case .education:
        return "education"
    case .drink:
        return "drink"
    case .cafe:
        return "cafe"
    case .store:
        return "store"
    case .shopping:
        return "shopping"
    case .hospital:
        return "hospital"
    case .travel:
        return "travel"
    case .none:
        return "none"
    }
}
