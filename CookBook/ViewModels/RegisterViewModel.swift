//
//  RegisterViewModel.swift
//  CookBook
//
//  Created by Gwinyai Nyatsoka on 3/5/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@Observable
class RegisterViewModel {
    
    var username = ""
    var email = ""
    var showPassword = false
    var password = ""
    var isLoading = false
    var errorMessage = ""
    var presentAlert = false
    
    func signup() async -> User? {
        
        guard validateUsername() else {
            errorMessage = "Username must be greater than 3 charatcers and less than 25 characters."
            presentAlert = true
            return nil
        }
        
        isLoading = true
        
        guard let usernameDocuments = try? await Firestore.firestore().collection("users").whereField("username", isEqualTo: username).getDocuments() else {
            errorMessage = "Something has gone wrong. Please try again later."
            presentAlert = true
            isLoading = false
            return nil
        }
        
        guard usernameDocuments.documents.count == 0 else {
            errorMessage = "Username already exists"
            presentAlert = true
            isLoading = false
            return nil
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let userId = result.user.uid
            let user = User(id: userId, username: username, email: email)
            try Firestore.firestore().collection("users").document(userId).setData(from: user)
            isLoading = false
            return user
        } catch(let error) {
            errorMessage = "Sign Up Failed"
            let errorCode = error._code
            if let authErrorCode = AuthErrorCode.Code(rawValue: errorCode) {
                switch authErrorCode {
                case .emailAlreadyInUse:
                    errorMessage = "Email Already In Use"
                case .invalidEmail:
                    errorMessage = "Invalid Email"
                case .weakPassword:
                    errorMessage = "Weak Password"
                default:
                    break
                }
            }
            isLoading = false
            presentAlert = true
            return nil
        }
    }
    
    func validateUsername() -> Bool {
        username.count >= 3 && username.count < 25
    }
    
    
}
