//
//  LoginView.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import SwiftUI

public struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Perennial Super App")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Sign in to your account")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 16) {
                        UserIDField(userID: $viewModel.userID)
                            .textFieldStyle(.roundedBorder)
                        
                        PasswordField(password: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                        
                        if viewModel.requiresPIN {
                            PINField(pin: $viewModel.pin)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        if viewModel.requiresOTP {
                            VStack(spacing: 8) {
                                OTPField(otp: $viewModel.otp)
                                    .textFieldStyle(.roundedBorder)
                                
                                Button("Resend OTP") {
                                    Task {
                                        await viewModel.sendOTP()
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal)
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.login()
                            }
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text(viewModel.isLoading ? "Signing in..." : "Sign In")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(viewModel.isLoading || viewModel.userID.isEmpty || viewModel.password.isEmpty)
                        .opacity(viewModel.isLoading || viewModel.userID.isEmpty || viewModel.password.isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LoginView()
}

