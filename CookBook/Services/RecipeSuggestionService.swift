//
//  RecipeSuggestionService.swift
//  CookBook
//

import Foundation

/// Info Gemini uses to come up with new ideas (not from Firestore).
struct RecipeSuggestionContext {
    /// Human-readable location like "Nashville, Tennessee".
    let locationDescription: String
    /// Recipes the user has created.
    let userRecipes: [Receipe]
    /// Recipes the user has saved.
    let savedRecipes: [Receipe]
}

protocol RecipeSuggestionServiceProtocol {
    /// Return up to a few brand-new recipes Gemini thinks the user would like.
    func suggestRecipes(for context: RecipeSuggestionContext) async throws -> [Receipe]
}

final class RecipeSuggestionService: RecipeSuggestionServiceProtocol {
    
    private let client: GeminiClient
    
    init(client: GeminiClient = .shared) {
        self.client = client
    }
    
    // Internal DTO for parsing Gemini’s JSON.
    private struct AISuggestedRecipeDTO: Codable {
        let name: String
        let timeMinutes: Int
        let description: String
        let region: String?
    }
    
    func suggestRecipes(for context: RecipeSuggestionContext) async throws -> [Receipe] {
        let location = context.locationDescription
        
        // Summarise user behaviour (only a few to keep prompt small)
        let createdSummary = context.userRecipes.prefix(5).map { r in
            "- \(r.name) (\(r.time) mins)"
        }.joined(separator: "\n")
        
        let savedSummary = context.savedRecipes.prefix(5).map { r in
            "- \(r.name) (\(r.time) mins)"
        }.joined(separator: "\n")
        
        let prompt = """
        You are a professional chef and recipe recommendation engine.

        The user is currently located in: \(location)

        Recipes this user has COOKED / CREATED:
        \(createdSummary.isEmpty ? "- (none yet)" : createdSummary)

        Recipes this user has SAVED:
        \(savedSummary.isEmpty ? "- (none yet)" : savedSummary)

        Based on this, invent up to 3 NEW recipe ideas that:
        - Feel appropriate for the user's location (cuisine, climate, culture).
        - Match or nicely complement the styles above.
        - Are NOT already in the lists above.

        Respond ONLY with valid JSON, as an array of objects like:

        [
          {
            "name": "Butter Chicken Nashville Style",
            "timeMinutes": 50,
            "description": "Short, friendly one-paragraph description of the dish and why they'd like it.",
            "region": "Indian-American fusion"
          }
        ]
        No extra text, no backticks, no explanation — just the JSON.
        """
        
        let text = try await client.generate(prompt: prompt)
        
        guard let data = text.data(using: .utf8) else {
            return []
        }
        
        let dtoList: [AISuggestedRecipeDTO]
        do {
            dtoList = try JSONDecoder().decode([AISuggestedRecipeDTO].self, from: data)
        } catch {
            print("Failed to parse AI suggestions JSON, raw:", text)
            return []
        }
        
        // Map AI DTOs into Receipe models so the UI can reuse existing views.
        let mapped: [Receipe] = dtoList.map { dto in
            Receipe(
                id: "ai-\(UUID().uuidString)",
                name: dto.name,
                image: "",                           // empty -> AsyncImage will show placeholder
                instructions: dto.description,       // use description as "instructions" text
                time: dto.timeMinutes,
                userId: "ai_suggested"               // special marker; not a real user
            )
        }
        
        return mapped
    }
}
