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
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password)
    }
}
