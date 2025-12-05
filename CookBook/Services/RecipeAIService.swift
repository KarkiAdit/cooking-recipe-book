//
//  RecipeAIService.swift
//  CookBook
//
//  Created by Aditya Karki on 12/4/25.
//

import Foundation

struct RecipeContext {
    let name: String
    let ingredients: [String]
    let time: Int
    let currentInstructions: String
    let image: Data?
}

protocol RecipeAIServiceProtocol {
    func suggestInstructions(for context: RecipeContext) async throws -> String
}

final class RecipeAIService: RecipeAIServiceProtocol {
    
    private let client: GeminiClient
    
    init(client: GeminiClient = .shared) {
        self.client = client
    }
    
    func suggestInstructions(for context: RecipeContext) async throws -> String {
        let ingredientsList = context.ingredients.joined(separator: ", ")
        
        // We add specific formatting rules so the AI doesn't reply with "Sure! Here is your recipe:"
        let prompt = """
        You are a professional chef helper.
        
        Context:
        - Recipe Name: \(context.name)
        - Ingredients: \(ingredientsList)
        - Estimated Time: \(context.time) minutes
        
        Current Draft Instructions:
        \"\"\"
        \(context.currentInstructions)
        \"\"\"
        
        Task:
        Rewrite the instructions into a clear, numbered step-by-step list.
        - Keep it concise.
        - Use imperative verbs (e.g., "Chop," "Sauté," "Bake").
        - If an image is provided, use visual cues from the image to refine the steps (e.g., "until golden brown like the image").
        - Do not include conversational filler like "Here are your instructions." Just give the list.
        """
        
        // Pass the image data to the client we updated earlier
        return try await client.generate(prompt: prompt, imageData: context.image)
    }
}
