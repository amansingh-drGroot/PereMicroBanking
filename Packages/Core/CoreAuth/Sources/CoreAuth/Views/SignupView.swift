//
//  SignupView.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import SwiftUI
import PhotosUI

public struct SignupView: View {
    @StateObject private var viewModel = SignupViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @State private var isPickingFront = true
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Indicator
                ProgressView(value: progressValue)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            
                            Text(stepTitle)
                                .font(.title2)
                                .bold()
                            
                            Text(stepSubtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Form Content
                        VStack(spacing: 20) {
                            switch viewModel.currentStep {
                            case .countrySelection:
                                countrySelectionStep
                            case .personalInfo:
                                personalInfoStep
                            case .documents:
                                documentsStep
                            case .credentials:
                                credentialsStep
                            case .otpVerification:
                                otpVerificationStep
                            }
                            
                            // Error Message
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.horizontal)
                            }
                            
                            // Navigation Buttons
                            HStack(spacing: 16) {
                                if viewModel.currentStep != .countrySelection {
                                    Button("Previous") {
                                        viewModel.previousStep()
                                    }
                                    .buttonStyle(.bordered)
                                }
                                
                                Spacer()
                                
                                if viewModel.currentStep == .otpVerification {
                                    Button(action: {
                                        Task {
                                            await viewModel.signup()
                                        }
                                    }) {
                                        HStack {
                                            if viewModel.isLoading {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            }
                                            Text(viewModel.isLoading ? "Registering..." : "Complete Registration")
                                        }
                                        .frame(minWidth: 150)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                    .disabled(viewModel.isLoading)
                                } else {
                                    Button("Next") {
                                        viewModel.nextStep()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(!canProceedToNextStep)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: isPickingFront ? $viewModel.documentFrontImage : $viewModel.documentBackImage)
            }
        }
    }
    
    // MARK: - Step Views
    
