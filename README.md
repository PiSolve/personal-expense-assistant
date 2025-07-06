# Personal Assistant - Expense Tracker

A Flutter-based personal expense tracking app with AI-powered natural language processing and Google Sheets integration.

## Features

- 🗣️ **Voice Input**: Speak your expenses in English or Hindi
- 🤖 **AI-Powered Parsing**: Automatically extract expense details from natural language
- 📊 **Google Sheets Integration**: Auto-sync expenses to your personal Google Sheets
- 💬 **Chat Interface**: Intuitive chat-based interaction
- 📱 **Cross-Platform**: Single codebase for iOS and Android
- 🔍 **Smart Insights**: Ask questions about your spending patterns

## Screenshots

[Add screenshots here once the app is built]

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Google Cloud Console account (for Google Sheets API)
- OpenAI API key (for natural language processing)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd personal_assistant
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate required files**
   ```bash
   flutter packages pub run build_runner build
   ```

### Configuration

#### 1. Google Sheets API Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Sheets API and Google Drive API
4. Create credentials (OAuth 2.0 Client ID)
5. Download the configuration file

**For Android:**
- Download `google-services.json` and place it in `android/app/`

**For iOS:**
- Download `GoogleService-Info.plist` and place it in `ios/Runner/`

#### 2. OpenAI API Setup

1. Get your API key from [OpenAI Platform](https://platform.openai.com/)
2. Update the initialization in `lib/main.dart` or create a configuration file:

```dart
// In your initialization code
final openaiService = Provider.of<OpenAIService>(context, listen: false);
openaiService.initialize('your-openai-api-key-here');
```

### Running the App

1. **Start an emulator or connect a physical device**

2. **Run the app**
   ```bash
   flutter run
   ```

## Usage

### First Time Setup

1. **Onboarding**: Enter your name and email
2. **Google Sign-In**: Connect your Google account
3. **Sheet Creation**: The app will create a personal expense tracker in your Google Drive

### Adding Expenses

**Voice Input:**
- Tap the microphone button
- Say something like: "I spent 25 dollars on lunch at McDonald's"
- Review and confirm the parsed details

**Text Input:**
- Type your expense: "Paid $50 for groceries"
- The AI will extract the amount, category, and description
- Confirm the details before saving

### Asking Questions

- "How much did I spend on food this month?"
- "What's my total spending?"
- "Show me my entertainment expenses"

## Project Structure

```
lib/
├── models/
│   ├── expense.dart              # Expense data model
│   └── expense.g.dart            # Generated serialization code
├── providers/
│   └── app_state.dart            # Global app state management
├── services/
│   ├── google_sheets_service.dart # Google Sheets integration
│   ├── openai_service.dart       # OpenAI API integration
│   └── speech_service.dart       # Speech recognition
├── screens/
│   ├── onboarding_screen.dart    # User onboarding
│   └── home_screen.dart          # Main chat interface
├── widgets/
│   ├── chat_message.dart         # Chat message widget
│   └── expense_confirmation_dialog.dart # Expense confirmation
└── main.dart                     # App entry point
```

## Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Provider**: State management
- **Google Sheets API**: Cloud storage and sync
- **OpenAI API**: Natural language processing
- **Speech-to-Text**: Voice input functionality
- **Google Fonts**: Typography
- **Material 3**: Modern UI design

## Expense Categories

- 🍽️ Food
- 🚗 Transportation
- 🎬 Entertainment
- 🛍️ Shopping
- 🏥 Health
- 💡 Bills
- 📚 Education
- ✈️ Travel
- 💼 General
- 📝 Others

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting

### Common Issues

**Google Sign-In Issues:**
- Make sure you've added the correct SHA-1 fingerprint to your Google Cloud Console
- Verify that Google Sheets API and Google Drive API are enabled

**Speech Recognition Not Working:**
- Check microphone permissions in device settings
- Ensure you have a stable internet connection
- Try switching between English and Hindi

**OpenAI API Errors:**
- Verify your API key is correct and active
- Check your OpenAI account billing status
- Ensure you have sufficient API credits

### Debugging Steps

1. Run with verbose logging:
   ```bash
   flutter run --verbose
   ```

2. Check device logs:
   ```bash
   flutter logs
   ```

3. Clear app data and restart if needed

## Future Enhancements

- 📸 Receipt scanning and OCR
- 📈 Advanced analytics and visualizations
- 🔔 Spending limit notifications
- 🌐 Multi-currency support
- 🎨 Custom themes and dark mode
- 📊 Export to other formats (PDF, CSV)
- 🔐 Biometric authentication
- 📱 Apple Watch / WearOS support

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please:
1. Check the troubleshooting section above
2. Search existing issues in the repository
3. Create a new issue with detailed information about your problem

## Acknowledgments

- OpenAI for providing the GPT API
- Google for the Sheets API and Flutter framework
- The Flutter community for excellent packages and documentation 