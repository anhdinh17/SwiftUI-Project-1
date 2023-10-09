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
    
    // This funcs read data from DB and get ID for each folder name
    func readDataFromDB(completion: @escaping([ExpenseFolder]) -> Void){
        var expenseFolderArray: [ExpenseFolder] = []
        var tempStringArray: [String] = []
        var tempDict: [String:Any] = [:]
        
        databaseRef.child("folders").observeSingleEvent(of: .value) { snapshot,arg  in
            print("READ FROM DATABASE: \n \(snapshot.value)")
            // What under "Folders"
            // it's a dictionary
            guard var dictionary = snapshot.value as? [String: Any] else {
                return
            }
            
            for (key,value) in dictionary {
                // Each Key is the ID (childByAutoID)
                // Each "value" is a dictionary,i.e ["August 2023": ""]
                guard let subDictionary = value as? [String:Any] else {return}
                // Get the key of each subDictionary and put it to temp array
                // subDictionary.keys is an array of keys
                // in this case, the subDictionary.keys array has only 1 element which is [Agust 2023: ""]
                subDictionary.keys.forEach { item in
                    tempDict[key] =  item
                }
            }
            print("TEMP STRING ARRAY: \(tempStringArray)")
            
            for (key,value) in tempDict {
                let model = ExpenseFolder(name: value as! String, idOfEachFolder: key)
                expenseFolderArray.append(model)
            }
            completion(expenseFolderArray)
        }
    }
    
    // Add detail to existing folder
    // This func add details of expense to an existing folder
    func addDetailsToFolder(folderName: String, id: String, expenseModel: ExpenseModel, completion: @escaping(Bool) -> Void) {
        let detailedExpense: [String: Any] = [
            "Expense Name" : expenseModel.nameOfExpense,
            "Expense Money" : expenseModel.amoutExpense,
        ]
        let updateDictionary = [
            folderName : detailedExpense
        ]
        databaseRef.child("folders").child(id).setValue(updateDictionary) { error,_ in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func readDataFromEachFolder(folderID: String, completion: @escaping(([ExpenseModel]) -> Void)) {
        var tempArray: [ExpenseModel] = []
        
        databaseRef.child("folders").child(folderID).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            for (key,value) in dictionary {
                guard let subDict = value as? [String:Any] else {return}
                let model = ExpenseModel(nameOfExpense: subDict["Expense Name"] as! String, amoutExpense: subDict["Expense Money"] as! Double, dateSpendOn: Date())
                tempArray.append(model)
            }
            completion(tempArray)
        })
    }
    
}
