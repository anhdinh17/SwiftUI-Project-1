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
    let dateSpentMoney: String
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Text(nameOfExpense)
                
                Spacer()
            }
            
            HStack {
                Text("Amount:")
                
                Spacer()
                
                Text("\(amountSpent, specifier: "%.2f")")
            }
            
            HStack {
                Text("Date:")
                
                Spacer()
                
                Text(dateSpentMoney)
            }
        }

    }
}

struct ExpenseInfoRow_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseInfoRow(nameOfExpense: "Coffee", amountSpent: 1.2, dateSpentMoney: "10/10/2023")
    }
}
