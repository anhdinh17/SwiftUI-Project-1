//
//  ExpenseResposne.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/17/23.
//

import Foundation
import SwiftUI

struct FoldersModel: Identifiable, Hashable {
    var id = UUID()
    var folderName: String?
    var folderIDFromDB: String?
}

