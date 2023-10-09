//
//  ExpenseInfoRow.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 8/23/23.
//

import SwiftUI

struct ExpenseInfoRow: View {
    let nameOfExpense: String
    let amountSpent: Double
    
    var body: some View {
        HStack {
            Text(nameOfExpense)
            
            Spacer()
            
            Text("\(amountSpent)")
        }
    }
}

struct ExpenseInfoRow_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseInfoRow(nameOfExpense: "Coffee", amountSpent: 1.2)
    }
}
