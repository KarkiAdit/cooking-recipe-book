//
//  LoginViewModel.swift
//  CookBook
//
//  Created by Aditya Karki on 12/1/25.
//

import Foundation

class LoginViewModel: ObservableObject {
    
    @Published var presentRegisterView = false
    @Published var email = ""
    @Published var password = ""
    @Published var showPassword: Bool = false
    
}
