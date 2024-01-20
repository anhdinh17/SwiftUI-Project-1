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
    
    //=======================================================================================================
    //MARK: With Login screen
    //=======================================================================================================
    
    func createUserInDB(id: String, username: String, email: String) {
        // Create "username" node and "folders" node
        // "folders" node lúc này empty vì mới tạo account
        databaseRef.child("Users").child(id).setValue(["username":username, "folders": "", "email":email])
    }
    
    // Create ExpenseFolder with ID of user
    // Under node ID at this point, there is dictionary of ["username": <username>, "folders": "", emai: <user's email>]
    /**
     - Voi func nay minh tra ve 1 arry FoldersModel. Nguyen nhan la neu tra ve array cua ExpenseFolder thi se bi vuong "id= UUID" trong ExpenseFolder + minh can 1 object voi var of fixed ID from DB.
     - Nhung hay suy nghi: Khi tao 1 object ExpenseFolder o ExpenseHomeView de day len DB, moi object se co var id, minh se dung var id do de tao id cho tung folder. Sau khi xong xuoi het, neu minh lai tao object cua ExpenseFolder va tra ve trong call back, var id luc nay ko anh huong gi het ma chi dung cho List cong them minh van co the pass vo fixed ID tu DB cho object nay => Ap dung logic nay cho addDetailsToEachFolderBasedOnUserID
     */
    func createExpenseFolderWithUserID(userID: String, expenseFolder: ExpenseFolder, completion: @escaping ((Bool,[FoldersModel]) -> Void)){
        // Array chi chua folder name
        var tempArray: [FoldersModel] = []
        
        databaseRef.child("Users").child(userID).child("folders").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            // What under "folders" node.
            guard var dictionary = snapshot.value as? [String:Any] else {
                // If there's nothing under "folders" (first time creating)
                let addedFolder = [
                    expenseFolder.id : [expenseFolder.name : "",
                                        "isBudgetSet" : false,
                                        "budget" : 0.0
                                       ]
                    // Dưới mỗi folder ID sẽ có folder name, isBudgetSet va budget cho folder name đó
                ]
                self?.databaseRef.child("Users").child(userID).child("folders").setValue(addedFolder) { error, _ in
                    if error != nil {
                        completion(false,[])
                        return
                    } else {
                        let folder = FoldersModel(folderName: expenseFolder.name, folderIDFromDB: expenseFolder.id)
                        tempArray.append(folder)
                        completion(true,tempArray)
                        // Tao xong folder dau tien roi ngung
                        // Array tra ve chi co 1 element
                    }
                }
                return
            }
            
            // Neu duoi "folders" da co folder nao do roi
            // Thi add them key-value
            dictionary[expenseFolder.id] = [
                expenseFolder.name : "",
                "isBudgetSet" : false,
                "budget" : 0.0
            ]
            self?.databaseRef.child("Users").child(userID).child("folders").setValue(dictionary) { error, _ in
                if error != nil {
                    completion(false,[])
                    return
                } else {
                    // Lam cach nao de lay ID cua tung folder va folder name
                    for (key,value) in dictionary {
                        let folderID = key
                        // SubDict = dictionary duoi moi folder ID
                        guard let subDict = value as? [String:Any] else {
                            return
                        }
                        let folderNameArray = subDict.keys.filter({$0 != "isBudgetSet" && $0 != "budget"})
                        let folderName = folderNameArray.first
                        let folder = FoldersModel(folderName: folderName, folderIDFromDB: folderID)
                        tempArray.append(folder)
                    }
                    completion(true,tempArray)
                }
            }
        })
    }
    
    // Read folder names
    func readDataBasedOnUserID(userID: String, completion: @escaping (([FoldersModel]) -> Void)) {
        var expenseFolderArray: [FoldersModel] = []
        databaseRef.child("Users").child(userID).child("folders").observeSingleEvent(of: .value, with: { [weak self] snapshhot in
            // What under "folders"
            guard let dictionary = snapshhot.value as? [String:Any] else {
                completion([])
                return
            }
            
            // Take folder ID and folder name
            for (key,value) in dictionary {
                let folderID = key
                // SubDict = dictionary duoi moi folder ID
                guard let subDict = value as? [String:Any] else {
                    return
                }
                /**
                 - subDict.keys trả về 1 array của tất cả key
                 - phải filter array này để chỉ lấy folder name
                 */
                let folderNameArray = subDict.keys.filter({$0 != "isBudgetSet" && $0 != "budget"})
                let folderName = folderNameArray.first
                let folder = FoldersModel(folderName: folderName, folderIDFromDB: folderID)
                expenseFolderArray.append(folder)
            }
            completion(expenseFolderArray)
        })
    }
    
    func addDetailsToEachFolderBasedOnUserID(userID: String,folderID: String, folderName: String, expenseModel: ExpenseModel, completion: @escaping ((Bool,[ExpenseModel]) -> Void)) {
        var expenseArray: [ExpenseModel] = []
        databaseRef.child("Users").child(userID).child("folders").child(folderID).child(folderName).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            // What under folder name
            guard var dictionary = snapshot.value as? [String:Any] else {
                // If under folder name there's nothing,
                // we add a dictionary
                let addedDict = [
                    expenseModel.id : [
                        expenseModel.nameOfExpense : ["Amount" : expenseModel.amoutExpense,
                                                      "Date" : expenseModel.dateSpendOn]
                    ]
                ]
                self?.databaseRef.child("Users").child(userID).child("folders").child(folderID).child(folderName).setValue(addedDict) {error, _ in
                    guard error == nil else {
                        completion(false,[])
                        return
                    }
                    expenseArray.append(expenseModel)
                    completion(true,expenseArray)
                    // First time add item, return array of 1 element and stop
                }
                return
            }
            
            // if there's already dictionary under folder name,
            // add key-value to that dict.
            dictionary[expenseModel.id] = [expenseModel.nameOfExpense : ["Amount" : expenseModel.amoutExpense,
                                                                         "Date" : expenseModel.dateSpendOn]]
            self?.databaseRef.child("Users").child(userID).child("folders").child(folderID).child(folderName).setValue(dictionary) { error,_ in
                if error == nil {
                    for (key,value) in dictionary {
                        let whatYouBoughtID = key
                        // dictUnderProductID = dictionary under productID
                        guard let dictUnderProductID = value as? [String:Any] else {
                            return
                        }
                        // .keys se tra ve array of 1 element la ten cua product vi chi co 1 element trong dictUnderProductID
                        let productName = dictUnderProductID.keys.first ?? ""
                        guard let dictUnderProduct = dictUnderProductID[productName] as? [String:Any] else {
                            return
                        }
                        
                        // Khi minh tao instance cua ExpenseModel de tra ve, luc nay
                        // minh ko can quan tam var id cua ExpenseModel, no se duoc dung cho List cua screen.
                        let expense = ExpenseModel(nameOfExpense: productName,
                                                   amoutExpense: dictUnderProduct["Amount"] as! Double,
                                                   dateSpendOn: dictUnderProduct["Date"] as! TimeInterval)
                        expenseArray.append(expense)
                    }
                    completion(true,expenseArray)
                } else {
                    completion(false,[])
                }
            }
        })
    }
    
    // Read all products from 1 folder
    // Bool trả về là bool của isBudgetSet
    func readDataFromOneFolder(userID: String, folderID: String, folderName: String, completion: @escaping ([ExpenseModel],Bool,Double)->Void) {
        var expenseArray: [ExpenseModel] = []
        
        // Read the isBudgetSet, budget first
        var isBudgetSet: Bool = false
        var budget: Double = 0.0
        databaseRef.child("Users").child(userID).child("folders").child(folderID).observeSingleEvent(of: .value, with: { [weak self] snapshot  in
            // What under folder's ID
            guard let dictionary = snapshot.value as? [String:Any] else {
                return
            }
            guard let boolValue = dictionary["isBudgetSet"] as? Int else {
                return
            }
            // Bool from DB sẽ có value là 1 or 0
            isBudgetSet = boolValue == 1 ? true : false
            
            guard let budgetValue = dictionary["budget"] as? Double else {
                return
            }
            budget = budgetValue
            
            /**
             - Để thằng này trong đây vì ta muốn lấy isBudgetSet first, sau đó mới run thằng này.
             - Nếu để thằng này ở ngoài thì call back của thằng này chạy trước => trả về completion xong hết trơn rồi nó mới chạy call back của thằng trên => isBudgetSet luôn luôn ko về được screen.
             */
            self?.databaseRef.child("Users").child(userID).child("folders").child(folderID).child(folderName).observeSingleEvent(of: .value, with: { [weak self] snapshot in
                guard let dictionary = snapshot.value as? [String:Any] else {
                    completion([],isBudgetSet,budget)
                    return
                }
                
                for (key,value) in dictionary {
                    let whatYouBoughtID = key
                    // SubDict = dictionary under productID
                    guard let dictUnderProductID = value as? [String:Any] else {
                        return
                    }
                    let productName = dictUnderProductID.keys.first ?? ""
                    guard let dictUnderProduct = dictUnderProductID[productName] as? [String:Any] else {
                        return
                    }
                    
                    // Khi minh tao instance cua ExpenseModel de tra ve, luc nay
                    // minh ko can quan tam var id cua ExpenseModel, no se duoc dung cho List cua screen.
                    let expense = ExpenseModel(nameOfExpense: productName,
                                               amoutExpense: dictUnderProduct["Amount"] as! Double,
                                               dateSpendOn: dictUnderProduct["Date"] as! TimeInterval)
                    expenseArray.append(expense)
                }
                completion(expenseArray,isBudgetSet,budget)
            })
        })
    }
    
    // Change isBudgetSet in Realtime DB
    func updateIsBudgetSet(userID: String, folderID: String, valueOfSwitch: Bool, completion: @escaping ((Bool) -> Void) ) {
        databaseRef.child("Users").child(userID).child("folders").child(folderID).child("isBudgetSet").setValue(valueOfSwitch) { [weak self] error, _ in
            if error == nil {
                completion(valueOfSwitch)
            } else {
                print("ERROR: \(error?.localizedDescription)")
            }
        }
    }
    
    // Change budet in each folder
    func changeBudgetInFolder(userID: String, folderID: String, budgetValue: Double, completion: @escaping(() -> Void)) {
        databaseRef.child("Users").child(userID).child("folders").child(folderID).child("budget").setValue(budgetValue) { [weak self] error, _ in
            if error == nil {
                completion()
            } else {
                print("ERROR: \(error?.localizedDescription)")
            }
        }
    }

}
