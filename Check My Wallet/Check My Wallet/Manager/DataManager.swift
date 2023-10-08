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
    
    func testAddData(folderName: String){
        databaseRef.child("folders").setValue([folderName: ""])
    }
    
    func createExpenseFolder(folderName: String, completion: @escaping (Bool)->Void) {
        databaseRef.child("folders").childByAutoId().observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var dictionary = snapshot.value as? [String:Any] else {
                // if under "folders" doesn't have any data yet.
                self?.databaseRef.child("folders").childByAutoId().setValue(
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
            self?.databaseRef.child("folders").childByAutoId().setValue(dictionary, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            })
        }
    }
    
    func readDataFromDB(completion: @escaping([ExpenseFolder]) -> Void){
        var expenseFolderArray: [ExpenseFolder] = []
        var tempStringArray: [String] = []
        var tempDict: [String:Any] = [:]
        
        databaseRef.child("folders").observeSingleEvent(of: .value) { snapshot in
            print("READ FROM DATABASE: \n \(snapshot.value)")
            // What under "Folders"
            // it's a dictionary
            guard var dictionary = snapshot.value as? [String: Any] else {
                return
            }
            
            for (key,value) in dictionary {
                // Each "value" is a dictionary,i.e ["August 2023": ""]
                guard let subDictionary = value as? [String:Any] else {return}
                // Get the key of each subDictionary and put it to temp array
                // subDictionary.keys is an array
                subDictionary.keys.forEach { item in
                    tempStringArray.append(item)
                }
            }
            print("TEMP STRING ARRAY: \(tempStringArray)")
            tempStringArray.forEach { item in
                let model = ExpenseFolder(name: item)
                expenseFolderArray.append(model)
            }
            completion(expenseFolderArray)
        }
    }
}
