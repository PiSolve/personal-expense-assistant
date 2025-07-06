import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/foundation.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  
  // Available languages
  static const List<String> supportedLanguages = [
    'en-US', // English
    'hi-IN', // Hindi
  ];
  
  // Initialize speech recognition
  Future<bool> initialize() async {
    try {
      // On web, permission is handled by the browser
      // On mobile, we would need permission_handler, but we're web-only now
      if (kIsWeb) {
        // Initialize speech to text directly on web
        _isInitialized = await _speechToText.initialize(
          onError: (error) {
            print('Speech recognition error: $error');
          },
          onStatus: (status) {
            print('Speech recognition status: $status');
          },
        );
      } else {
        // For mobile platforms, we would need permission_handler
        // For now, return false for non-web platforms
        print('Speech recognition not available on this platform');
        return false;
      }
      
      return _isInitialized;
    } catch (error) {
      print('Error initializing speech service: $error');
      return false;
    }
  }
  
  // Check if speech recognition is available
  bool get isAvailable => _speechToText.isAvailable;
  
  // Check if currently listening
  bool get isListening => _isListening;
  
  // Check if initialized
  bool get isInitialized => _isInitialized;
  
  // Start listening for speech
  Future<void> startListening({
    required Function(String) onResult,
    String language = 'en-US',
  }) async {
    if (!_isInitialized) {
      throw Exception('Speech service not initialized');
    }
    
    if (_isListening) {
      return;
    }
    
    try {
      _isListening = true;
      
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            _isListening = false;
          }
        },
        localeId: language,
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onSoundLevelChange: (level) {
          // Handle sound level changes if needed
        },
      );
    } catch (error) {
      print('Error starting speech recognition: $error');
      _isListening = false;
      rethrow;
    }
  }
  
  // Stop listening
  Future<void> stopListening() async {
    if (!_isListening) {
      return;
    }
    
    try {
      await _speechToText.stop();
      _isListening = false;
    } catch (error) {
      print('Error stopping speech recognition: $error');
      _isListening = false;
    }
  }
  
  // Cancel listening
  Future<void> cancelListening() async {
    if (!_isListening) {
      return;
    }
    
    try {
      await _speechToText.cancel();
      _isListening = false;
    } catch (error) {
      print('Error canceling speech recognition: $error');
      _isListening = false;
    }
  }
  
  // Get available locales
  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      return [];
    }
    
    try {
      return await _speechToText.locales();
    } catch (error) {
      print('Error getting available locales: $error');
      return [];
    }
  }
  
  // Get supported languages for the app
  List<LanguageOption> getSupportedLanguages() {
    return [
      LanguageOption(
        code: 'en-US',
        name: 'English',
        nativeName: 'English',
      ),
      LanguageOption(
        code: 'hi-IN',
        name: 'Hindi',
        nativeName: 'हिंदी',
      ),
    ];
  }
  
  // Check if language is supported
  bool isLanguageSupported(String languageCode) {
    return supportedLanguages.contains(languageCode);
  }
  
  // Get default language
  String getDefaultLanguage() {
    return 'en-US';
  }
  
  // Get language display name
  String getLanguageDisplayName(String languageCode) {
    final languages = getSupportedLanguages();
    final language = languages.firstWhere(
      (lang) => lang.code == languageCode,
      orElse: () => languages.first,
    );
    return language.name;
  }
  
  // Dispose resources
  void dispose() {
    if (_isListening) {
      _speechToText.stop();
    }
    _isInitialized = false;
    _isListening = false;
  }
}

// Language option data class
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  
  LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });
  
  @override
  String toString() => name;
  
  @override
  bool operator ==(Object other) {
    return other is LanguageOption && other.code == code;
  }
  
  @override
  int get hashCode => code.hashCode;
} 