    private var countrySelectionStep: some View {
        VStack(spacing: 20) {
            Text("Select Your Country")
                .font(.headline)
                .padding(.bottom, 8)
            
            Text("We'll show you the required identity documents based on your country")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)
            
            VStack(spacing: 16) {
                ForEach(Country.allCases) { country in
                    Button(action: {
                        viewModel.selectCountry(country)
                    }) {
                        HStack {
                            Text(country.flag)
                                .font(.system(size: 40))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(country.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(countryDescription(for: country))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if viewModel.selectedCountry == country {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(
                            viewModel.selectedCountry == country
                                ? Color.green.opacity(0.1)
                                : Color.gray.opacity(0.1)
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    viewModel.selectedCountry == country
                                        ? Color.green
                                        : Color.clear,
                                    lineWidth: 2
                                )
                        )
                    }
                }
            }
        }
    }
    
    private func countryDescription(for country: Country) -> String {
        switch country {
        case .india:
            return "Aadhaar + PAN required"
        case .australia:
            return "Passport / DL + DVS"
        case .philippines:
            return "National ID / Passport"
        }
    }
    
    private var personalInfoStep: some View {
        VStack(spacing: 16) {
            TextField("Full Name", text: $viewModel.fullName)
                .textFieldStyle(.roundedBorder)
            
            DatePicker("Date of Birth", selection: $viewModel.dateOfBirth, displayedComponents: .date)
                .datePickerStyle(.compact)
            
            TextField("Address", text: $viewModel.address, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...5)
            
            TextField("Contact Number", text: $viewModel.contactNumber)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
        }
    }
    
    private var documentsStep: some View {
        VStack(spacing: 16) {
            if let country = viewModel.selectedCountry {
                VStack(spacing: 8) {
                    Text("Upload Required Documents")
                        .font(.headline)
                    
                    Text("For \(country.flag) \(country.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Show required documents info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Required Documents:")
                            .font(.caption)
                            .bold()
                        ForEach(viewModel.requiredDocuments, id: \.self) { doc in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text(doc.rawValue)
                                    .font(.caption)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // Document Type Picker (only shows documents for selected country)
            if !viewModel.availableDocuments.isEmpty {
                Picker("Document Type", selection: $viewModel.selectedDocumentType) {
                    ForEach(viewModel.availableDocuments, id: \.self) { type in
                        HStack {
                            Text(type.rawValue)
                            if type.isRequired {
                                Text("*")
                                    .foregroundColor(.red)
                            }
                        }
                        .tag(type)
                    }
                }
                .pickerStyle(.menu)
                .onAppear {
                    // Set first available document as default
                    if viewModel.selectedDocumentType.country != viewModel.selectedCountry {
                        viewModel.selectedDocumentType = viewModel.availableDocuments.first ?? .aadhaar
                    }
                }
                
                // Document description
                Text(viewModel.selectedDocumentType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Document Number
            TextField("Document Number", text: $viewModel.documentNumber)
                .textFieldStyle(.roundedBorder)
            
            // Front Image
            VStack(alignment: .leading, spacing: 8) {
                Text("Front Image")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let image = viewModel.documentFrontImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(8)
                } else {
                    Button(action: {
                        isPickingFront = true
                        showImagePicker = true
                    }) {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                            Text("Tap to add front image")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            
            // Back Image (Optional)
            VStack(alignment: .leading, spacing: 8) {
                Text("Back Image (Optional)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let image = viewModel.documentBackImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(8)
                } else {
                    Button(action: {
                        isPickingFront = false
                        showImagePicker = true
                    }) {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                            Text("Tap to add back image")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            
            // Add Document Button
            Button("Add Document") {
                viewModel.addDocument()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.documentNumber.isEmpty || viewModel.documentFrontImage == nil)
            
            // Added Documents List
            if !viewModel.documents.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Added Documents")
                        .font(.headline)
                    
                    ForEach(viewModel.documents, id: \.type) { document in
                        HStack {
                            Text(document.type.rawValue)
                            Spacer()
                            Button(action: {
                                viewModel.removeDocument(document)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var credentialsStep: some View {
        VStack(spacing: 16) {
            TextField("User ID", text: $viewModel.userID)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    private var otpVerificationStep: some View {
        VStack(spacing: 16) {
            Text("OTP has been sent to \(viewModel.contactNumber)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            OTPField(otp: $viewModel.otp)
                .textFieldStyle(.roundedBorder)
            
            Button("Resend OTP") {
                Task {
                    await viewModel.sendOTP()
                }
            }
            .font(.caption)
            .foregroundColor(.blue)
            .disabled(viewModel.isLoading)
        }
    }
    
    // MARK: - Computed Properties
    
    private var progressValue: Double {
        switch viewModel.currentStep {
        case .countrySelection: return 0.20
        case .personalInfo: return 0.40
        case .documents: return 0.60
        case .credentials: return 0.80
        case .otpVerification: return 1.0
        }
    }
    
    private var stepTitle: String {
        switch viewModel.currentStep {
        case .countrySelection: return "Select Country"
        case .personalInfo: return "Personal Information"
        case .documents: return "Identity Documents"
        case .credentials: return "Create Credentials"
        case .otpVerification: return "Verify OTP"
        }
    }
    
    private var stepSubtitle: String {
        switch viewModel.currentStep {
        case .countrySelection: return "Choose your country to see required documents"
        case .personalInfo: return "Enter your personal details"
        case .documents: return "Upload proof of identity/address"
        case .credentials: return "Create your login credentials"
        case .otpVerification: return "Enter the OTP sent to your number"
        }
    }
    
    private var canProceedToNextStep: Bool {
        switch viewModel.currentStep {
        case .countrySelection:
            return viewModel.selectedCountry != nil
        case .personalInfo:
            return !viewModel.fullName.isEmpty &&
                   !viewModel.address.isEmpty &&
                   !viewModel.contactNumber.isEmpty &&
                   !viewModel.email.isEmpty
        case .documents:
            // Validation is done in viewModel.validateDocuments()
            // For India, both Aadhaar and PAN are required
            if let country = viewModel.selectedCountry, country == .india {
                let uploadedTypes = Set(viewModel.documents.map { $0.type })
                return uploadedTypes.contains(.aadhaar) && uploadedTypes.contains(.pan)
            } else {
                return !viewModel.documents.isEmpty
            }
        case .credentials:
            return !viewModel.userID.isEmpty &&
                   !viewModel.password.isEmpty &&
                   viewModel.password == viewModel.confirmPassword &&
                   viewModel.password.count >= 8
        case .otpVerification:
            return false
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    SignupView()
}
