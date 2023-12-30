//
//  SignUpViewmodel.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/13/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

class SignUpViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    // Sign up account to Firebase
    func registerAccount() {
        guard validate() else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if error == nil {
                // Get the ID created by Firebase for user
                guard let userID = result?.user.uid else {
                    return
                }
                
                // Create a username in Realtime Database
                self?.createUserInDB(id: userID, username: self?.name ?? "", userEmail: self?.email ?? "")
                
                // Save email,username,userID to UserDefault for easy use
                UserDefaults.standard.set(self?.email, forKey: "userEmail")
                UserDefaults.standard.set(self?.name, forKey: "userName")
                UserDefaults.standard.set(userID, forKey: "userID")
            } else {
                print(error?.localizedDescription)
            }

        }
    }
    
    func createUserInDB(id: String, username: String, userEmail: String) {
        DataManager.shared.createUserInDB(id: id, username: username, email: userEmail)
    }
    
    // Validate all the fields
    private func validate() -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        guard email.contains("@") && email.contains(".") else { return false}
        
        guard password.count >= 6 else { return false}
        
        return true
    }
}
