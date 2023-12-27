//
//  ContentView.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 8/23/23.
//

import SwiftUI
import FirebaseAuth

struct ExpenseHomeView: View {
    
    @State var isAddButtonTapped: Bool = false
    @State var folderArray: [FoldersModel] = []
    @State var showAddFolderAlert: Bool = false
    @StateObject var viewModel = ExpenseHomeViewViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(folderArray) { eachFolder in
                    NavigationLink(value: eachFolder) {
                        Text(eachFolder.folderName ?? "")
                    }
                }
            }
            .navigationTitle("Home")
            .navigationDestination(for: FoldersModel.self){ folderName in
                DetailedScreenOfExpenses(folderName: folderName.folderName ?? "",
                                         userID: viewModel.userID,
                                         folderID: folderName.folderIDFromDB ?? "")
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
            
            Button {
                try? Auth.auth().signOut()
            } label: {
                Text("Sign Out")
            }
        }
        .onAppear{
            // Fetch data from Realtime DB respect to current user
            DataManager.shared.readDataBasedOnUserID(userID: viewModel.userID, completion: { array in
                self.folderArray = array
            })
        }
        .alert("Add Your Expense Object", isPresented: $showAddFolderAlert, actions: {
            TextField("Your folder name", text: $viewModel.folderName)
            Button("Add", action: {
                // Tap Add button of alert
                if !viewModel.folderName.isEmpty {
                    // Create a folder object
                    let folder = ExpenseFolder(name: viewModel.folderName)
                    // save to database
                    DataManager.shared.createExpenseFolderWithUserID(userID: viewModel.userID, expenseFolder: folder, completion: { result,array in
                        if result {
                            self.folderArray = array
                        } else {
                            print("UNABLE TO SAVE TO DATA")
                        }
                    })
                    // Set viewModel folder name to be empty so next time we click +
                    // textField will be empty
                    viewModel.folderName = ""
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
