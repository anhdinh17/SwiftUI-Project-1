//
//  ExpenseModel.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 8/23/23.
//

import Foundation
import SwiftUI

struct ExpenseModel: Hashable, Identifiable {
    let id = UUID().uuidString
    let nameOfExpense: String
    let amoutExpense: Double
    // Use TimeInterval to save to DB
    let dateSpendOn: TimeInterval
}
