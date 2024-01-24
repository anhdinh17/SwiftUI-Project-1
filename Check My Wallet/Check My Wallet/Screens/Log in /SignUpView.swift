//
//  SignUpView.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/13/23.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()
    
    var body: some View {
        VStack {
            HeaderView(title: "Sign Up",
                       subtitle: "Start Organizing Your Expenses",
                       angle: -15,
                       background: .orange)
            VStack {
                TextField("Full Name", text: $viewModel.name)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocorrectionDisabled()
                
                TextField("Email Address", text: $viewModel.email)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(DefaultTextFieldStyle())
                
                StandardButton(title: "Register", backgroundColor: .green, buttonAction: {
                    // Click on Register
                    viewModel.registerAccount()
                })
            }
            .padding()
            // Cho offset để textField ko bị keyboard che
            .offset(y: -50)

        }
        .alert("Oops", isPresented: $viewModel.isErrorAlert) {
            Button {
                
            } label: {
                Text("OK")
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
