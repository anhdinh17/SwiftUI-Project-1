//
//  MainView.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/16/23.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewVM()
    
    var body: some View {
        // If users signed in AND currentUserId not empty,
        // show ExpenseHomeView
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            ExpenseHomeView()
        } else {
            LoginView()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
