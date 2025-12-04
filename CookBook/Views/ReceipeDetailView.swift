//
//  ReceipeDetailView.swift
//  CookBook
//
//  Created by Gwinyai Nyatsoka on 4/5/2024.
//

import SwiftUI

struct ReceipeDetailView: View {
    
    let receipe: Receipe
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: receipe.image)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
            } placeholder: {
                ZStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 250)
                    Image(systemName: "photo.fill")
                }
            }
            
            HStack {
                Text(receipe.name)
                    .font(.system(size: 22, weight: .semibold))
                Spacer()
                Image(systemName: "clock.fill")
                    .font(.system(size: 15))
                Text("\(receipe.time) mins")
                    .font(.system(size: 15))
            }
            .padding(.top)
            .padding(.horizontal)
            Text(receipe.instructions)
                .font(.system(size: 15))
                .padding(.top, 10)
                .padding(.horizontal)
            Spacer()
        }
    }
}

#Preview {
    ReceipeDetailView(receipe: Receipe.mockReceipes[0])
}
