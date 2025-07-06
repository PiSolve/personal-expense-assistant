// Configuration file for the Personal Assistant app
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Initialize dotenv
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }
  
  // OpenAI API Configuration
  static String get openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openaiModel => dotenv.env['OPENAI_MODEL'] ?? 'gpt-3.5-turbo';
  
  // Google Services Configuration
  static String get googleSignInClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  static String get googleSignInWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  
  // App Settings
  static const String appName = 'Personal Assistant';
  static const String appVersion = '1.0.0';
  
  // Default expense categories
  static const List<String> defaultCategories = [
    'Food',
    'Transportation', 
    'Entertainment',
    'Shopping',
    'Health',
    'Bills',
    'Education',
    'Travel',
    'General',
    'Others',
  ];
  
  // Speech recognition settings
  static const String defaultLanguage = 'en-US';
  static const List<String> supportedLanguages = ['en-US', 'hi-IN'];
  
  // Google Sheets settings
  static const String defaultSheetName = 'Expense Tracker';
  static const List<String> sheetHeaders = [
    'Date',
    'Category', 
    'Description',
    'Amount',
  ];
  
  // Validation settings
  static const double minExpenseAmount = 0.01;
  static const double maxExpenseAmount = 999999.99;
  static const int maxDescriptionLength = 200;
  
  // App behavior settings
  static const int maxRecentExpenses = 100;
  static const int speechTimeoutSeconds = 5;
  static const int apiTimeoutSeconds = 30;
  
  // Development settings
  static const bool isDebugMode = true;
  static const bool enableLogging = true;
  
  // Check if the app is properly configured
  static bool get isConfigured {
    return openaiApiKey.isNotEmpty &&
           openaiApiKey != 'your_openai_api_key_here' &&
           googleSignInWebClientId.isNotEmpty &&
           googleSignInWebClientId != 'your_google_web_client_id_here.apps.googleusercontent.com';
  }
  
  // Get configuration warnings
  static List<String> getConfigurationWarnings() {
    final warnings = <String>[];
    
    if (openaiApiKey.isEmpty || openaiApiKey == 'your_openai_api_key_here') {
      warnings.add('OpenAI API key is not configured');
    }
    
    if (googleSignInClientId.isEmpty || googleSignInClientId == 'your_google_client_id_here.apps.googleusercontent.com') {
      warnings.add('Google Sign-In client ID is not configured');
    }
    
    if (googleSignInWebClientId.isEmpty || googleSignInWebClientId == 'your_google_web_client_id_here.apps.googleusercontent.com') {
      warnings.add('Google Sign-In web client ID is not configured');
    }
    
    return warnings;
  }
} 