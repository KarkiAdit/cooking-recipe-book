//
//  UserProfileView.swift
//  CookBook
//
//  Created by Aditya Karki on 12/4/25.
//

import SwiftUI
import FirebaseAuth

struct UserProfileView: View {
    
    let yourReceipes: [Receipe]
    let savedReceipes: [Receipe]
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    private let spacing: CGFloat = 10
    private let padding: CGFloat = 10
    
    private var itemWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return (screenWidth - (spacing * 2) - (padding * 2)) / 3
    }
    
    private var itemHeight: CGFloat {
        CGFloat(1.5) * itemWidth
    }
    
    private var userName: String {
        if let email = Auth.auth().currentUser?.email,
           let namePart = email.split(separator: "@").first {
            return String(namePart)
        }
        return "User"
    }
    
    var body: some View {
        Group {
            if Auth.auth().currentUser == nil {
                VStack {
                    Spacer()
                    Text("Please sign in to view your profile.")
                        .font(.system(size: 16, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        HStack {
                            Text(userName)
                                .font(.system(size: 22, weight: .bold))
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "person.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.black)
                            }
                        }
                        .padding(.horizontal, padding)
                        .padding(.top, 12)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Recipes")
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.horizontal, padding)
                            
                            LazyVGrid(columns: columns, spacing: spacing) {
                                if yourReceipes.isEmpty {
                                    emptyState
                                } else {
                                    ForEach(yourReceipes) { receipe in
                                        NavigationLink {
                                            ReceipeDetailView(receipe: receipe)
                                        } label: {
                                            recipeCard(receipe)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, padding)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Saved Recipes")
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.horizontal, padding)
                            
                            LazyVGrid(columns: columns, spacing: spacing) {
                                if savedReceipes.isEmpty {
                                    emptyState
                                } else {
                                    ForEach(savedReceipes) { receipe in
                                        NavigationLink {
                                            ReceipeDetailView(receipe: receipe)
                                        } label: {
                                            recipeCard(receipe)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, padding)
                        }
                        
                        Spacer(minLength: 16)
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func recipeCard(_ receipe: Receipe) -> some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: receipe.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: itemWidth, height: itemHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .clipped()
            } placeholder: {
                VStack {
                    ProgressView()
                }
                .frame(width: itemWidth, height: itemHeight)
            }
            Text(receipe.name)
                .lineLimit(1)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.black)
        }
    }
    
    private var emptyState: some View {
        VStack {
            Spacer(minLength: 20)
            Text("No recipes to show yet.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    UserProfileView(
        yourReceipes: Array(Receipe.mockReceipes.prefix(3)),
        savedReceipes: Array(Receipe.mockReceipes.suffix(3))
    )
}

