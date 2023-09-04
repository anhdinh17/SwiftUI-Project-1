//
//  DataManager.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 9/3/23.
//

import Foundation
import SwiftUI
import FirebaseDatabase

class DataManager {
    static let shared = DataManager()

    private init() {}
    
    let databaseRef = Database.database().reference()
    
    func createExpenseFolder(folderName: String, completion: @escaping (Bool)->Void) {
        databaseRef.child("folders").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var dictionary = snapshot.value as? [String:Any] else {
                // if under "folders" doesn't have any data yet.
                self?.databaseRef.child("folders").setValue(
                    [
                        folderName: ""
                    ]
                ){error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
                return
            }
            
            // if under "folders" already has data.
            dictionary[folderName] = ""
            self?.databaseRef.child("folders").setValue(dictionary, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            })
        }
    }
}
