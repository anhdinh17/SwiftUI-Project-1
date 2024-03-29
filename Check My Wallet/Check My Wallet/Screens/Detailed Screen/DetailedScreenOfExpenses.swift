//
//  DetailedScreenOfExpenses.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 9/3/23.
//

import SwiftUI

/**
 - viewModel.budget lúc mới vào sẽ được fetch từ DB. Default value là 0.0 khi mới tạo folder.
 */
struct DetailedScreenOfExpenses: View {
    @StateObject var viewModel = DetailedScreenOfExpensesVM()
    @State var isAddButtonTapped: Bool = false
    @State var isBudgetTextShown: Bool = false
    @State var isTotalSpendingOverBudget: Bool = false
    // Variable to trigger alert of over spending
    @State var isAlertShown: Bool = false
    // Trigger alert after setting new budget
    @State var isSetBudgetHit: Bool = false
    // Trigger alert if deletion has error
    @State var isDeleteItemNotThrough: Bool = false
    @FocusState var isBudgetTextFieldFocus: Bool
    // Dardk mode or light mode
    @Environment(\.colorScheme) var colorScheme
    var folderName: String
    var userID: String
    var folderID: String
    
    var body: some View {
        VStack {
            if viewModel.expenseArray.count == 0 {
                Text("You don't have any expenses yet.\nCreate one by tapping + sign.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.gray)
            }
            
            List {
                // Put things to Section to use Header
                Section {
                    ForEach(viewModel.expenseArray) { expense in
                        NavigationLink(value: expense) {
                            let dateSpendMoney = Utility.convertTimeIntervalToDateFormat(timeInterval: expense.dateSpendOn)
                            ExpenseInfoRow(nameOfExpense: expense.nameOfExpense,
                                           amountSpent: expense.amoutExpense,
                                           dateSpentMoney: dateSpendMoney)
                            .swipeActions {
                                // Another way to Swipe to delete
                                // But with this, List doesn't automatically update Table UI, we have to remove the index that is deleted from the array.
                                Button {
                                    // delete this specific item at DB
                                    DataManager.shared.deleteSpending(userID: userID, folderID: folderID, folderName: folderName, spendingID: expense.id) { success in
                                        if success {
                                            if let indexDeleted = viewModel.expenseArray.firstIndex(where: {$0.id == expense.id}) {
                                                viewModel.expenseArray.remove(at: indexDeleted)
                                                //Recalculate total spending to update UI
                                                viewModel.totalSpending = SpendingDataController.shared.calculateTotalSpending(arrayOfSepnding: self.viewModel
                                                    .expenseArray)
                                            }
                                        } else {
                                            isDeleteItemNotThrough.toggle()
                                        }
                                    }
                                }label: {
                                    Text("Delete")
                                }
                                .tint(.red)
                            }
                        }
                    }
                } header: {
                    // Hiện header nếu array tồn tại
                    if viewModel.expenseArray.count > 0 {
                        VStack {
                            // switch on/off => viewModel.isSetBudget = True/False
                            Toggle(isOn: $viewModel.isSetBudget) {
                                Text("Do you want to set a budget?")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .onChange(of: viewModel.isSetBudget) { newValue in
                                // newValue = false/true if switch is Off/On
                                // Change value of isBudgetSet in Realtime Database
                                DataManager.shared.updateIsBudgetSet(userID: self.userID, folderID: self.folderID, valueOfSwitch: newValue) { isBudgetSet in
                                    self.viewModel.isSetBudget = isBudgetSet
                                }
                            }
                            
                            // If switch is ON
                            // show textField
                            if viewModel.isSetBudget {
                                VStack (spacing: 15) {
                                    HStack {
                                        Spacer()
                                        
                                        TextField("Enter Your Budget", value: $viewModel.budget, format: .number)
                                        // tap on textField => isBudgetTextFieldFocus = true
                                            .focused($isBudgetTextFieldFocus)
                                            .frame(height: 30)
                                            .cornerRadius(3)
                                            .overlay(content: {
                                                RoundedRectangle(cornerRadius: 3)
                                                    .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
                                            })
                                        // Hit Return button on keyboard
                                            .onSubmit {
                                                isBudgetTextFieldFocus = false
                                            }
                                        
                                        Spacer()
                                    }
                                    
                                    // Set Budget button
                                    Button {
                                        // resign textfield keyboard
                                        isBudgetTextFieldFocus = false
                                        
                                        // if budget is valid meaning that budget is > 0
                                        if viewModel.budget ?? 0.0 > 0.0 {
                                            // Change budget in DB
                                            DataManager.shared.changeBudgetInFolder(userID: userID, folderID: folderID, budgetValue: viewModel.budget ?? 0.0) {
                                                self.isBudgetTextShown = true
                                                self.isSetBudgetHit.toggle()
                                            }
                                        }
                                        //isTotalSpendingOverBudget.toggle()
                                    } label: {
                                        Text("Set Budget")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 150, height: 35)
                                    .background(Color.blue)
                                    .cornerRadius(5)
                                    
                                    // Budget Text
                                    if isBudgetTextShown || viewModel.budget ?? 0.0 > 0.0 {
                                        // Show budget
                                        Text("Your budget: $\((viewModel.budget) ?? 0.0, specifier: "%.2f")")
                                            .font(.title3)
                                            .fontWeight(.medium)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            
                            // Total spending
                            Text("Total Spending: $\(viewModel.totalSpending, specifier: "%.2f")")
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                    }
                } footer: {
                    if viewModel.expenseArray.count > 0 {
                        HStack {
                            Spacer()
                            
                            // Click on button to go to ChartView
                            // Using NavigationLink
                            NavigationLink(destination: ChartView(expenseArray: self.viewModel.expenseArray)) {
                                Text("See Charts")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .frame(width: 260, height: 50)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(folderName)
        }
        .onAppear{
            // Mới vô thì lấy array từ DB.
            // Calculate total spending.
            // Lấy isBudgetSet từ DB để display Switch.
            // Lấy budget từ DB
            DataManager.shared.readDataFromOneFolder(userID: userID, folderID: folderID, folderName: folderName) { array, isBudgetSet, budget in
                DispatchQueue.main.async {
                    viewModel.expenseArray = array
                    // Caculate total spending after we get the array when getting to this screen.
                    viewModel.totalSpending = SpendingDataController.shared.calculateTotalSpending(arrayOfSepnding: array)
                    // Value of isBudgetSet from DB
                    self.viewModel.isSetBudget = isBudgetSet
                    // get the value of budget
                    self.viewModel.budget = budget
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isAddButtonTapped.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddButtonTapped, onDismiss: {
            /**
             - At first we bind .alert to isTotalSpendingOverBudget. This variable is calculated in the sheet. But then .alert won't be triggered. (some mechanism behind SwiftUI that we can't present alert after the sheet is closed).
             - The solution on SOV is to use onDimiss
             */
            
            // When the sheet dimisses, isTotalSpendingOverBudget has new value from AddNewExpense (because of the binding)
            if self.isTotalSpendingOverBudget {
                DispatchQueue.main.async {
                    isAlertShown = true
                }
            }
        }) {
            AddNewExpense(isAddButtonTapped: $isAddButtonTapped,
                          expenseArray: $viewModel.expenseArray,
                          folderName: self.folderName,
                          userID: self.userID,
                          folderID: self.folderID,
                          isBudgetSet: self.viewModel.isSetBudget,
                          totalSpending: $viewModel.totalSpending,
                          isTotalSpendingOverBudget: $isTotalSpendingOverBudget,
                          folderBudget: self.viewModel.budget ?? 0.0
            )
        }
        .alert("Warning", isPresented: $isAlertShown) {
            Button{
                
            } label: {
                Text("Ok")
            }
        } message: {
            Text("You have exceeded your budget")
        }
        .alert("Good News", isPresented: $isSetBudgetHit) {
            Button{
               
            } label: {
                Text("Ok")
            }
        } message: {
            if let budget = viewModel.budget {
                Text("You have setup a budget of \(budget,specifier: "%.2f")")
            }
        }
        .alert("Oops", isPresented: $isDeleteItemNotThrough) {
            Button{
               
            } label: {
                Text("Ok")
            }
        } message: {
            Text("We are not able to delete your item at this time.\nPlease try again later.")
        }
    }
}

struct DetailedScreenOfExpenses_Previews: PreviewProvider {
    static var previews: some View {
        DetailedScreenOfExpenses(folderName: "Whatever", userID: "", folderID: "")
    }
}
