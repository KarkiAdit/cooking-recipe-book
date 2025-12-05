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
        
        let prompt = """
        You are a professional chef assistant writing friendly, easy-to-follow cooking instructions.

        Context:
        - Recipe Name: \(context.name)
        - Ingredients: \(ingredientsList)
        - Estimated Time: \(context.time) minutes

        Current Draft Instructions (may be empty or rough):
        \"\"\"
        \(context.currentInstructions)
        \"\"\"

        Task:
        Rewrite the instructions into a clear, numbered, step-by-step list for a home cook.

        Output format (very important):
        - Return ONLY the final instructions.
        - Use a plain numbered list exactly like:
          1. ...
          2. ...
          3. ...
        - One step per line.
        - You may use simple emojis to make steps friendlier and easier to scan (for example: 🔪, 🥘, 🍽️, 🌿).
        - Do NOT use any markdown formatting: no **bold**, no bullet points (- or •), no headings, and no code blocks.
        - Do NOT repeat the recipe name or ingredients list.
        - Do NOT add any intro or outro text such as "Here are your instructions" or "Enjoy your meal."

        Style guidelines:
        - Write short, clear, conversational sentences that feel like a helpful friend explaining the recipe.
        - Use imperative verbs (e.g., "Chop the onions", "Heat the pan", "Bake for 20 minutes").
        - Where helpful, include cues for doneness (e.g., "until golden brown", "until the sauce thickens", "until the vegetables are tender").
        - If an image is provided, use visual cues from the image to refine the steps (for example: "Bake until the top looks golden and slightly crisp, similar to the image").

        Return only the numbered steps as plain text.
        """

        
        // Pass the image data to the client we updated earlier
        return try await client.generate(prompt: prompt, imageData: context.image)
    }
}
