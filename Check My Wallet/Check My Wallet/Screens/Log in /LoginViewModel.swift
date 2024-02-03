//
//  LoginViewModel.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/12/23.
//

import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var errorMessage: String = ""
    @Published var isErrorAlert: Bool = false
    
    func login(completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] AuthResult, error in
            if error == nil {
                if let userID = AuthResult?.user.uid {
                    DataManager.shared.getUsernameAndEmail(userID: userID) { [weak self] username, email in
                        guard let username = username, let email = email else {
                            return
                        }
                        // Save email,username,userID to UserDefault for easy use
                        UserDefaults.standard.set(email, forKey: "userEmail")
                        UserDefaults.standard.set(username, forKey: "userName")
                        UserDefaults.standard.set(userID, forKey: "userID")
                    }
                    completion(true)
                }
            } else {
                self?.isErrorAlert = true
                self?.errorMessage = error?.localizedDescription ?? ""
            }
        }
    }
}
