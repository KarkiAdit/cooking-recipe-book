//
//  LoadingComponentView.swift
//  CookBook
//
//  Created by Gwinyai Nyatsoka on 9/5/2024.
//

import SwiftUI

struct LoadingComponentView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
            ProgressView()
                .tint(Color.white)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoadingComponentView()
}
