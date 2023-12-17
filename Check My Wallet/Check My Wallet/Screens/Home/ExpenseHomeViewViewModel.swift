//
//  ExpenseHomeViewViewModel.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 9/3/23.
//

import Foundation
import FirebaseAuth

class ExpenseHomeViewViewModel: ObservableObject {
    @Published var userID: String
    @Published var folderName: String = ""
    
    init() {
        // Check if user is signed in
        if Auth.auth().currentUser != nil {
            self.userID = Auth.auth().currentUser?.uid ?? ""
        } else {
            self.userID = ""
        }
    }
}
