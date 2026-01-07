//
//  APIClient.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import Foundation

public class APIClient {
    public static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    private var authToken: String?
    
    private init() {
        // TODO: Move this to ConfigKit or environment configuration
        #if DEBUG
        self.baseURL = "http://127.0.0.1:8080"
        #else
        self.baseURL = "https://api.peremicrobanking.com" // Update with production URL
        #endif
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        // Allow HTTP connections for localhost (bypasses ATS for development)
        #if DEBUG
        if baseURL.contains("127.0.0.1") || baseURL.contains("localhost") {
            // For localhost development, we need to allow HTTP
            // This is handled by Info.plist ATS exceptions
        }
        #endif
        
        self.session = URLSession(configuration: configuration)
    }
    
    public func setAuthToken(_ token: String?) {
        self.authToken = token
    }
    
    // MARK: - Generic Request Method
    
    public func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        let fullURL = "\(baseURL)\(endpoint)"
        print("🌐 API Request: \(method) \(fullURL)")
        
        guard let url = URL(string: fullURL) else {
            print("❌ Invalid URL: \(fullURL)")
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Log request body for debugging
        if let body = body {
            if let jsonData = try? JSONSerialization.data(withJSONObject: body),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 Request Body: \(jsonString)")
            }
        }
        
        if requiresAuth {
            guard let token = authToken else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                throw APIError.encodingError
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw APIError.invalidResponse
            }
            
            print("📥 Response Status: \(httpResponse.statusCode)")
            
            // Log response data for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Body: \(responseString)")
            }
            
            // Handle HTTP errors
            switch httpResponse.statusCode {
            case 200...299:
                print("✅ Success")
                break
            case 401:
                throw APIError.unauthorized
            case 400:
                if let errorData = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    throw APIError.badRequest(errorData.message)
                }
                throw APIError.badRequest("Bad request")
            case 404:
                throw APIError.notFound
            case 429:
                throw APIError.rateLimited
            case 500...599:
                throw APIError.serverError
            default:
                throw APIError.unknown(httpResponse.statusCode)
            }
            
            // Decode response
            let decoder = JSONDecoder()
            
            // Flexible date decoding - try ISO8601 first, then custom formats
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // Try ISO8601 with fractional seconds
                let iso8601Formatter = ISO8601DateFormatter()
                iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = iso8601Formatter.date(from: dateString) {
                    return date
                }
                
                // Try ISO8601 without fractional seconds
                iso8601Formatter.formatOptions = [.withInternetDateTime]
                if let date = iso8601Formatter.date(from: dateString) {
                    return date
                }
                
                // Try custom format: "1990-01-01T00:00:00Z"
                let customFormatter = DateFormatter()
                customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                customFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                if let date = customFormatter.date(from: dateString) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
            }
            
            return try decoder.decode(T.self, from: data)
            
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            let errorMessage = "Failed to decode response: \(error.localizedDescription)"
            print("DecodingError: \(error)")
            if case .keyNotFound(let key, let context) = error {
                print("Missing key: \(key.stringValue), context: \(context)")
            }
            if case .typeMismatch(let type, let context) = error {
                print("Type mismatch: expected \(type), context: \(context)")
            }
            throw APIError.decodingError(errorMessage)
        } catch let urlError as URLError {
            let errorMessage = "Network error: \(urlError.localizedDescription)"
            print("URLError: \(urlError.code.rawValue) - \(errorMessage)")
            throw APIError.networkError(errorMessage)
        } catch {
            let errorMessage = "Network error: \(error.localizedDescription)"
            print("Unknown error: \(error)")
            throw APIError.networkError(errorMessage)
        }
    }
}

// MARK: - API Error Types

public enum APIError: LocalizedError {
    case invalidURL
    case encodingError
    case decodingError(String)
    case networkError(String)
    case invalidResponse
    case unauthorized
    case badRequest(String)
    case notFound
    case rateLimited
    case serverError
    case unknown(Int)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingError:
            return "Failed to encode request"
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized. Please login again."
        case .badRequest(let message):
            return message
        case .notFound:
            return "Resource not found"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .serverError:
            return "Server error. Please try again later."
        case .unknown(let code):
            return "Unknown error (code: \(code))"
        }
    }
}

struct APIErrorResponse: Decodable {
    let message: String
    let error: String?
}

