//
//  LoginView.swift
//  CookBook
//
//  Created by Aditya Karki on 12/1/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Email")
                .font(.system(size: 15))
            TextField("Email", text: $email)
                .font(.system(size: 14))
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            Rectangle()
                .fill(Color.border)
                .frame(height: 1)
                .padding(.bottom, 15)
            
            Text("Password")
                .font(.system(size: 15))
            SecureField("Password", text: $password)
                .font(.system(size: 14))
            Rectangle()
                .fill(Color.border)
                .frame(height: 1)
                .padding(.bottom, 15)
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
                    
                }, label: {
                    Text("Register now")
                        .font(.system(size: 14, weight: .semibold))
                })
                Spacer()
                    
            }
            .padding(.top, 20)

        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    LoginView()
}
