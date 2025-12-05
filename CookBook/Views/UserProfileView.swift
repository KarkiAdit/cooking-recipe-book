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
    
    // Layout
    private let gridColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    private let spacing: CGFloat = 14
    private let padding: CGFloat = 16
    
    private var gridItemWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let totalSpacing = spacing
        return (screenWidth - totalSpacing - (padding * 2)) / 2
    }
    
    private var gridItemHeight: CGFloat {
        gridItemWidth * 1.25
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
                // Not logged in
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
                        
                        // Header
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hi, \(userName)")
                                    .font(.system(size: 22, weight: .bold))
                                Text("Welcome back to your kitchen 👨‍🍳")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: 42, height: 42)
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(.black)
                            }
                        }
                        .padding(.horizontal, padding)
                        .padding(.top, 12)
                        
                        // MARK: Your Recipes (full-width like "New This Week")
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Recipes")
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.horizontal, padding)
                            
                            if yourReceipes.isEmpty {
                                emptyState(message: "You haven’t added any recipes yet.\nStart by creating your first dish!")
                                    .padding(.horizontal, padding)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(yourReceipes) { receipe in
                                        yourRecipeRow(receipe)
                                    }
                                }
                                .padding(.horizontal, padding)
                            }
                        }
                        
                        // MARK: Saved Recipes (2-column grid, same style as Explore All)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Saved Recipes")
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.horizontal, padding)
                            
                            if savedReceipes.isEmpty {
                                emptyState(message: "Recipes you save will appear here.\nTap the bookmark icon on any recipe to save it.")
                                    .padding(.horizontal, padding)
                            } else {
                                LazyVGrid(columns: gridColumns, spacing: spacing) {
                                    ForEach(savedReceipes) { receipe in
                                        NavigationLink {
                                            ReceipeDetailView(receipe: receipe)
                                        } label: {
                                            savedRecipeCard(receipe)
                                        }
                                    }
                                }
                                .padding(.horizontal, padding)
                            }
                        }
                        
                        Spacer(minLength: 24)
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Your Recipe Row (full-width hero card)
    
    private func yourRecipeRow(_ receipe: Receipe) -> some View {
        NavigationLink {
            ReceipeDetailView(receipe: receipe)
        } label: {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: receipe.image)) { phase in
                    switch phase {
                    case .empty:
                        Color.primaryFormEntry
                            .frame(height: 190)
                            .overlay(ProgressView())
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .clipped()
                    case .failure:
                        Color.primaryFormEntry
                            .frame(height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    @unknown default:
                        Color.primaryFormEntry
                            .frame(height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
                
                // Gradient overlay at bottom
                LinearGradient(
                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("YOUR RECIPE")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Capsule())
                        
                        Text("\(receipe.time) mins")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    
                    Text(receipe.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    
                    Text("Created by you • Tap to view")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(14)
            }
            .shadow(color: Color.black.opacity(0.10), radius: 5, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Saved Recipe Card (2-column, same vibe as Explore All)
    
    private func savedRecipeCard(_ receipe: Receipe) -> some View {
        let accent = accentColor(for: receipe)
        
        return ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: receipe.image)) { phase in
                switch phase {
                case .empty:
                    Color.primaryFormEntry
                        .frame(width: gridItemWidth, height: gridItemHeight)
                        .overlay(
                            ProgressView()
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: gridItemWidth, height: gridItemHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .clipped()
                case .failure:
                    Color.primaryFormEntry
                        .frame(width: gridItemWidth, height: gridItemHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                @unknown default:
                    Color.primaryFormEntry
                        .frame(width: gridItemWidth, height: gridItemHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            
            // Bottom gradient so text is readable
            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            
            // Text overlay (title + minutes)
            VStack(alignment: .leading, spacing: 4) {
                Text(receipe.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 11, weight: .medium))
                    Text("\(receipe.time) mins")
                        .font(.system(size: 11))
                    
                    Spacer()
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(accent)
                }
                .foregroundStyle(.white.opacity(0.9))
            }
            .padding(10)
        }
        .frame(width: gridItemWidth, height: gridItemHeight)
        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 3)
    }
    
    private func accentColor(for receipe: Receipe) -> Color {
        let palette: [Color] = [
            .orange, .pink, .teal, .blue, .purple
        ]
        let index = abs(receipe.id.hashValue) % palette.count
        return palette[index]
    }
    
    // MARK: - Empty state
    
    private func emptyState(message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "rectangle.on.rectangle.slash")
                .font(.system(size: 26))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

#Preview {
    UserProfileView(
        yourReceipes: Array(Receipe.mockReceipes.prefix(3)),
        savedReceipes: Array(Receipe.mockReceipes.suffix(3))
    )
}
