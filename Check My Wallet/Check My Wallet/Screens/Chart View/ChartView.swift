//
//  ChartView.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 11/29/23.
//

import SwiftUI
import Charts

struct ChartView: View {
    
    let expenseArray: [ExpenseModel]
    
    var body: some View {
        Chart {
            ForEach(expenseArray) { expense in
                BarMark(x: .value("Items", expense.nameOfExpense),
                        y: .value("Amount", expense.amoutExpense))
            }
        }
        .padding()
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(expenseArray: [.init(nameOfExpense: "Shoues", amoutExpense: 15.77, dateSpendOn: 12345677899)])
    }
}
