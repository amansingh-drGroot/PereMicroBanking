# ConfigKit

Configuration management package for PereMicroBanking app. Handles Firebase initialization and app-wide configuration.

## Features

- Firebase configuration and initialization
- Singleton pattern for centralized configuration
- Configuration state tracking

## Usage

```swift
import ConfigKit

// In your app's init or AppDelegate
ConfigKit.shared.configure()
```

## Dependencies

- FirebaseCore (10.18.0+)

## Requirements

- iOS 16.0+
- Swift 5.9+

