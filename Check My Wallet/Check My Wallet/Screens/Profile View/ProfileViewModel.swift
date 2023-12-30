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
    @Published var userImage: UIImage?
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            
            // Reset UserDefaults for user's email, password, ID.
            UserDefaults.standard.set("", forKey: "userEmail")
            UserDefaults.standard.set("", forKey: "userName")
            UserDefaults.standard.set("", forKey: "userID")
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
        
        /**
        - Specify the file path and name
        - Cach tao path nay voi child("images/\(UUID().uuidString).jpg") la giong nhau
        - With this way, every time users upload an image, there will be only 1 image file in Storage because we use userID for the image, which means every time uploading an image, we overwrite the old one.
         */
        let userID = UserDefaults.standard.object(forKey: "userID") as? String ?? ""
        let fileRef = storageRef.child("images").child(userID).child("\(userID).jpg")
        
        // Upload image
        let uploadTask = fileRef.putData(imageData, metadata: nil) { metaData, error in
            if error == nil && metaData != nil {
                // TODO: save image to Realtime Database
                // For now we don't need to store it to DB, we download image from Storage
            }
        }
    }
    
    func downloadImage(completion: @escaping () -> Void) {
        let userID = UserDefaults.standard.object(forKey: "userID") as? String ?? ""
        
        // Reference to the file you want to download
        let storageRef = Storage.storage().reference()
        // Specify the path
        let fileRef = storageRef.child("images/\(userID)/\(userID).jpg")
        // Retrieve the data
        fileRef.getData(maxSize: 5 * 1024 * 1024) { [weak self] data, error in
            if error == nil && data != nil {
                if let image = UIImage(data: data ?? Data()) {
                    DispatchQueue.main.async {
                        // "image" is the image from Storage
                        self?.userImage = image
                        completion()
                    }
                }
            }
        }
    }
}
