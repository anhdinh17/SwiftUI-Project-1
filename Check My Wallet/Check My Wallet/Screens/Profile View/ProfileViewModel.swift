//
//  ProfileViewModel.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/26/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

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
    
    func uploadImage(selectedImage: UIImage) {
        // Create a reference to Storage
        let storageRef = Storage.storage().reference()
        
        // Turn our image into Data type
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        // Specify the file path and name
        // Cach tao path nay voi child("images/\(UUID().uuidString).jpg") la giong nhau
        let fileRef = storageRef.child("images").child("\(UUID().uuidString).jpg")
        
        // Upload image
        let uploadTask = fileRef.putData(imageData, metadata: nil) { metaData, error in
            if error == nil && metaData != nil {
                // TODO: save image to Realtime Database
            }
        }
    }
}
