# PereMicroBanking

## Project Structure
```
PereMicroBanking/
├── PereMicroBanking/              # Main App Target
│   ├── PereMicroBankingApp.swift
│   └── ContentView.swift
├── Packages/                       # All SPM Packages
│   ├── Core/
│   │   ├── DesignKit/             # A1 - DesignSystem
│   │   ├── NetworkKit/            # A2 - Networking Base
│   │   ├── ConfigKit/             # B - Config & Feature Flags
│   │   └── CoreAuth/              # C - User Authentication
│   ├── Profile/
│   │   ├── UserFlowKit/           # D - New/Existing User
│   │   ├── OnboardingKit/         # E - Onboarding
│   │   └── ProfileKit/            # F - Load User Profile
│   ├── KYC/
│   │   ├── KYCKit/                # G - KYC Flow (Interface)
│   │   ├── KYCIndiaKit/           # H - India KYC
│   │   ├── KYCAustraliaKit/       # H - Australia KYC
│   │   └── KYCPhilippinesKit/     # H - Philippines KYC
│   ├── Personalization/
│   │   └── SegmentationKit/       # I - Segmentation Engine
│   ├── Home/
│   │   └── HomeKit/               # J - Home/Dashboard
│   ├── Banking/
│   │   ├── BankingKit/            # K - Banking Services
│   │   ├── AccountsKit/           # K1 - Accounts
│   │   ├── LoansKit/              # K2 - Loans
│   │   └── DepositsKit/           # K3 - Deposits
│   ├── Cards/
│   │   ├── CardsKit/              # L - Cards
│   │   ├── CreditDebitKit/       # L1 - Credit/Debit Cards
│   │   └── CardControlsKit/      # L2 - Card Controls
│   ├── Rewards/
│   │   ├── RewardsKit/            # M - Rewards
│   │   ├── RewardPointsKit/       # M1 - Reward Points
│   │   └── ShoppingKit/           # M2 - Shop with Points
│   ├── Payments/
│   │   ├── PaymentsKit/           # N - Digital Payments
│   │   ├── UPIWalletKit/          # N1 - UPI/Wallet
│   │   └── InternationalTransferKit/ # N2 - International Transfers
│   └── Security/
│       ├── SubscriptionKit/       # O - Premium Subscription
│       └── SecurityKit/           # O1, O2, O3 - Security Features
└── PereMicroBanking.xcodeproj/
```
