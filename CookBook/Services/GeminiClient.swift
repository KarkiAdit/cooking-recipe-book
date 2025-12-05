//
//  GeminiClient.swift
//  CookBook
//
//  Created by Aditya Karki on 12/4/25.
//

import Foundation
import UIKit

// MARK: - Configuration

struct GeminiConfig {
    /// Retrieves the Gemini API Key from the application's Info.plist.
    static var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String ?? ""
    }
}

// MARK: - Request Structures (Multimodal)

/// The top-level structure for the /generateContent API request body.
struct GeminiRequest: Codable {
    
    struct Content: Codable {
        /// Defines a single part of the content, which can be text or inline image data.
        struct Part: Codable {
            let text: String?
            let inlineData: InlineData?
            
            enum CodingKeys: String, CodingKey {
                case text
                case inlineData = "inline_data"
            }
        }
        
        /// Contains base64-encoded image data and its MIME type.
        struct InlineData: Codable {
            let mimeType: String
            let data: String
            
            enum CodingKeys: String, CodingKey {
                case mimeType = "mime_type"
                case data
            }
        }
        
        let parts: [Part]
    }
    let contents: [Content]
}

// MARK: - Response Structures

/// The top-level structure for the /generateContent API response body.
struct GeminiResponse: Codable {
    struct Candidate: Codable {
        struct Content: Codable {
            struct Part: Codable {
                let text: String?
            }
            let parts: [Part]
        }
        let content: Content
    }
    let candidates: [Candidate]?
}

/// The structure for the /models API response body.
struct ListModelsResponse: Codable {
    struct Model: Codable {
        let name: String // e.g., "models/gemini-2.5-flash"
        let version: String?
        let displayName: String?
        let description: String?
        let supportedGenerationMethods: [String]?
    }
    let models: [Model]
}

/// Structure used to decode API errors when HTTP status code is non-2xx.
struct GeminiErrorEnvelope: Codable {
    struct APIError: Codable {
        let code: Int?
        let message: String?
        let status: String?
    }
    let error: APIError
}

// MARK: - Client Class

final class GeminiClient {
    static let shared = GeminiClient()
    
    private let session = URLSession.shared
    
    /// The REST API endpoint for content generation. Uses the stable gemini-2.5-flash alias on v1beta.
    private let modelPath = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    
    /// The REST API endpoint for listing available models.
    private let listModelsPath = "https://generativelanguage.googleapis.com/v1beta/models"

    // ------------------------------------------
    
    /**
     Sends a request to the Gemini API to generate content based on a text prompt and an optional image.
     
     The API Key is passed via the "x-goog-api-key" header for security and reliability.
     
     - Parameters:
        - prompt: The text prompt to guide the model's response.
        - imageData: Optional base64-encoded JPEG image data to provide visual context.
     - Returns: The generated text response from the model.
     - Throws: An NSError if the API key is missing, the URL is bad, or the API returns an error status code.
     */
    func generate(prompt: String, imageData: Data? = nil) async throws -> String {
        let apiKey = GeminiConfig.apiKey
        guard !apiKey.isEmpty else {
            throw NSError(domain: "GeminiClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing GEMINI_API_KEY in Info.plist"])
        }
        
        // 1. Construct URL (No API Key in query string)
        guard let url = URL(string: modelPath) else {
            throw URLError(.badURL)
        }
        
        // 2. Construct Multimodal Parts
        var parts: [GeminiRequest.Content.Part] = []
        parts.append(.init(text: prompt, inlineData: nil))
        
        if let imageData = imageData {
            let base64String = imageData.base64EncodedString()
            let imagePart = GeminiRequest.Content.Part(
                text: nil,
                inlineData: .init(mimeType: "image/jpeg", data: base64String)
            )
            parts.append(imagePart)
        }
        
        let body = GeminiRequest(contents: [.init(parts: parts)])
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        
        // 3. Construct Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Pass the API Key in the Header (Recommended authentication method)
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        
        request.httpBody = data
        
        let (responseData, response) = try await session.data(for: request)
        
        // 4. Error Handling
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            if let apiError = try? JSONDecoder().decode(GeminiErrorEnvelope.self, from: responseData) {
                let message = apiError.error.message ?? "Unknown Gemini API error"
                throw NSError(domain: "GeminiClient", code: apiError.error.code ?? http.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
            } else {
                let raw = String(data: responseData, encoding: .utf8) ?? "<non-utf8 response>"
                throw NSError(domain: "GeminiClient", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: raw])
            }
        }
        
        // 5. Success Handling
        do {
            let decoded = try JSONDecoder().decode(GeminiResponse.self, from: responseData)
            guard
                let firstCandidate = decoded.candidates?.first,
                let firstPart = firstCandidate.content.parts.first,
                let text = firstPart.text
            else {
                throw NSError(domain: "GeminiClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "No text in response"])
            }
            return text
        } catch {
            let raw = String(data: responseData, encoding: .utf8) ?? "<non-utf8 response>"
            print("Gemini raw response:", raw)
            throw error
        }
    }

    // ------------------------------------------

    /**
     Sends a request to the Gemini API to list all models available to the current API key.
     
     This is useful for troubleshooting "model not found" errors by confirming model names and key access.
     
     - Returns: An array of `Model` objects containing names, descriptions, and supported methods.
     - Throws: An NSError if the API key is missing or the API returns an authentication error (e.g., 403 or 404).
     */
    func listAvailableModels() async throws -> [ListModelsResponse.Model] {
        let apiKey = GeminiConfig.apiKey
        guard !apiKey.isEmpty else {
            throw NSError(domain: "GeminiClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing API Key"])
        }
        
        guard let url = URL(string: listModelsPath) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Pass the API Key as a header
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        
        let (responseData, response) = try await session.data(for: request)
        
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            if let apiError = try? JSONDecoder().decode(GeminiErrorEnvelope.self, from: responseData) {
                let message = apiError.error.message ?? "Unknown ListModels API error"
                throw NSError(domain: "GeminiClient", code: apiError.error.code ?? http.statusCode, userInfo: [NSLocalizedDescriptionKey: "ListModels Error: \(message)"])
            } else {
                let raw = String(data: responseData, encoding: .utf8) ?? "<non-utf8 response>"
                throw NSError(domain: "GeminiClient", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "ListModels Raw Error: \(raw)"])
            }
        }
        
        do {
            let decoded = try JSONDecoder().decode(ListModelsResponse.self, from: responseData)
            return decoded.models
        } catch {
            print("ListModels decoding error: \(error)")
            throw error
        }
    }
}
