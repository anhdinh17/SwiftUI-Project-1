//
//  ContentView.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 8/23/23.
//

import SwiftUI

struct ExpenseHomeView: View {
    
    @State var isAddButtonTapped: Bool = false
    @State var folderArray: [ExpenseFolder] = []
    @State var showAddFolderAlert: Bool = false
    @State var folderName: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(folderArray) { eachFolder in
                    NavigationLink(value: eachFolder) {
                        Text("\(eachFolder.name)")
                    }
                }
            }
            .navigationTitle("Home")
            .navigationDestination(for: ExpenseFolder.self){ folderName in
                // Pass ChildByAutoID to next screen
                DetailedScreenOfExpenses(idOfFolder: folderName.idOfEachFolder ?? "",
                                         folderName: folderName.name)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddFolderAlert.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear{
            DataManager.shared.readDataFromDB { folderArray in
                self.folderArray = folderArray
            }
        }
        .alert("Add Your Expense Object", isPresented: $showAddFolderAlert, actions: {
            TextField("Your folder name", text: $folderName)
            Button("Add", action: {
                // Tap Add button of alert
                if !self.folderName.isEmpty {
                    // save to database
                    DataManager.shared.createExpenseFolder(folderName: self.folderName) { result in
                        if result {
                            folderArray.append(ExpenseFolder(name: folderName))
                        } else {
                            print("UNABLE TO SAVE TO DATA")
                        }
                    }
//                    DataManager.shared.testAddData(folderName: folderName)
                } else {
                    // alert to make users enter name
                }
            })
            Button("Cancel", role: .cancel, action: {})
        }, message : {
            Text("Enter name of your subject")
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseHomeView()
    }
}
