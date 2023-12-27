//
//  ExpenseFolder.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 9/3/23.
//

import Foundation

struct ExpenseFolder: Hashable, Identifiable {
    let id = UUID().uuidString
    let name: String
    var idOfEachFolder: String?
}
