//  HomeViewModel.swift
//  CookBook

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
@Observable
class HomeViewModel {
    
    var showSignOutAlert = false
    var showAddReceipeView = false
    
    // User's own recipes
    var receipes: [Receipe] = []
    
    // Saved recipes (and IDs for quick lookup)
    var savedReceipes: [Receipe] = []
    var savedReceipeIds: Set<String> = []
    
    // MARK: - Fetch user's own recipes
    func fetchReceipes() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged in user")
            return
        }
        
        do {
            let snapshot = try await Firestore.firestore()
                .collection("receipes")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            receipes = snapshot.documents.compactMap { Receipe(snapshot: $0) }
            print("Receipes after mapping:", receipes.count)
        } catch {
            print("Error fetching recipes:", error)
        }
    }
    
    // MARK: - Fetch saved recipes
    func fetchSavedReceipes() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged in user")
            return
        }
        
        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .collection("savedReceipes")
                .getDocuments()
            
            let models = snapshot.documents.compactMap { Receipe(snapshot: $0) }
            savedReceipes = models
            savedReceipeIds = Set(models.map { $0.id })
            
            print("Saved receipes after mapping:", savedReceipes.count)
        } catch {
            print("Error fetching saved recipes:", error)
        }
    }
    
    // MARK: - Save / unsave a recipe
    func toggleSave(for receipe: Receipe) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged in user")
            return
        }
        
        let docRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("savedReceipes")
            .document(receipe.id)
        
        if savedReceipeIds.contains(receipe.id) {
            // Unsave
            savedReceipeIds.remove(receipe.id)
            savedReceipes.removeAll { $0.id == receipe.id }
            
            do {
                try await docRef.delete()
                print("Unsaved receipe:", receipe.id)
            } catch {
                print("Error unsaving receipe:", error)
            }
        } else {
            // Save (write fields manually, no FirestoreSwift)
            savedReceipeIds.insert(receipe.id)
            savedReceipes.append(receipe)
            
            let data: [String: Any] = [
                "image": receipe.image,
                "name": receipe.name,
                "instructions": receipe.instructions,
                "time": receipe.time,
                "userId": receipe.userId
            ]
            
            do {
                try await docRef.setData(data)
                print("Saved receipe:", receipe.id)
            } catch {
                print("Error saving receipe:", error)
            }
        }
    }
    
    // MARK: - Sign out
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch {
            print("Sign out error:", error.localizedDescription)
            return false
        }
    }
}
