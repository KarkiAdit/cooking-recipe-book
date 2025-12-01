//
//  AuthTextFieldStyle.swift
//  CookBook
//
//  Created by Aditya Karki on 12/1/25.
//

import Foundation
import SwiftUI

struct AuthTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack {
            configuration
                .font(.system(size: 14))
                .textInputAutocapitalization(.never)
            Rectangle()
                .fill(Color.border)
                .frame(height: 1)
                .padding(.bottom, 15)

        }
    }
}
