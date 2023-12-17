//
//  DetailedScreenOfExpenses.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 9/3/23.
//

import SwiftUI

struct DetailedScreenOfExpenses: View {
    
    @State var isAddButtonTapped: Bool = false
    @State var expenseArray: [ExpenseModel] = []
    var folderName: String
    var userID: String
    
    var body: some View {
            List {
                ForEach(expenseArray) { expense in
                    NavigationLink(value: expense) {
                        let dateSpendMoney = Utility.convertTimeIntervalToDateFormat(timeInterval: expense.dateSpendOn)
                        ExpenseInfoRow(nameOfExpense: expense.nameOfExpense, amountSpent: expense.amoutExpense, dateSpentMoney: dateSpendMoney)
                    }
                }
            }
//            .onAppear{
//                DataManager.shared.readDataFromEachFolder(folderID: idOfFolder, folderName: folderName, completion: { array in
//                    self.expenseArray = array
//                })
//            }
            .navigationDestination(for: ExpenseModel.self){ expense in
                Text("\(expense.nameOfExpense)")
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
                AddNewExpense(newItemPresented: $isAddButtonTapped,
                              expenseArray: $expenseArray,
                              folderName: self.folderName,
                              userID: self.userID)
            }
            
            if expenseArray.count > 0 {
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
            }
    }
}

struct DetailedScreenOfExpenses_Previews: PreviewProvider {
    static var previews: some View {
        DetailedScreenOfExpenses(folderName: "Whatever", userID: "")
    }
}
