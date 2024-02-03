//
//  Check_My_WalletApp.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 8/23/23.
//

import SwiftUI
import FirebaseCore

@main
struct Check_My_WalletApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
