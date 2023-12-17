//
//  DataManager.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 9/3/23.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import FirebaseAuth

class DataManager {
    static let shared = DataManager()

    private init() {}
    
    let databaseRef = Database.database().reference()
    
    func testAddData(folderName: String){
        databaseRef.child("folders").setValue([folderName: ""])
    }
    
    // Create expense folder with childByAutoID
    // This func is used before we create SignIn/SignUp screens
    func createExpenseFolder(folderName: String, completion: @escaping (Bool)->Void) {
        databaseRef.child("folders").childByAutoId().observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var dictionary = snapshot.value as? [String:Any] else {
                // if under folder/chilByAutoId doesn't have any data yet.
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
    // This funcs used before we have Signed In logic
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
    // This fuc is used before we create Sign In screen
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
    
    func createUserInDB(id: String, username: String) {
        // Create "username" node and "folders" node
        // "folders" node lúc này empty vì mới tạo account
        databaseRef.child("Users").child(id).setValue(["username":username, "folders": ""])
    }
    
    // Create ExpenseFolder with ID of user
    // Under node ID at this point, there is dictionary of ["username": <username>, "folders": ""]
    func createExpenseFolderWithUserID(id: String, folderName: String, completion: @escaping ((Bool,[ExpenseFolder]) -> Void)){
        // Array chi chua folder name
        var tempArray: [ExpenseFolder] = []
        
        databaseRef.child("Users").child(id).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            // What under ID node
            guard var dictionary = snapshot.value as? [String:Any] else {
                return
            }
            
            // If the first time users create a folder
            // When we create a user by signing up, we also create "folders" under userID and set it ""
            // But when we try to do dictionary["folders"] it returns nil. So we have to check if it's nill that means
            // users first time create a folder
            guard var folderDictionary = dictionary["folders"] as? [String:Any] else {
                dictionary["folders"] = [
                    folderName : ""
                ]
                let object = ExpenseFolder(name: folderName)
                tempArray.append(object)
                // Add xong lan dau thi return true va array roi ngung
                completion(true,tempArray)
                return
            }
            print("DICTIONARY FOLDER: \(folderDictionary)")
            
            // Nếu dictionary["folders"] ko nil - tức là đã có folder nào đó rồi, add thêm folder mới
            // Set empty vì tại thời điểm này mình chỉ muốn tạo folder thôi
            folderDictionary[folderName] = ""
            print("DICTIONARY FOLDER AFTER ADDED NEW FOLDER: \(folderDictionary)")
            // Tao array chi chua folder name
            folderDictionary.keys.forEach { folder in
                tempArray.append(ExpenseFolder(name: folder))
            }
            
            // Dùng syntax nách để update child "folders"
            // Còn nếu dùng cách child("Users").child(id).setValue(dictionary) ko ra.
            // Firebase ko update lại toàn bộ "dictionary", mình phải update ở vị trí mình muốn.
            self?.databaseRef.child("Users/\(id)/folders").setValue(folderDictionary, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false,[])
                    return
                }
                completion(true,tempArray)
            })
        })
    }
    
    // Read folder names
    func readDataBasedOnUserID(userID: String, completion: @escaping (([ExpenseFolder]) -> Void)) {
        var expenseFolderArray: [ExpenseFolder] = []
        var tempStringArray: [String] = []
        databaseRef.child("Users").child(userID).child("folders").observeSingleEvent(of: .value, with: { [weak self] snapshhot in
            // What under "folders"
            guard let dictionary = snapshhot.value as? [String:Any] else {
                completion([])
                return
            }

            dictionary.keys.forEach { eachKey in
                tempStringArray.append(eachKey)
            }
            
            tempStringArray.forEach { item in
                expenseFolderArray.append(.init(name: item))
            }
            
            completion(expenseFolderArray)
        })
    }
    
    func addDetailsToEachFolderBasedOnUserID(userID: String, folderName: String, expenseModel: ExpenseModel, completion: @escaping ((Bool) -> Void)) {
        databaseRef.child("Users").child(userID).child("folders").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else {
                completion(false)
                return
            }
            
            guard var folderDictionary = dictionary["folders"] as? [String:Any] else {
                return
            }
            guard var folderNameDictionary = folderDictionary[folderName] as? [String:Any] else {
                return
            }
            folderNameDictionary[expenseModel.nameOfExpense] = ["Amount" : expenseModel.amoutExpense,
                                                                "Date" : expenseModel.dateSpendOn]
            self?.databaseRef.child("Users").child(userID).setValue(dictionary) { error,_ in
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        })
    }
}
