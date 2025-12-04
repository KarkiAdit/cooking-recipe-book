//
//  ProgressComponentView.swift
//  CookBook
//
//  Created by Gwinyai Nyatsoka on 13/5/2024.
//

import SwiftUI

struct ProgressComponentView: View {
    
    @Binding var value: Float
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
            ProgressView("Uploading...", value: value, total: 1)
                .padding(.horizontal)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ProgressComponentView(value: .constant(0.5))
}
