//
//  ProfileViewModel.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/26/23.
//

import SwiftUI
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("ERROR SIGN OUT: \(error.localizedDescription)")
        }
    }
    
    public var isSignedIn: Bool {
        // Check if user is signed in or not
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
    func getUserEmail() -> String {
        var userEmail = ""
        userEmail = UserDefaults.standard.object(forKey: "userEmail") as? String ?? ""
        return userEmail
    }
    
    func getUserName() -> String {
        var username = ""
        username = UserDefaults.standard.object(forKey: "userName") as? String ?? ""
        return username
    }
}
