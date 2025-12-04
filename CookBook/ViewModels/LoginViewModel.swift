//
//  LoginViewModel.swift
//  CookBook
//
//  Created by Gwinyai Nyatsoka on 2/5/2024.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@Observable
class LoginViewModel {
    
    var presentRegisterView = false
    var email = ""
    var password = ""
    var showPassword = false
    var errorMessage = ""
    var presentAlert = false
    var isLoading = false
    
    func login() async -> User? {
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let userId = result.user.uid
            let user = try await Firestore.firestore().collection("users").document(userId).getDocument(as: User.self)
            isLoading = false
            return user
        } catch(let error) {
            isLoading = false
            errorMessage = "Login Failed"
            let errorCode = error._code
            if let authErrorCode = AuthErrorCode.Code(rawValue: errorCode) {
                switch authErrorCode {
                case .wrongPassword:
                    errorMessage = "Wrong Password"
                case .invalidEmail:
                    errorMessage = "Wrong Email"
                default:
                    break
                }
            }
            presentAlert = true
            return nil
        }
    }
    
}
