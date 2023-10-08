//
//  AddNewExpense.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 8/23/23.
//

import SwiftUI

struct AddNewExpense: View {
    
    @Binding var newItemPresented: Bool
    @Binding var expenseArray: [ExpenseModel]
    @State var nameOfExpense: String = ""
    @State var amountSpent: String = ""
    @State var dateSpendMoney: Date = Date()
    
    var body: some View {
        VStack {
            Text("Add New Expense")
                .bold()
                .font(.system(size: 32))
                .padding(.top, 50)
            
            Form {
                TextField("What you spend on", text: $nameOfExpense)
                    .textFieldStyle(DefaultTextFieldStyle())
                
                TextField("Amount", text: $amountSpent)
                    .textFieldStyle(PlainTextFieldStyle())
                
                DatePicker("Date you spend on",
                           selection: $dateSpendMoney,
                           displayedComponents: .date
                )
                
                Button{
                    let expenseModel = ExpenseModel(nameOfExpense: nameOfExpense, amoutExpense: amountSpent, dateSpendOn: dateSpendMoney)
                    expenseArray.append(expenseModel)
                    self.newItemPresented = false
                }label: {
                    Text("Add")
                        .bold()
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
            }
        }
    }
}

struct AddNewExpense_Previews: PreviewProvider {
    static var previews: some View {
        AddNewExpense(newItemPresented: .constant(false), expenseArray: .constant([ExpenseModel(nameOfExpense: "Coffee", amoutExpense: "5.00", dateSpendOn: Date())]))
    }
}
