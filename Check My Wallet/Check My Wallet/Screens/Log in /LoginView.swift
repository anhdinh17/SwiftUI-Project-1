//
//  LoginView.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/12/23.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @State var isErrorAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView(title: "Check My Wallet",
                           subtitle: "",
                           angle: 15,
                           background: Color.blue)
                
                VStack {
                    VStack {
                        TextField("E-mail", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                        
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()

                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Sign up")
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 30, maxHeight: 30)
                    }
                    .padding(.bottom, 10)
                    
                    Button {
                        viewModel.login { success in
                            if success {
                                // Tu dong chuyen sang Main View
                                // Nhin giai thich o duoi
                            } else {
                                
                            }
                        }
                        /**
                         - Khi login thanh cong -> user signed in -> trong MainView, viewModel.currentUserID not empty AND viewModel.IsSignedIn = true -> hien man hinh minh muon
                         */
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
        .alert("Oops", isPresented: $isErrorAlert) {
            Button {
                
            } label: {
                Text("OK")
            }
        } message: {
            Text("\(viewModel.errorMessage)")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
