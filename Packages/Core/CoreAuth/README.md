# CoreAuth

Authentication module for PereMicroBanking app. Provides complete authentication flow including login, signup, OTP, and PIN verification.

## Features

### Authentication
- User ID/Customer ID login
- Password authentication
- PIN verification
- OTP (One-Time Password) verification
- Account registration/signup

### Components
- **Models**: LoginCredentials, SignupCredentials, AuthState, AuthError
- **Services**: AuthService, OTPService, PINService
- **ViewModels**: LoginViewModel, SignupViewModel
- **Views**: LoginView, SignupView, and reusable form components

## Usage

### Login Flow

```swift
import CoreAuth

let loginView = LoginView()
```

### Signup Flow

```swift
import CoreAuth

let signupView = SignupView()
```

### Using Services Directly

```swift
import CoreAuth

// Login
let credentials = LoginCredentials(userID: "user123", password: "password")
let result = try await AuthService.shared.login(with: credentials)

// Send OTP
try await OTPService.shared.sendOTP(to: "+1234567890")

// Verify OTP
let isValid = try await OTPService.shared.verifyOTP("123456", for: "+1234567890")
```

## Architecture

### Models
- `LoginCredentials`: User ID, password, optional PIN and OTP
- `SignupCredentials`: Account details, personal info, new credentials
- `AuthState`: Authentication state enum
- `AuthError`: Error types with localized descriptions

### Services
- `AuthService`: Main authentication service (protocol-based for testing)
- `OTPService`: OTP generation and verification
- `PINService`: PIN validation and encryption

### ViewModels
- `LoginViewModel`: Manages login state and flow
- `SignupViewModel`: Manages signup state and flow

### Views
- `LoginView`: Complete login UI
- `SignupView`: Complete signup UI
- Form components: `UserIDField`, `PasswordField`, `PINField`, `OTPField`

## Dependencies

- FirebaseAuth (10.18.0+)

## Requirements

- iOS 16.0+
- Swift 5.9+

## Next Steps

The services currently have placeholder implementations. You'll need to:

1. Integrate with your backend API in `AuthService`
2. Connect to your OTP provider in `OTPService`
3. Implement proper PIN encryption in `PINService`
4. Add document upload for KYC in signup flow

