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
    var folderName: String
    var userID: String
    var folderID: String
    @State var isAlertOn: Bool = false
    
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
                    .keyboardType(.numberPad)
                
                // "selection" la 1 Date type
                DatePicker("Date you spend on",
                           selection: $dateSpendMoney,
                           displayedComponents: .date
                )
                
                Button{
                    // Chuyen Date thanh TimeInterval
                    let expenseModel = ExpenseModel(nameOfExpense: nameOfExpense,
                                                    amoutExpense: Double(amountSpent) ?? 0.00,
                                                    dateSpendOn: dateSpendMoney.timeIntervalSince1970)
                    
                    // Add to DB
                    DataManager.shared.addDetailsToEachFolderBasedOnUserID(userID: self.userID,
                                                                           folderID: self.folderID,
                                                                           folderName: self.folderName,
                                                                           expenseModel: expenseModel) { success,array in
                        if success {
                            self.expenseArray = array
                            // Close pop-up sheet
                            self.newItemPresented = false
                        } else {
                            isAlertOn = true
                        }
                    }
                }label: {
                    Text("Add")
                        .bold()
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
            }
        }
        .alert("Oops something went wrong", isPresented: $isAlertOn) {
            // Alert that users cannot add detail expense
        }
    }
}

struct AddNewExpense_Previews: PreviewProvider {
    static var previews: some View {
        AddNewExpense(newItemPresented: .constant(false),
                      expenseArray: .constant([ExpenseModel(nameOfExpense: "Coffee", amoutExpense: 5.00, dateSpendOn: Date().timeIntervalSince1970)]),
                      folderName: "abc",
                      userID: "",
                      folderID: "")
    }
}
