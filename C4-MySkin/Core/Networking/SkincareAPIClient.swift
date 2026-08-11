//
//  SkincareAPIClient.swift
//  C4-MySkin
//
//  Created by Hermes Agent on 10/08/26.
//

import Foundation

struct SkincareAPIClient {
    private let baseURL = URL(string: "https://skincare.krossmanzs.com")!
    private let session: URLSession
    private let decoder: JSONDecoder
    private let apiKey: String

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        apiKey: String? = nil
    ) {
        self.session = session
        self.decoder = decoder
        self.apiKey = apiKey ?? EnvironmentLoader.value(forKey: "API_KEY") ?? ""
    }

    func searchProducts(query: String) async throws -> ProductSearchResponse {
        try await request(
            path: "/api/products/search",
            queryItems: [URLQueryItem(name: "query", value: query)]
        )
    }

    func resolveProduct(query: String) async throws -> ProductResolveResponse {
        try await request(
            path: "/api/products/resolve",
            queryItems: [URLQueryItem(name: "query", value: query)]
        )
    }

    func getProductDossier(
        slug: String,
        enrich: Bool = true,
        skinType: String? = nil,
        skinSensitivity: String? = nil,
        concernAcnePore: String? = nil,
        concernSkinTone: String? = nil,
        concernSunDamage: String? = nil
    ) async throws -> ProductDossierResponse {
        var queryItems = [URLQueryItem(name: "enrich", value: String(enrich))]
        if let skinType { queryItems.append(URLQueryItem(name: "skin_type", value: skinType)) }
        if let skinSensitivity { queryItems.append(URLQueryItem(name: "skin_sensitivity", value: skinSensitivity)) }
        if let concernAcnePore { queryItems.append(URLQueryItem(name: "concern_acne_pore", value: concernAcnePore)) }
        if let concernSkinTone { queryItems.append(URLQueryItem(name: "concern_skin_tone", value: concernSkinTone)) }
        if let concernSunDamage { queryItems.append(URLQueryItem(name: "concern_sun_damage", value: concernSunDamage)) }

        return try await request(
            path: "/api/products/\(slug)",
            queryItems: queryItems
        )
    }

    func searchIngredients(query: String) async throws -> IngredientSearchResponse {
        try await request(
            path: "/api/ingredients/search",
            queryItems: [URLQueryItem(name: "query", value: query)]
        )
    }

    func getIngredient(slug: String) async throws -> IngredientDetailResponse {
        try await request(path: "/api/ingredients/\(slug)")
    }

    private func request<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        var components = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        guard !apiKey.isEmpty else {
            throw APIError.missingAPIKey
        }

        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let serverMessage = String(data: data, encoding: .utf8)
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: serverMessage)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case missingAPIKey
    case httpError(statusCode: Int, message: String?)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .missingAPIKey:
            return "Missing API_KEY. Add it to .env or the app environment."
        case let .httpError(statusCode, message):
            if let message, !message.isEmpty {
                return "Request failed (\(statusCode)): \(message)"
            }
            return "Request failed with status code \(statusCode)."
        case let .decodingFailed(error):
            return "Failed to decode API response: \(error.localizedDescription)"
        }
    }
}
