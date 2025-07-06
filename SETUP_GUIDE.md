# Setup Guide for Personal Assistant

This guide will help you set up the Personal Assistant app on your development machine.

## Prerequisites

- Flutter SDK (>=3.0.0)
- Android Studio or VS Code
- A Google account for Google Sheets integration
- An OpenAI account for AI-powered expense parsing

## Step 1: Clone and Install Dependencies

```bash
git clone <repository-url>
cd personal_assistant
flutter pub get
```

## Step 2: Configure API Keys

### OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Create an account or sign in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key and update `lib/config/app_config.dart`:

```dart
static const String openaiApiKey = 'your-actual-openai-api-key-here';
```

### Google Sheets API Setup

#### For Android

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Google Sheets API
   - Google Drive API
4. Create credentials:
   - Click "Create Credentials" > "OAuth 2.0 Client ID"
   - Select "Android" as application type
   - Add your package name: `com.example.personal_assistant`
   - Add SHA-1 fingerprint (see instructions below)
5. Download the `google-services.json` file
6. Place it in `android/app/` directory

#### For iOS

1. In the same Google Cloud Console project
2. Create credentials:
   - Click "Create Credentials" > "OAuth 2.0 Client ID"
   - Select "iOS" as application type
   - Add your bundle identifier: `com.example.personalAssistant`
3. Download the `GoogleService-Info.plist` file
4. Place it in `ios/Runner/` directory

#### Getting SHA-1 Fingerprint (Android)

For debug builds:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

For release builds:
```bash
keytool -list -v -keystore /path/to/your/keystore -alias your-key-alias
```

## Step 3: Generate Required Files

```bash
flutter packages pub run build_runner build
```

## Step 4: Update Configuration

Edit `lib/config/app_config.dart` and update the following:

```dart
class AppConfig {
  // Replace with your actual OpenAI API key
  static const String openaiApiKey = 'sk-your-actual-key-here';
  
  // Replace with your Google Client ID (optional)
  static const String googleSignInClientId = 'your-google-client-id';
  
  // Other settings (optional)
  static const bool isDebugMode = true; // Set to false for production
}
```

## Step 5: Platform-Specific Configuration

### Android Configuration

1. Add the following to `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}

dependencies {
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

2. Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MICROPHONE" />
```

### iOS Configuration

1. Add to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice input</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition for voice commands</string>
```

2. Update `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleSignIn

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
  }
}
```

## Step 6: Test the Setup

1. Run the app:
```bash
flutter run
```

2. Check the debug console for any configuration warnings

3. Test the main features:
   - Onboarding flow
   - Google Sign-in
   - Voice input (with microphone permission)
   - Text input for expenses
   - AI parsing functionality

## Common Issues and Solutions

### Google Sign-In Issues

- **Problem**: Sign-in fails with "Invalid client ID"
- **Solution**: Verify your SHA-1 fingerprint is correct and added to Google Cloud Console

### OpenAI API Issues

- **Problem**: "API key not found" error
- **Solution**: Check that your API key is correctly added to `app_config.dart`

### Speech Recognition Issues

- **Problem**: Microphone permission denied
- **Solution**: Check app permissions in device settings

### Build Issues

- **Problem**: Missing generated files
- **Solution**: Run `flutter packages pub run build_runner build --delete-conflicting-outputs`

## Development Tips

1. **Enable Debug Logging**: Set `AppConfig.enableLogging = true` for detailed logs
2. **Use Simulators**: Test on both Android and iOS simulators
3. **Test on Real Devices**: Voice input works better on real devices
4. **API Quotas**: Monitor your OpenAI API usage to avoid quota issues

## Next Steps

After successful setup:

1. Customize expense categories in `AppConfig.defaultCategories`
2. Adjust AI prompts in `OpenAIService` for better parsing
3. Add custom features or integrations
4. Prepare for production deployment

## Getting Help

If you encounter issues:

1. Check the troubleshooting section in README.md
2. Review the Flutter and package documentation
3. Check GitHub issues for similar problems
4. Create a new issue with detailed error information

## Production Deployment

Before deploying to production:

1. Set `AppConfig.isDebugMode = false`
2. Use release builds with proper code signing
3. Test on multiple devices and Android/iOS versions
4. Set up proper error logging and monitoring
5. Review API key security and rotation practices 