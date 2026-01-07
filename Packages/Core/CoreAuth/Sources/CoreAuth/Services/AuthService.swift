//
//  AuthService.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import Foundation

public protocol AuthServiceProtocol {
    func login(with credentials: LoginCredentials) async throws -> AuthResult
    func signup(with credentials: SignupCredentials) async throws -> AuthResult
    func logout() async throws
    func getCurrentUser() -> User?
}

public class AuthService: AuthServiceProtocol {
    public static let shared = AuthService()
    
    private var currentUser: User?
    private let userDefaults = UserDefaults.standard
    private let userIDKey = "com.peremicrobanking.currentUserID"
    private let userTokenKey = "com.peremicrobanking.userToken"
    private let apiClient = APIClient.shared
    
    private init() {
        // Load saved user on init
        if let userID = userDefaults.string(forKey: userIDKey) {
            let token = userDefaults.string(forKey: userTokenKey)
            currentUser = User(userID: userID, token: token)
            // Set token in API client
            apiClient.setAuthToken(token)
        }
    }
    
    /// Authenticates a user with login credentials
    /// - Parameter credentials: Login credentials including User ID, Password, optional PIN and OTP
    /// - Returns: AuthResult containing user and any additional requirements
    /// - Throws: AuthError for various failure scenarios
    public func login(with credentials: LoginCredentials) async throws -> AuthResult {
        guard credentials.isValid else {
            throw AuthError.invalidInput("User ID and Password are required")
        }
        
        // Prepare request
        let request = LoginRequest(
            userID: credentials.userID,
            password: credentials.password,
            pin: credentials.pin,
            otp: credentials.otp
        )
        
        // Convert to dictionary for API call
        var body: [String: Any] = [
            "userID": request.userID,
            "password": request.password
        ]
        
        // Only include pin and otp if they're not nil
        if let pin = request.pin, !pin.isEmpty {
            body["pin"] = pin
        }
        if let otp = request.otp, !otp.isEmpty {
            body["otp"] = otp
        }
        
        do {
            // Call API
            let response: LoginResponse = try await apiClient.request(
                endpoint: "/auth/login",
                method: "POST",
                body: body,
                requiresAuth: false
            )
            
            // Check if PIN is required
            if response.requiresPIN == true {
                throw AuthError.pinRequired
            }
            
            // Check if OTP is required
            if response.requiresOTP == true {
                throw AuthError.otpRequired
            }
            
            // Create User object
            let user = User(
                userID: response.userID,
                fullName: response.fullName,
                email: response.email,
                token: response.token,
                sessionExpiry: response.expiryDate
            )
            
            // Save user and token
            self.currentUser = user
            saveUser(user)
            apiClient.setAuthToken(response.token)
            
            return AuthResult(user: user)
            
        } catch let error as APIError {
            // Convert API errors to AuthError with better error messages
            throw mapAPIError(error)
        } catch let error as AuthError {
            throw error
        } catch let error as DecodingError {
            // Better error message for decoding errors
            print("Decoding error: \(error)")
            throw AuthError.networkError
        } catch {
            // Preserve original error message
            print("Login error: \(error.localizedDescription)")
            throw AuthError.networkError
        }
    }
    
