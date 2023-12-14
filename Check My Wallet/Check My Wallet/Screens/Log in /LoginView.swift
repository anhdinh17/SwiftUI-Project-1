//
//  LoginView.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/12/23.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView(title: "Check My Wallet",
                           subtitle: "",
                           angle: 15,
                           background: Color.blue)
                
                VStack {
                    VStack {
                        TextField("E-mail", text: $viewModel.username)
                            .textFieldStyle(.roundedBorder)
                        
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()

                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Sign up")
                            .frame(width: 260, height: 40)
                    }
                    .padding(.bottom, 10)
                    
                    Button {
                        
                    } label: {
                        Text("Sign In")
                            .padding()
                            .fontWeight(.semibold)
                    }
                    .frame(width: 200, height: 40)
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(8)
                }
                // Nâng VStack này lên, không thì sẽ thấy khoảng cách với Header xa
                .offset(y: -100)
            }
            .navigationTitle("Log In")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
