//
//  DetailedScreenOfExpenses.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 9/3/23.
//

import SwiftUI

struct DetailedScreenOfExpenses: View {
    @StateObject var viewModel = DetailedScreenOfExpensesVM()
    @State var isAddButtonTapped: Bool = false
    @State var expenseArray: [ExpenseModel] = []
    @State var isBudgetTextShown: Bool = false
    @State var tempBudget: String = ""
    @State var isBudgetSet: Bool = false
    var folderName: String
    var userID: String
    var folderID: String
    
    var body: some View {
        List {
            // Put things to Section to use Header
            Section {
                ForEach(expenseArray) { expense in
                    NavigationLink(value: expense) {
                        let dateSpendMoney = Utility.convertTimeIntervalToDateFormat(timeInterval: expense.dateSpendOn)
                        ExpenseInfoRow(nameOfExpense: expense.nameOfExpense,
                                       amountSpent: expense.amoutExpense,
                                       dateSpentMoney: dateSpendMoney)
                    }
                }
            } header: {
                VStack {
                    // switch on/off => viewModel.isSetBudget = True/False
                    Toggle(isOn: $viewModel.isSetBudget) {
                        Text("Do you want to set a budget?")
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
                                
                                TextField("Enter Your Budget", text: $tempBudget)
                                    .frame(height: 30)
                                    .background(Color.white)
                                    .cornerRadius(3)
                                    // Hit Return button on keyboard
                                    .onSubmit {
                                        viewModel.budget = tempBudget
                                        tempBudget = ""
                                    }
                                
                                Spacer()
                            }
                            
                            // Set Budget button
                            Button {
                                // if budget is valid meaning that budget is > 0
                                if Double(viewModel.budget) ?? 0.0 > 0 {
                                    self.isBudgetTextShown = true
                                }
                            } label: {
                                Text("Set Budget")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 150, height: 35)
                            .background(Color.blue)
                            .cornerRadius(5)
                            
                            // Budget Text
                            if isBudgetTextShown {
                                // Show budget
                                Text("Your budget: $\(Double(viewModel.budget) ?? 0.0, specifier: "%.2f")")
                                    .font(.title3)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    
                    // Total spending
                    Text("Total Spending: $\(Double(viewModel.totalSpending), specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.medium)
                }
            } footer: {
                if expenseArray.count > 0 {
                    HStack {
                        Spacer()
                        
                        // Click on button to go to ChartView
                        // Using NavigationLink
                        NavigationLink(destination: ChartView(expenseArray: self.expenseArray)) {
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
        .onAppear{
            // Mới vô thì lấy array từ DB.
            // calculate total spending
            // lấy isBudgetSet từ DB để display Switch.
            DataManager.shared.readDataFromOneFolder(userID: userID, folderID: folderID, folderName: folderName) { array, isBudgetSet in
                DispatchQueue.main.async {
                    expenseArray = array
                    // Caculate total spending after we get the array when getting to this screen.
                    viewModel.totalSpending = SpendingDataController.shared.calculateTotalSpending(arrayOfSepnding: array)
                    // Value of isBudgetSet
                    self.viewModel.isSetBudget = isBudgetSet
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
        .sheet(isPresented: $isAddButtonTapped) {
            AddNewExpense(isAddButtonTapped: $isAddButtonTapped,
                          expenseArray: $expenseArray,
                          folderName: self.folderName,
                          userID: self.userID,
                          folderID: self.folderID,
                          totalSpending: $viewModel.totalSpending)
        }
//        .alert("Add Budget", isPresented: $viewModel.isSetBudget) {
//            TextField("Please enter your budget", text: $viewModel.budget)
//        }
    }
}

struct DetailedScreenOfExpenses_Previews: PreviewProvider {
    static var previews: some View {
        DetailedScreenOfExpenses(folderName: "Whatever", userID: "", folderID: "")
    }
}
