//
//  AddNewExpense.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 8/23/23.
//

import SwiftUI

struct AddNewExpense: View {
    @StateObject var viewModel = AddNewExpenseVM()
    @Binding var isAddButtonTapped: Bool
    @Binding var expenseArray: [ExpenseModelToFetchList]
    var folderName: String
    var userID: String
    var folderID: String
    var isBudgetSet: Bool
    @State var isAlertOn: Bool = false
    // Binding total spending to use for viewModel.totalSpending in DetailedScreen
    @Binding var totalSpending: Double
    // Binding this Bool to check if total spending is over budget so that we can show alert in DetailedScreen
    @Binding var isTotalSpendingOverBudget: Bool
    // Take in current budget of folder from DetailedScreen
    var folderBudget: Double
    
    var body: some View {
        VStack {
            Text("Add New Expense")
                .bold()
                .font(.system(size: 32))
                .padding(.top, 50)
            
            Form {
                TextField("What you spend on", text: $viewModel.nameOfExpense)
                    .textFieldStyle(DefaultTextFieldStyle())
                
                TextField("Amount", text: $viewModel.amountSpent)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(.numbersAndPunctuation)
                
                // "selection" la 1 Date type
                DatePicker("Date you spend on",
                           selection: $viewModel.dateSpendMoney,
                           displayedComponents: .date
                )
                
                Button{
                    // Chuyen Date thanh TimeInterval
                    let expenseModel = ExpenseModel(nameOfExpense: viewModel.nameOfExpense,
                                                    amoutExpense: Double(viewModel.amountSpent) ?? 0.00,
                                                    dateSpendOn: viewModel.dateSpendMoney.timeIntervalSince1970)
                    
                    // Add to DB
                    DataManager.shared.addDetailsToEachFolderBasedOnUserID(userID: self.userID,
                                                                           folderID: self.folderID,
                                                                           folderName: self.folderName,
                                                                           expenseModel: expenseModel) { success,array in
                        if success {
                            // Nhận về 1 array, "expenseArray" bind với "expenseArray" ở DetailedScreen => expenseArray ở DetailedScreen sẽ thay đổi => fetch tableView với new row
                            self.expenseArray = array
                            
                            // Calculate new total spending after hitting Add so that we can have new total spending for DetailedScreen
                            self.totalSpending = SpendingDataController.shared.calculateTotalSpending(arrayOfSepnding: array)
                            
                            // Check if total spending is more than budget
                            if self.totalSpending > self.folderBudget && self.isBudgetSet == true {
                                isTotalSpendingOverBudget = true
                            }
                            
                            // Close pop-up sheet
                            self.isAddButtonTapped = false
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

//MARK: - This stupid Preview
//struct AddNewExpense_Previews: PreviewProvider {
//    static var previews: some View {
//        AddNewExpense(isAddButtonTapped: .constant(false),
//                      expenseArray: .constant([ExpenseModel(nameOfExpense: "Coffee", amoutExpense: 5.00, dateSpendOn: Date().timeIntervalSince1970)]),
//                      folderName: "abc",
//                      userID: "",
//                      folderID: "",
//                      isBudgetSet: .constant(false),
//                      totalSpending: .constant(0.0),
//                      isTotalSpendingOverBudget: .constant(false),
//                      folderBudget: 0.0
//                      )
//    }
//}
