//
//  SpendingDataController.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 1/6/24.
//

import Foundation

class SpendingDataController {
    static let shared = SpendingDataController()
    var totalSpendingTilNow: Int = 0
    
    private init() {
        
    }
    
    // Calculate total spending
    func calculateTotalSpending(arrayOfSepnding: [ExpenseModel]) -> Double {
        var totalSpending: Double = 0.0
        arrayOfSepnding.forEach { eachSpending in
            totalSpending += eachSpending.amoutExpense
        }
        return totalSpending
    }
}
