//
//  SignupViewModel.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
public class SignupViewModel: ObservableObject {
    // Country Selection
    @Published public var selectedCountry: Country?
    
    // Personal Information
    @Published public var fullName: String = ""
    @Published public var dateOfBirth: Date = Date()
    @Published public var address: String = ""
    @Published public var contactNumber: String = ""
    @Published public var email: String = ""
    
    // Credentials
    @Published public var userID: String = ""
    @Published public var password: String = ""
    @Published public var confirmPassword: String = ""
    
    // Documents
    @Published public var documents: [DocumentUpload] = []
    @Published public var selectedDocumentType: DocumentType = .aadhaar
    @Published public var documentNumber: String = ""
    @Published public var documentFrontImage: UIImage?
    @Published public var documentBackImage: UIImage?
    
    // OTP
    @Published public var otp: String = ""
    @Published public var otpSent: Bool = false
    
    // State
    @Published public var authState: AuthState = .unauthenticated
    @Published public var errorMessage: String?
    @Published public var isLoading: Bool = false
    @Published public var currentStep: SignupStep = .countrySelection
    
    public enum SignupStep {
        case countrySelection
        case personalInfo
        case documents
        case credentials
        case otpVerification
    }
    
    // Computed property for available documents based on country
    public var availableDocuments: [DocumentType] {
        guard let country = selectedCountry else { return [] }
        return DocumentType.documents(for: country)
    }
    
    // Computed property for required documents based on country
    public var requiredDocuments: [DocumentType] {
        guard let country = selectedCountry else { return [] }
        return DocumentType.documents(for: country).filter { $0.isRequired }
    }
    
    private let authService: AuthServiceProtocol
    private let otpService: OTPServiceProtocol
    
    public init(
        authService: AuthServiceProtocol = AuthService.shared,
        otpService: OTPServiceProtocol = OTPService.shared
    ) {
        self.authService = authService
        self.otpService = otpService
    }
    
    /// Sets the selected country and updates available documents
    public func selectCountry(_ country: Country) {
        selectedCountry = country
        // Reset documents when country changes
        documents = []
        // Set first available document as default
        if let firstDoc = availableDocuments.first {
            selectedDocumentType = firstDoc
        }
        errorMessage = nil
    }
    
    /// Adds a document to the documents array
    public func addDocument() {
        guard let country = selectedCountry else {
            errorMessage = "Please select a country first"
            return
        }
        
        guard !documentNumber.isEmpty else {
            errorMessage = "Document number is required"
            return
        }
        
        guard let frontImage = documentFrontImage,
              let frontImageData = frontImage.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Document front image is required"
            return
        }
        
        // Validate document type is available for selected country
        guard availableDocuments.contains(selectedDocumentType) else {
            errorMessage = "This document type is not available for \(country.rawValue)"
            return
        }
        
        let backImageData = documentBackImage?.jpegData(compressionQuality: 0.8)
        
        let document = DocumentUpload(
            type: selectedDocumentType,
            documentNumber: documentNumber,
            frontImageData: frontImageData,
            backImageData: backImageData
        )
        
        // Check if document type already exists
        if documents.contains(where: { $0.type == selectedDocumentType }) {
            errorMessage = "\(selectedDocumentType.rawValue) has already been added"
            return
        }
        
        documents.append(document)
        
