//
//  LoadingComponentView.swift
//  CookBook
//
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
