//
//  AddNewExpenseVM.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 1/14/24.
//

import Foundation
import SwiftUI

class AddNewExpenseVM: ObservableObject {
    @Published var totalSpending: Double = 0.0
    @Published var nameOfExpense: String = ""
    @Published var amountSpent: String = ""
    @Published var dateSpendMoney: Date = Date()
}
