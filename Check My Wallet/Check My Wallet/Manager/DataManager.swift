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
            
            // if under ID already has data.
            // Hình như dòng này lặp lại với đống trên
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
        databaseRef.child("folders").child(id).child(folderName).observeSingleEvent(of: .value) { [weak self] snapshot in
            // dictionary = dictionary under folder name
            guard var dictionary = snapshot.value as? [String:Any] else {
                // Nếu dưới folder name chưa có gì, trong tình huống này là EMPTY STRING.
                // Tạo dictionary dạng ta muốn
                self?.databaseRef.child("folders").child(id).child(folderName).setValue(
                    [expenseModel.nameOfExpense: [
                        "Amount" : expenseModel.amoutExpense,
                        "Date" : expenseModel.dateSpendOn
                    ]
                    ]
                ) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
                return
            }
            // Nếu dưới folder name đã có dictionary
            // Add new key-value to dictionary under folder name
            dictionary[expenseModel.nameOfExpense] = ["Amount" : expenseModel.amoutExpense,
                                                      "Date" : expenseModel.dateSpendOn]
            self?.databaseRef.child("folders").child(id).child(folderName).setValue(dictionary) { error,_ in
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }


    }
    
    func readDataFromEachFolder(folderID: String, folderName: String, completion: @escaping(([ExpenseModel]) -> Void)) {
        var tempArray: [ExpenseModel] = []

        databaseRef.child("folders").child(folderID).child(folderName).observeSingleEvent(of: .value, with: { snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            for (key,value) in dictionary {
                guard let subDict = value as? [String:Any] else {return}
                let model = ExpenseModel(nameOfExpense: key, amoutExpense: subDict["Amount"] as! Double, dateSpendOn: subDict["Date"] as! TimeInterval)
                tempArray.append(model)
            }
            completion(tempArray)
        })
    }
    
}
