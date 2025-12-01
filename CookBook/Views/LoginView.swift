//
//  LoginView.swift
//  CookBook
//
//  Created by Aditya Karki on 12/1/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Email")
                .font(.system(size: 15))
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textFieldStyle(AuthTextFieldStyle())
                
            Text("Password")
                .font(.system(size: 15))
            if viewModel.showPassword {
                TextField("Password", text: $viewModel.password)
                    .textFieldStyle(AuthTextFieldStyle())
                    .overlay(alignment: .trailing){
                        Button(action: {
                            viewModel.showPassword = false
                        }, label: {
                            Image(systemName: "eye")
                                .foregroundStyle(.black)
                                .padding(.bottom)
                        })
                    }
            } else {
                VStack {
                    SecureField("Password", text: $viewModel.password)
                        .font(.system(size: 14))
                    Rectangle()
                        .fill(Color.border)
                        .frame(height: 1)
                        .padding(.bottom, 15)
                }
                .overlay(alignment: .trailing){
                    Button(action: {
                        viewModel.showPassword = true
                    }, label: {
                        Image(systemName: "eye.slash")
                            .foregroundStyle(.black)
                            .padding(.bottom)
                    })
                }
            }
            Button(action: {}, label: {
                Text("Login")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(12)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .background(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
            })
            
            HStack{
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
        .fullScreenCover(isPresented: $viewModel.presentRegisterView, content: {RegisterView()})
    }
}

#Preview {
    LoginView()
}
