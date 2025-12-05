//
//  HomeViewModel.swift
//  CookBook
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
@Observable
class HomeViewModel {
    
    // UI state
    var showSignOutAlert = false
    var showAddReceipeView = false
    
    // MARK: - Core recipe buckets
    
    /// Recipes created by the logged-in user
    var userRecipes: [Receipe] = []
    
    /// Recipes the user has saved
    var userSavedRecipes: [Receipe] = []
    
    /// All recipes in Firestore (for discovery / AI)
    var allRecipes: [Receipe] = []
    
    /// AI–suggested recipes for "Suggested For You"
    var aiSuggestedRecipes: [Receipe] = []
    
    /// Fast lookup for “is this saved?”
    var savedReceipeIds: Set<String> = []
    
    // MARK: - Services
    
    private let db = Firestore.firestore()
    private let suggestionService: RecipeSuggestionServiceProtocol
    
    init(suggestionService: RecipeSuggestionServiceProtocol = RecipeSuggestionService()) {
        self.suggestionService = suggestionService
    }
    
    // MARK: - Backwards-compatible aliases for existing views
    
    var receipes: [Receipe] {
        get { userRecipes }
        set { userRecipes = newValue }
    }
    
    var savedReceipes: [Receipe] {
        get { userSavedRecipes }
        set { userSavedRecipes = newValue }
    }
    
    var suggestedReceipes: [Receipe] {
        get { aiSuggestedRecipes }
        set { aiSuggestedRecipes = newValue }
    }
    
    // Old method names still work
    func fetchReceipes() async { await fetchUserRecipes() }
    func fetchSavedReceipes() async { await fetchSavedRecipes() }
    
    // MARK: - Fetches
    
    /// All recipes in the app (for discovery / AI)
    func fetchAllRecipes() async {
        do {
            let snapshot = try await db.collection("receipes").getDocuments()
            allRecipes = snapshot.documents.compactMap { Receipe(snapshot: $0) }
            print("Fetched ALL recipes:", allRecipes.count)
        } catch {
            print("Error fetching ALL recipes:", error)
        }
    }
    
    /// Recipes created by the logged-in user
    func fetchUserRecipes() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged in user for fetchUserRecipes")
            userRecipes = []
            return
        }
        
        do {
            let snapshot = try await db.collection("receipes")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            userRecipes = snapshot.documents.compactMap { Receipe(snapshot: $0) }
            print("Fetched user recipes:", userRecipes.count)
        } catch {
            print("Error fetching user recipes:", error)
        }
    }
    
    /// Recipes the user has saved
    func fetchSavedRecipes() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged in user for fetchSavedRecipes")
            userSavedRecipes = []
            savedReceipeIds = []
            return
        }
        
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("savedReceipes")
                .getDocuments()
            
            let models = snapshot.documents.compactMap { Receipe(snapshot: $0) }
            userSavedRecipes = models
            savedReceipeIds = Set(models.map { $0.id })
            
            print("Fetched saved recipes:", userSavedRecipes.count)
        } catch {
            print("Error fetching saved recipes:", error)
        }
    }
    
    // MARK: - AI suggestions

    /// Rebuild the AI "Suggested For You" list using Gemini.
    func refreshSuggestions(locationDescription: String) async {
        // Build context from what the user has done so far
        let context = RecipeSuggestionContext(
            locationDescription: locationDescription,
            userRecipes: userRecipes,
            savedRecipes: userSavedRecipes
        )
        
        do {
            let suggestions = try await suggestionService.suggestRecipes(for: context)
            aiSuggestedRecipes = suggestions
            print("AI suggested \(suggestions.count) new recipes")
        } catch {
            print("Error getting AI suggestions:", error)
            aiSuggestedRecipes = []
        }
    }

    /// When user saves / unsaves, also refresh suggestions.
    func toggleSave(for receipe: Receipe, locationDescription: String) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged in user for toggleSave")
            return
        }
        
        let docRef = db.collection("users")
            .document(userId)
            .collection("savedReceipes")
            .document(receipe.id)
        
        if savedReceipeIds.contains(receipe.id) {
            // Unsave
            savedReceipeIds.remove(receipe.id)
            userSavedRecipes.removeAll { $0.id == receipe.id }
            
            do {
                try await docRef.delete()
                print("Unsaved receipe:", receipe.id)
            } catch {
                print("Error unsaving receipe:", error)
            }
        } else {
            // Save
            savedReceipeIds.insert(receipe.id)
            userSavedRecipes.append(receipe)
            
            do {
                try docRef.setData(from: receipe)
                print("Saved receipe:", receipe.id)
            } catch {
                print("Error saving receipe:", error)
            }
        }
        
        // Rebuild "Suggested For You" using the new service
        await refreshSuggestions(locationDescription: locationDescription)
    }

    
    // MARK: - Sign out
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch {
            print("Sign-out error:", error)
            return false
        }
    }
}
