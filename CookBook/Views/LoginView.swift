//
//  LoginView.swift
//  CookBook
//
//

import SwiftUI

struct LoginView: View {
    
    @State var viewModel = LoginViewModel()
    @Environment(SessionManager.self) var sessionManager: SessionManager
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Email")
                    .font(.system(size: 15))
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(AuthTextFieldStyle())
                Text("Password")
                    .font(.system(size: 15))
                PasswordComponentView(showPassword: $viewModel.showPassword, password: $viewModel.password)
                Button(action: {
                    Task {
                        if let user = await viewModel.login() {
                            sessionManager.currentUser = user
                            sessionManager.sessionState = .loggedIn
                        }
                    }
                }, label: {
                    Text("Login")
                })
                .buttonStyle(PrimaryButtonStyle())
                HStack {
                    Spacer()
                    Text("Don't have an account?")
                        .font(.system(size: 14))
                    Button(action: {
                        viewModel.presentRegisterView = true
                    }, label: {
                        Text("Register now")
                            .font(.system(size: 14, weight: .semibold))
                    })
                    Spacer()
                }
                .padding(.top, 20)
                    
            }
            .padding(.horizontal, 10)
            .fullScreenCover(isPresented: $viewModel.presentRegisterView, content: {
                RegisterView()
            })
            if viewModel.isLoading {
                LoadingComponentView()
            }
        }
        .alert("Error", isPresented: $viewModel.presentAlert) {
            
        } message: {
            Text(viewModel.errorMessage)
        }

    }
}

#Preview {
    LoginView()
        .environment(SessionManager())
}
