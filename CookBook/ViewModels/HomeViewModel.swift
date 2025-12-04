import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
@Observable
class HomeViewModel {
    
    var showSignOutAlert = false
    var showAddReceipeView = false
    var receipes: [Receipe] = []
    
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
            
            print("Raw docs count:", snapshot.documents.count)
            for doc in snapshot.documents {
                print("Doc:", doc.documentID, doc.data())
            }
            
            receipes = snapshot.documents.compactMap { doc in
                let r = Receipe(snapshot: doc)
                if r == nil {
                    print("Receipe init failed for doc:", doc.documentID)
                }
                return r
            }
            
            print("Receipes after mapping:", receipes.count)
            
        } catch {
            print("Error fetching recipes:", error)
        }
    }
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
