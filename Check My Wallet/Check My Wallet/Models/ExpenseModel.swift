//
//  ExpenseModel.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 8/23/23.
//

import Foundation
import SwiftUI

struct ExpenseModel: Hashable, Identifiable {
    let id = UUID()
    let nameOfExpense: String
    let amoutExpense: Double
    let dateSpendOn: Date
}
