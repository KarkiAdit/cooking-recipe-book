//
//  CapsuleTextFieldStyle.swift
//  CookBook
//
//  Created by Gwinyai Nyatsoka on 5/5/2024.
//

import Foundation
import SwiftUI

struct CapsuleTextFieldStyle: TextFieldStyle {
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                Capsule()
                    .fill(Color.primaryFormEntry)
            )
    }
    
}
