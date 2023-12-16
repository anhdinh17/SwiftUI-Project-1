//
//  MainViewVM.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/16/23.
//

import Foundation
import FirebaseAuth

class MainViewVM: ObservableObject {
    @Published var currentUserId: String = ""
    private var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        /**
         - Khi init instance cua class nay, se xet xem user signed in or not.
         - addStateDidChangeListener observes if a user signs in or signs out.
         - if a user signs in -> user.uid has value -> self.currentUserId will change from "" to some value -> whatever listens to it will udpate/execute things.
         - if a user signs out -> user.uid has no value -> self.currentUserId is ""
         - Thang nay ket hop voi isSignedIn o duoi de double check
         */
        self.handler = Auth.auth().addStateDidChangeListener({ [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
            }
        })
    }
    
    public var isSignedIn: Bool {
        // Check if user is signed in or not
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
    /// Thằng này có thể thay cho đống init()
    public var UserIdChanged: Bool {
        self.handler = Auth.auth().addStateDidChangeListener({ [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
            }
        })
        return !currentUserId.isEmpty
    }
    
    
}
