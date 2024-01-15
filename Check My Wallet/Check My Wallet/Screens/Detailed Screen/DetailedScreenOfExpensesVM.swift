//
//  DetailedScreenOfExpensesVM.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 1/6/24.
//

import Foundation
import SwiftUI

class DetailedScreenOfExpensesVM: ObservableObject {
    @Published var isSetBudget: Bool = false
    @Published var budget: String = ""
    @Published var totalSpending: Double = 0
    
    func checkBudget() {
        if isSetBudget {
            // Do something when users want to set budget
            let budget = Double(budget) ?? 0.0
            if budget > 0 {
                // Budget phải lớn hơn 0 mới hợp lí
                // Compare budget with current total spending amount
            }
        }
    }
}
