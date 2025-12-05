//
//  HomeView.swift
//  CookBook
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    
    @State var viewModel = HomeViewModel()
    @Environment(SessionManager.self) var sessionManager: SessionManager
    @StateObject private var locationManager = LocationManager()
    
    // MARK: - Layout helpers
    
    let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    let spacing: CGFloat = 14
    let padding: CGFloat = 16
    
    var itemWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let totalSpacing = spacing
        return (screenWidth - totalSpacing - (padding * 2)) / 2
    }
    
    var itemHeight: CGFloat {
        itemWidth * 1.3
    }
    
    // MARK: - Data slices
    
    /// Most recent recipes from allRecipes
    var recentReceipes: [Receipe] {
        Array(viewModel.allRecipes.prefix(3))
    }
    
    /// AI-generated suggestions
    var suggestedReceipes: [Receipe] {
        viewModel.aiSuggestedRecipes
    }
    
    /// All recipes in Firestore (everyone’s)
    var allReceipes: [Receipe] {
        viewModel.allRecipes
    }
    
    // MARK: - Title for "Suggested For You"
    
    private var suggestedTitle: String {
        let loc = locationManager.locationDescription
        if loc.isEmpty || loc == "Unknown" {
            return "Trending Near You"
        } else {
            return "In \(loc), You Might Love…"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: New This Week (full-width rows)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Freshly added recipes this week.")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, padding)
                            .padding(.top, 12)
                        
                        VStack(spacing: 12) {
                            ForEach(recentReceipes) { receipe in
                                recentRow(receipe)
                            }
                        }
                        .padding(.horizontal, padding)
                    }
                    
                    // MARK: Suggested For You
                    if !suggestedReceipes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(suggestedTitle)
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
                    
                    // MARK: Explore All
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Explore All Dishes")
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
                    
                    Spacer(minLength: 80) // so last row isn't covered by button
                }
            }
            // Bottom Add button (fixed)
            .safeAreaInset(edge: .bottom) {
                Button {
                    viewModel.showAddReceipeView = true
                } label: {
                    Text("Add Receipe")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 6)
                .background(.ultraThinMaterial)
            }
            // Toolbar
            .toolbar {
                // Profile button (top-left)
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        UserProfileView(
                            yourReceipes: viewModel.userRecipes,
                            savedReceipes: viewModel.userSavedRecipes
                        )
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                }
                
                // Sign out button (top-right)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showSignOutAlert = true
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                }
            }
            .alert(
                "Are you sure you would like to sign out?",
                isPresented: $viewModel.showSignOutAlert
            ) {
                Button("Sign Out", role: .destructive) {
                    if viewModel.signOut() {
                        sessionManager.sessionState = .loggedOut
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        // Initial load
        .task {
            // Location
            locationManager.requestLocationIfNeeded()
            
            // Firestore data
            await viewModel.fetchUserRecipes()
            await viewModel.fetchSavedRecipes()
            await viewModel.fetchAllRecipes()
            
            // AI suggestions
            await viewModel.refreshSuggestions(
                locationDescription: locationManager.locationDescription
            )
        }
        // 🔁 Whenever location text changes → refresh suggestions
        .onChange(of: locationManager.locationDescription) { _, newDescription in
            Task {
                await viewModel.refreshSuggestions(locationDescription: newDescription)
            }
        }
        // 🔁 Whenever saved IDs change → refresh suggestions
        .onChange(of: viewModel.savedReceipeIds) { _, _ in
            Task {
                await viewModel.refreshSuggestions(
                    locationDescription: locationManager.locationDescription
                )
            }
        }
        // AddRecipe sheet
        .sheet(isPresented: $viewModel.showAddReceipeView, onDismiss: {
            Task {
                await viewModel.fetchUserRecipes()
                await viewModel.fetchSavedRecipes()
                await viewModel.fetchAllRecipes()
                await viewModel.refreshSuggestions(
                    locationDescription: locationManager.locationDescription
                )
            }
        }) {
            AddReceipeView()
        }
    }
    
    // MARK: - Bookmark button helper
    
    private func bookmarkButton(for receipe: Receipe, isSaved: Bool) -> some View {
        Button {
            Task {
                await viewModel.toggleSave(
                    for: receipe,
                    locationDescription: locationManager.locationDescription
                )
            }
        } label: {
            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSaved ? .blue : .white)
                .padding(6)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }
    
    // MARK: - Suggested placeholder helper
    
    @ViewBuilder
    private func suggestedPlaceholder(for receipe: Receipe, height: CGFloat) -> some View {
        let symbols = [
            "fork.knife",
            "flame",
            "leaf",
            "takeoutbag.and.cup.and.straw",
            "takeoutbag.and.cup.and.straw.fill"
        ]
        let index = abs(receipe.id.hashValue) % symbols.count
        let symbolName = symbols[index]
        
        ZStack {
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.85),
                    Color.red.opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            
            Image(systemName: symbolName)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white.opacity(0.95))
        }
    }
    
    // MARK: - Card views
    
    /// Full-width row for *New This Week*
    private func recentRow(_ receipe: Receipe) -> some View {
        let isSaved = viewModel.savedReceipeIds.contains(receipe.id)
        
        return NavigationLink {
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
                
                LinearGradient(
                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("NEW THIS WEEK")
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
                    
                    Text("Just added • Tap to view")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(14)
            }
            .shadow(color: Color.black.opacity(0.10), radius: 5, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            bookmarkButton(for: receipe, isSaved: isSaved)
                .padding(10)
        }
    }
    
    /// Full-width row for *Suggested*
    private func suggestedRow(_ receipe: Receipe) -> some View {
        let isSaved = viewModel.savedReceipeIds.contains(receipe.id)
        
        return NavigationLink {
            ReceipeDetailView(receipe: receipe)
        } label: {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: receipe.image)) { phase in
                    switch phase {
                    case .empty:
                        suggestedPlaceholder(for: receipe, height: 190)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .clipped()
                    case .failure:
                        suggestedPlaceholder(for: receipe, height: 190)
                    @unknown default:
                        suggestedPlaceholder(for: receipe, height: 190)
                    }
                }
                
                LinearGradient(
                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("SUGGESTED")
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
                    
                    Text("Picked just for you • Tap to view")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(14)
            }
            .shadow(color: Color.black.opacity(0.10), radius: 5, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            bookmarkButton(for: receipe, isSaved: isSaved)
                .padding(10)
        }
    }
    
    /// Grid card for Explore All – title now inside card
    private func gridCard(_ receipe: Receipe) -> some View {
        let isSaved = viewModel.savedReceipeIds.contains(receipe.id)
        
        return ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: receipe.image)) { phase in
                switch phase {
                case .empty:
                    Color.primaryFormEntry
                        .overlay(ProgressView())
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .clipped()
                case .failure:
                    Color.primaryFormEntry
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                @unknown default:
                    Color.primaryFormEntry
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .frame(width: itemWidth, height: itemHeight)
            
            // Bottom gradient + title inside card
            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
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
                }
                .foregroundStyle(.white.opacity(0.9))
            }
            .padding(8)
        }
        .frame(width: itemWidth, height: itemHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 3)
        .overlay(alignment: .topTrailing) {
            bookmarkButton(for: receipe, isSaved: isSaved)
                .padding(6)
        }
    }
}

#Preview {
    HomeView()
        .environment(SessionManager())
}
