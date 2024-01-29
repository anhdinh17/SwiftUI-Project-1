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
    @State var showAddFolderAlert: Bool = false
    @StateObject var viewModel = ExpenseHomeViewViewModel()
    @State var isDeleteFolderGoWrongAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.folderArray) { eachFolder in
                    NavigationLink(value: eachFolder) {
                        Text(eachFolder.folderName ?? "")
                    }
                }
                .onDelete { indexSet in
                    // Delete a folder in folderArray
                    deleteFolder(at: indexSet)
                }
            }
            .navigationTitle("Home")
            .navigationDestination(for: FoldersModel.self){ folderName in
                DetailedScreenOfExpenses(folderName: folderName.folderName ?? "",
                                         userID: viewModel.userID,
                                         folderID: folderName.folderIDFromDB ?? "")
            }
            .toolbar {
                // TIPS: if you want to place 2 buttons on the same leading or trailing,
                // you have to use HStack inside ToolbarItem{}
                
                // Edit button to the left
                ToolbarItem(placement: .topBarLeading) {
                    // Use edit button for deletion
                    // Thang Edit button nay ket hop voi .onDelete (SwiftUI handles)
                    EditButton()
                }
                
                // Plus button to the right
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
            // Fetch data from Realtime DB respect to current user
            DataManager.shared.readDataBasedOnUserID(userID: viewModel.userID, completion: { array in
                self.viewModel.folderArray = array
                print("FOLDER ARRAY WHEN GETTING TO SCREEN: \(viewModel.folderArray)")
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
                            // get new array of folders -> List will update table.
                            self.viewModel.folderArray = array
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
        .alert("Oops", isPresented: $isDeleteFolderGoWrongAlert) {
            Button {
                
            } label: {
                Text("OK")
            }
        } message: {
            Text("We are not able to delete your item at this time.\n Please try again later.")
        }
    }
    
    func deleteFolder(at offsets: IndexSet) {
        var folderID = ""
        // i is index of item to be deleted
        for i in offsets.makeIterator() {
            let objectToBeDelelted = viewModel.folderArray[i]
            folderID = objectToBeDelelted.folderIDFromDB ?? ""
        }
        DataManager.shared.deleteFolder(userID: viewModel.userID, folderID: folderID) { success in
            if success {
                // Remove deleted item from folderArray
                self.viewModel.folderArray.remove(atOffsets: offsets)
                print("FOLDER ARRAY AFTER DELETE: \(viewModel.folderArray)")
            } else {
                isDeleteFolderGoWrongAlert.toggle()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseHomeView()
    }
}
