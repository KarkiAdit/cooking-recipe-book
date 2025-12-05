import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

@Observable
class AddReceipeViewModel {
    
    var receipeName = ""
    var preparationTime = 0
    var instructions = ""
    var showImageOptions = false
    var showLibrary = false
    var displayedReceipeImage: Image?
    var receipeImage: UIImage?
    var showCamera = false
    var uploadProgress: Float = 0
    var isUploading = false
    var isLoading = false
    var showAlert = false
    var alertTitle = ""
    var alertMessage = ""
    
    var isAIProcessing = false
    var aiErrorMessage = ""
    
    private let recipeAIService: RecipeAIServiceProtocol
    
    init(recipeAIService: RecipeAIServiceProtocol = RecipeAIService()) {
        self.recipeAIService = recipeAIService
    }
    
    func addReceipe(imageURL: URL, handler: @escaping (_ success: Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            createAlert(title: "Not Signed In", message: "Please sign in to create receipes.")
            handler(false)
            return
        }
        guard receipeName.count >= 2 else {
            createAlert(title: "Invalid Receipe Name", message: "Receipe name must be 2 or more characters long.")
            handler(false)
            return
        }
        guard instructions.count >= 5 else {
            createAlert(title: "Invalid Intructions", message: "Instructions must be 5 or more characters long.")
            handler(false)
            return
        }
        guard preparationTime != 0 else {
            createAlert(title: "Invalid Preparation Time", message: "Preparation time must be greater than 0 minutes.")
            handler(false)
            return
        }
        isLoading = true
        let ref = Firestore.firestore().collection("receipes").document()
        let receipe = Receipe(id: ref.documentID, name: receipeName, image: imageURL.absoluteString, instructions: instructions, time: preparationTime, userId: userId)
        do {
            try Firestore.firestore().collection("receipes").document(ref.documentID).setData(from: receipe) { error in
                self.isLoading = false
                if let error = error {
                    print(error.localizedDescription)
                    self.createAlert(title: "Could Not Save Receipe", message: "We could not save your receipe right now, please try later.")
                    handler(false)
                    return
                }
                handler(true)
            }
        } catch {
            createAlert(title: "Could Not Save Receipe", message: "We could not save your receipe right now, please try later.")
            isLoading = false
            handler(false)
        }
    }
    
    private func createAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    func upload() async -> URL? {
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
        guard let receipeImage = receipeImage,
              let imageData = receipeImage.jpegData(compressionQuality: 0.7) else {
            createAlert(title: "Image Upload Failed", message: "Your receipe image could not be uploaded.")
            return nil
        }
        
        let imageID = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "_")
        let imageName = "\(imageID).jpg"
        let imagePath = "images/\(userId)/\(imageName)"
        let storageRef = Storage.storage().reference(withPath: imagePath)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        isUploading = true
        do {
            let _ = try await storageRef.putDataAsync(imageData, metadata: metaData) { progress in
                if let progress = progress {
                    let percentComplete = Float(progress.completedUnitCount / progress.totalUnitCount)
                    self.uploadProgress = percentComplete
                }
            }
            isUploading = false
            let downloadURL = try await storageRef.downloadURL()
            return downloadURL
        } catch {
            createAlert(title: "Image Upload Failed", message: "Your receipe image could not be uploaded.")
            isUploading = false
            return nil
        }
    }
    
    func generateAIInstructions() async {
        isAIProcessing = true
        defer { isAIProcessing = false }
        
        let imageData = receipeImage?.jpegData(compressionQuality: 0.7)
        
        let context = RecipeContext(
            name: receipeName,
            ingredients: [],
            time: preparationTime,
            currentInstructions: instructions,
            image: imageData
        )
        
        do {
            let suggestion = try await recipeAIService.suggestInstructions(for: context)
            instructions = suggestion
        } catch {
            aiErrorMessage = error.localizedDescription
            createAlert(title: "AI Error", message: aiErrorMessage)
        }
    }
}