    /// Registers a new user
    /// - Parameter credentials: Signup credentials including personal info, documents, and credentials
    /// - Returns: AuthResult containing user and any additional requirements
    /// - Throws: AuthError for various failure scenarios
    public func signup(with credentials: SignupCredentials) async throws -> AuthResult {
        guard credentials.isValid else {
            throw AuthError.invalidInput("All required fields must be filled")
        }
        
        // Validate documents
        guard !credentials.documents.isEmpty else {
            throw AuthError.invalidInput("At least one document is required")
        }
        
        // Convert documents to API format with base64 encoding
        let documentRequests = credentials.documents.map { doc -> DocumentRequest in
            let frontImageBase64 = doc.frontImageData?.base64EncodedString()
            let backImageBase64 = doc.backImageData?.base64EncodedString()
            
            return DocumentRequest(
                type: doc.type.rawValue,
                documentNumber: doc.documentNumber,
                frontImage: frontImageBase64,
                backImage: backImageBase64
            )
        }
        
        // Prepare signup request
        let signupRequest = SignupRequest(
            country: credentials.country.rawValue,
            fullName: credentials.fullName,
            dateOfBirth: credentials.dateOfBirth,
            address: credentials.address,
            contactNumber: credentials.contactNumber,
            email: credentials.email,
            userID: credentials.userID,
            password: credentials.password,
            documents: documentRequests,
            otp: credentials.otp
        )
        
        // Convert to dictionary for API call
        // Date format: ISO8601 without fractional seconds (e.g., "1990-01-01T00:00:00Z")
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        var body: [String: Any] = [
            "country": signupRequest.country,
            "fullName": signupRequest.fullName,
            "dateOfBirth": formatter.string(from: signupRequest.dateOfBirth),
            "address": signupRequest.address,
            "contactNumber": signupRequest.contactNumber,
            "email": signupRequest.email,
            "userID": signupRequest.userID,
            "password": signupRequest.password,
            "documents": documentRequests.map { doc in
                var docDict: [String: Any] = [
                    "type": doc.type,
                    "documentNumber": doc.documentNumber
                ]
                if let frontImage = doc.frontImage {
                    docDict["frontImage"] = frontImage
                }
                if let backImage = doc.backImage {
                    docDict["backImage"] = backImage
                }
                return docDict
            }
        ]
        
        if let otp = signupRequest.otp {
            body["otp"] = otp
        }
        
        do {
            // Call signup API
            let response: SignupResponse = try await apiClient.request(
                endpoint: "/auth/signup",
                method: "POST",
                body: body,
                requiresAuth: false
            )
            
            // Create User object
            let user = User(
                userID: response.userID,
                fullName: credentials.fullName,
                email: credentials.email,
                token: response.token,
                sessionExpiry: response.expiryDate
            )
            
            // Save user and token
            self.currentUser = user
            saveUser(user)
            apiClient.setAuthToken(response.token)
            
            return AuthResult(user: user)
            
        } catch let error as APIError {
            throw mapAPIError(error)
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.networkError
        }
    }
    
    /// Logs out the current user
    /// - Throws: Error if logout fails
    public func logout() async throws {
        guard let _ = currentUser else {
            // Already logged out
            return
        }
        
        let request = LogoutRequest(logoutAllDevices: false)
        let body: [String: Any] = [
            "logoutAllDevices": request.logoutAllDevices as Any
        ].compactMapValues { $0 }
        
        do {
            let _: LogoutResponse = try await apiClient.request(
                endpoint: "/auth/logout",
                method: "POST",
                body: body,
                requiresAuth: true
            )
        } catch {
            // Even if API call fails, clear local session
            // Log error but don't throw
            print("Logout API call failed: \(error.localizedDescription)")
        }
        
        // Clear local session
        currentUser = nil
        userDefaults.removeObject(forKey: userIDKey)
        userDefaults.removeObject(forKey: userTokenKey)
        apiClient.setAuthToken(nil)
    }
    
    /// Gets the currently authenticated user
    /// - Returns: User if authenticated, nil otherwise
    public func getCurrentUser() -> User? {
        return currentUser
    }
    
    // MARK: - Private Helpers
    
    private func saveUser(_ user: User) {
        userDefaults.set(user.userID, forKey: userIDKey)
        if let token = user.token {
            userDefaults.set(token, forKey: userTokenKey)
        }
    }
    
    private func mapAPIError(_ error: APIError) -> AuthError {
        switch error {
        case .unauthorized:
            return AuthError.invalidCredentials
        case .badRequest(let message):
            return AuthError.invalidInput(message)
        case .networkError(let message):
            print("Network error details: \(message)")
            return AuthError.networkError
        case .decodingError(let message):
            print("Decoding error: \(message)")
            return AuthError.networkError
        case .invalidURL:
            print("Invalid URL")
            return AuthError.networkError
        case .invalidResponse:
            print("Invalid response from server")
            return AuthError.networkError
        case .rateLimited:
            return AuthError.networkError
        case .serverError:
            return AuthError.networkError
        case .notFound:
            return AuthError.networkError
        case .unknown(let code):
            print("Unknown error code: \(code)")
            return AuthError.networkError
        case .encodingError:
            print("Encoding error")
            return AuthError.networkError
        }
    }
}