        // Reset document fields
        documentNumber = ""
        documentFrontImage = nil
        documentBackImage = nil
        errorMessage = nil
    }
    
    /// Removes a document from the documents array
    public func removeDocument(_ document: DocumentUpload) {
        documents.removeAll { $0.type == document.type }
    }
    
    /// Sends OTP to registered contact number
    public func sendOTP() async {
        guard !contactNumber.isEmpty else {
            errorMessage = "Contact number is required"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await otpService.sendOTP(to: contactNumber)
            otpSent = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Verifies OTP and completes signup
    public func signup() async {
        guard validateInputs() else {
            return
        }
        
        isLoading = true
        authState = .authenticating
        errorMessage = nil
        
        do {
            // Verify OTP first
            if otpSent {
                let isValid = try await otpService.verifyOTP(otp, for: contactNumber)
                guard isValid else {
                    errorMessage = "Invalid OTP"
                    isLoading = false
                    return
                }
            }
            
            guard let country = selectedCountry else {
                errorMessage = "Country selection is required"
                isLoading = false
                return
            }
            
            let credentials = SignupCredentials(
                country: country,
                fullName: fullName,
                dateOfBirth: dateOfBirth,
                address: address,
                contactNumber: contactNumber,
                email: email,
                userID: userID,
                password: password,
                documents: documents,
                otp: otp.isEmpty ? nil : otp
            )
            
            let result = try await authService.signup(with: credentials)
            authState = .authenticated
            // Post notification to trigger navigation to ContentView
            NotificationCenter.default.post(name: NSNotification.Name("UserDidLogin"), object: nil)
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            authState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Moves to next step
    public func nextStep() {
        switch currentStep {
        case .countrySelection:
            if validateCountrySelection() {
                currentStep = .personalInfo
            }
        case .personalInfo:
            if validatePersonalInfo() {
                currentStep = .documents
            }
        case .documents:
            if validateDocuments() {
                currentStep = .credentials
            }
        case .credentials:
            if validateCredentials() {
                currentStep = .otpVerification
            }
        case .otpVerification:
            break
        }
    }
    
    /// Moves to previous step
    public func previousStep() {
        switch currentStep {
        case .countrySelection:
            break
        case .personalInfo:
            currentStep = .countrySelection
        case .documents:
            currentStep = .personalInfo
        case .credentials:
            currentStep = .documents
        case .otpVerification:
            currentStep = .credentials
        }
    }
    
    /// Resets the signup form
    public func reset() {
        selectedCountry = nil
        fullName = ""
        dateOfBirth = Date()
        address = ""
        contactNumber = ""
        email = ""
        userID = ""
        password = ""
        confirmPassword = ""
        documents = []
        documentNumber = ""
        documentFrontImage = nil
        documentBackImage = nil
        otp = ""
        otpSent = false
        errorMessage = nil
        authState = .unauthenticated
        currentStep = .countrySelection
    }
    
    // MARK: - Private Helpers
    
    private func validateCountrySelection() -> Bool {
        guard selectedCountry != nil else {
            errorMessage = "Please select a country"
            return false
        }
        return true
    }
    
    private func validatePersonalInfo() -> Bool {
        guard !fullName.isEmpty else {
            errorMessage = "Full name is required"
            return false
        }
        
        guard !address.isEmpty else {
            errorMessage = "Address is required"
            return false
        }
        
        guard !contactNumber.isEmpty else {
            errorMessage = "Contact number is required"
            return false
        }
        
        guard !email.isEmpty else {
            errorMessage = "Email is required"
            return false
        }
        
        // Basic email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            errorMessage = "Invalid email format"
            return false
        }
        
        return true
    }
    
    private func validateDocuments() -> Bool {
        guard let country = selectedCountry else {
            errorMessage = "Country selection is required"
            return false
        }
        
        // Check if all required documents are uploaded
        let requiredDocs = requiredDocuments
        let uploadedDocTypes = Set(documents.map { $0.type })
        let requiredDocTypes = Set(requiredDocs)
        
        // For India, both Aadhaar and PAN are required
        if country == .india {
            guard uploadedDocTypes.contains(.aadhaar) && uploadedDocTypes.contains(.pan) else {
                errorMessage = "Both Aadhaar and PAN cards are required for India"
                return false
            }
        } else {
            // For other countries, at least one required document
            guard !documents.isEmpty else {
                errorMessage = "At least one document is required"
                return false
            }
            
            // Check if at least one required document is uploaded
            let hasRequiredDoc = requiredDocTypes.intersection(uploadedDocTypes).isEmpty == false
            guard hasRequiredDoc else {
                let docNames = requiredDocs.map { $0.rawValue }.joined(separator: " or ")
                errorMessage = "Please upload \(docNames)"
                return false
            }
        }
        
        return true
    }
    
    private func validateCredentials() -> Bool {
        guard !userID.isEmpty else {
            errorMessage = "User ID is required"
            return false
        }
        
        guard !password.isEmpty else {
            errorMessage = "Password is required"
            return false
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return false
        }
        
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return false
        }
        
        return true
    }
    
    private func validateInputs() -> Bool {
        guard validatePersonalInfo() else { return false }
        guard validateDocuments() else { return false }
        guard validateCredentials() else { return false }
        
        if otpSent && otp.isEmpty {
            errorMessage = "OTP is required"
            return false
        }
        
        return true
    }
    
    private func handleAuthError(_ error: AuthError) {
        authState = .error(error.localizedDescription ?? "Unknown error")
        errorMessage = error.localizedDescription
    }
}
