//
//  OTPField.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import SwiftUI

public struct OTPField: View {
    @Binding var otp: String
    let placeholder: String
    
    public init(otp: Binding<String>, placeholder: String = "Enter OTP") {
        self._otp = otp
        self.placeholder = placeholder
    }
    
    public var body: some View {
        TextField(placeholder, text: $otp)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .multilineTextAlignment(.center)
    }
}

