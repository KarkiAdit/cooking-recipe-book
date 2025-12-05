//
//  HomeView.swift
//  CookBook
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    
    @State var viewModel = HomeViewModel()
    @Environment(SessionManager.self) var sessionManager: SessionManager
    
    // 3-column grid for "All"
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    let spacing: CGFloat = 10
    let padding: CGFloat = 10
    
    var itemWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return (screenWidth - (spacing * 2) - (padding * 2)) / 3
    }
    
    var itemHeight: CGFloat {
        CGFloat(1.5) * itemWidth
    }
    
    // MARK: - Sections
    
    /// Last 3 recipes (most recently fetched / added)
    var recentReceipes: [Receipe] {
        Array(viewModel.receipes.suffix(3).reversed())
    }
    
    /// Suggested = saved recipes (up to 3)
    var suggestedReceipes: [Receipe] {
        Array(viewModel.savedReceipes.prefix(3))
    }
    
    /// All user's recipes
    var allReceipes: [Receipe] {
        viewModel.receipes
    }
    
    private var userDisplayName: String {
        if let user = Auth.auth().currentUser {
            if let name = user.displayName, !name.isEmpty {
                return name
            }
            if let email = user.email,
               let prefix = email.split(separator: "@").first {
                return String(prefix)
            }
        }
        return "User"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: Recently Added
                    if !recentReceipes.isEmpty {
                        HStack {
                            Text("Recently Added")
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                            Text(userDisplayName)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, padding)
                        .padding(.top, 12)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(recentReceipes) { receipe in
                                    recentCard(receipe)
                                }
                            }
                            .padding(.horizontal, padding)
                        }
                    }
                    
                    // MARK: Suggested For You (saved)
                    if !suggestedReceipes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Suggested For You")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(.horizontal, padding)
                            
                            VStack(spacing: 12) {
                                ForEach(suggestedReceipes) { receipe in
                                    suggestedRow(receipe)
                                }
                            }
                            .padding(.horizontal, padding)
                        }
                    }
                    
                    // MARK: All
                    if !allReceipes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("All")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(.horizontal, padding)
                            
                            LazyVGrid(columns: columns, spacing: spacing) {
                                ForEach(allReceipes) { receipe in
                                    NavigationLink {
                                        ReceipeDetailView(receipe: receipe)
                                    } label: {
                                        gridCard(receipe)
                                    }
                                }
                            }
                            .padding(.horizontal, padding)
                        }
                    }
                    
                    // extra bottom padding so last row isn't hidden behind button
                    Spacer(minLength: 80)
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Bottom Add button
                Button(action: {
                    viewModel.showAddReceipeView = true
                }, label: {
                    Text("Add Receipe")
                })
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 6)
                .background(.ultraThinMaterial)
            }
            .toolbar {
                // Profile (leading)
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        UserProfileView(
                            yourReceipes: viewModel.receipes,
                            savedReceipes: viewModel.savedReceipes
                        )
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.black)
                    }
                }
                
                // Logout (trailing)
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.showSignOutAlert = true
                    }, label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(.black)
                    })
                }
            }
            .alert("Are you sure you would like to sign out?", isPresented: $viewModel.showSignOutAlert) {
                Button("Sign Out", role: .destructive) {
                    if viewModel.signOut() {
                        sessionManager.sessionState = .loggedOut
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        .task {
            await viewModel.fetchReceipes()
            await viewModel.fetchSavedReceipes()
        }
        .sheet(isPresented: $viewModel.showAddReceipeView, onDismiss: {
            Task {
                await viewModel.fetchReceipes()
                await viewModel.fetchSavedReceipes()
            }
        }) {
            AddReceipeView()
        }
    }
    
    // MARK: - Save overlay helper
    
    private func bookmarkOverlay(for receipe: Receipe) -> some View {
        let isSaved = viewModel.savedReceipeIds.contains(receipe.id)
        
        return Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
            .font(.system(size: 13, weight: .semibold))
            .padding(6)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .padding(6)
            .onTapGesture {
                Task {
                    await viewModel.toggleSave(for: receipe)
                }
            }
    }
    
    // MARK: - Card views
    
    private func recentCard(_ receipe: Receipe) -> some View {
        NavigationLink {
            ReceipeDetailView(receipe: receipe)
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 4) {
                    AsyncImage(url: URL(string: receipe.image)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: itemWidth, height: itemHeight * 0.9)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .clipped()
                    } placeholder: {
                        VStack {
                            ProgressView()
                        }
                        .frame(width: itemWidth, height: itemHeight * 0.9)
                    }
                    Text(receipe.name)
                        .lineLimit(1)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.black)
                }
                
                bookmarkOverlay(for: receipe)
            }
        }
    }
    
    private func suggestedRow(_ receipe: Receipe) -> some View {
        NavigationLink {
            ReceipeDetailView(receipe: receipe)
        } label: {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: receipe.image)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .clipped()
                    } placeholder: {
                        VStack {
                            ProgressView()
                        }
                        .frame(width: 90, height: 90)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(receipe.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.black)
                            .lineLimit(1)
                        Text("\(receipe.time) mins • Tap to view")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding(10)
                .background(Color.primaryFormEntry.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                bookmarkOverlay(for: receipe)
            }
        }
    }
    
    private func gridCard(_ receipe: Receipe) -> some View {
        ZStack(alignment: .topTrailing) {
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
            
            bookmarkOverlay(for: receipe)
        }
    }
}

#Preview {
    HomeView()
        .environment(SessionManager())
}
