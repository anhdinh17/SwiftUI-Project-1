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
        
        // if user's ip is iOS 17 or up, we will display donut chart
        if #available(iOS 17.0, *) {
            Chart {
                ForEach(expenseArray) { expense in
                    SectorMark(
                        angle: .value("Amount", expense.amoutExpense),
                        innerRadius: .ratio(0.65)
                        //angularInset: 2.0
                    )
                    .foregroundStyle(by: .value("abdefg", expense.nameOfExpense))
                    .annotation(position: .overlay) {
                        Text("\(expense.amoutExpense, specifier: "%.2f")")
                            .font(.system(size: 10))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
        } else {
            Chart {
                ForEach(expenseArray) { expense in
                    BarMark(x: .value("Items", expense.nameOfExpense),
                            y: .value("Amount", expense.amoutExpense))
                }
            }
            .padding()
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(expenseArray: [.init(nameOfExpense: "Shoues", amoutExpense: 15.77, dateSpendOn: 12345677899)])
    }
}
