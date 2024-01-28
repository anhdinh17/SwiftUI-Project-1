//
//  ExpenseModelToFetchList.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 1/28/24.
//

import Foundation

struct ExpenseModelToFetchList: Identifiable, Hashable {
    var id: String
    let nameOfExpense: String
    let amoutExpense: Double
    // Use TimeInterval to save to DB
    let dateSpendOn: TimeInterval
}
