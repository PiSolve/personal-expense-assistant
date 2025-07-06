import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_state.dart';
import '../services/google_sheets_service.dart';
import '../services/openai_service.dart';
import '../services/speech_service.dart';
import '../models/expense.dart';
import '../widgets/chat_message.dart';
import '../widgets/expense_confirmation_dialog.dart';
import '../config/app_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  bool _isListening = false;
  bool _isProcessing = false;
  String _currentLanguage = 'en-US';
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
    _addWelcomeMessage();
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeServices() async {
    final speechService = Provider.of<SpeechService>(context, listen: false);
    await speechService.initialize();
    
    // Initialize OpenAI service with configuration
    if (AppConfig.isConfigured) {
      final openaiService = Provider.of<OpenAIService>(context, listen: false);
      openaiService.initialize(AppConfig.openaiApiKey);
    }
  }
  
  void _addWelcomeMessage() {
    final appState = Provider.of<AppState>(context, listen: false);
    final welcomeMessage = ChatMessage(
      text: 'Hello ${appState.userName ?? 'there'}! 👋\n\nI\'m your personal expense tracking assistant. You can:\n\n• Type or speak your expenses\n• Ask questions about your spending\n• View your expense summary\n\nJust tell me something like "I spent 25 dollars on lunch" or "Show me my food expenses"',
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(welcomeMessage);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Assistant', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageSelector,
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'sheets',
                child: Row(
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 8),
                    Text('View Sheets'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: _handleMenuSelection,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          
          // Processing indicator
          if (_isProcessing)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Processing your request...',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your expense or question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  backgroundColor: _isListening 
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                  child: Icon(
                    _isListening ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                  ),
                  mini: true,
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () => _sendMessage(_messageController.text),
                  child: const Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isProcessing = true;
    });
    
    _scrollToBottom();
    _processMessage(text);
  }
  
  Future<void> _processMessage(String text) async {
    try {
      // Check if it's an expense or a question
      if (_isExpenseInput(text)) {
        await _processExpenseInput(text);
      } else {
        await _processQuestion(text);
      }
    } catch (error) {
      _addBotMessage('Sorry, I encountered an error while processing your request. Please try again.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  bool _isExpenseInput(String text) {
    final expenseKeywords = ['spent', 'paid', 'bought', 'cost', 'expense', 'purchase', 'bill', 'money'];
    final lowerText = text.toLowerCase();
    return expenseKeywords.any((keyword) => lowerText.contains(keyword)) || 
           RegExp(r'\d+\.?\d*').hasMatch(text);
  }
  
  Future<void> _processExpenseInput(String text) async {
    final openaiService = Provider.of<OpenAIService>(context, listen: false);
    
    try {
      // Add debug logging
      print('Processing expense input: $text');
      print('OpenAI service configured: ${AppConfig.isConfigured}');
      
      final parsedExpense = await openaiService.parseExpense(text);
      
      if (parsedExpense != null) {
        print('Successfully parsed expense: ${parsedExpense.amount}, ${parsedExpense.category}');
        _showExpenseConfirmation(parsedExpense);
      } else {
        print('OpenAI returned null - failed to parse');
        _addBotMessage('I couldn\'t understand the expense details. Please try again with amount and description.');
      }
    } catch (error) {
      print('Error processing expense: $error');
              _addBotMessage('Sorry, I couldn\'t process that expense. Error: $error');
        
        // Temporary fallback for testing - create a mock expense
        final mockExpense = ParsedExpense(
          amount: 25.0,
          category: 'General',
          description: text.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim(),
          date: DateTime.now(),
        );
        _addBotMessage('🔧 Using fallback parsing for testing...');
        _showExpenseConfirmation(mockExpense);
    }
  }
  
  Future<void> _processQuestion(String text) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final openaiService = Provider.of<OpenAIService>(context, listen: false);
    
    try {
      final answer = await openaiService.answerExpenseQuestion(text, appState.expenses);
      
      if (answer != null) {
        _addBotMessage(answer);
      } else {
        _addBotMessage('I couldn\'t find an answer to your question. Please try asking differently.');
      }
    } catch (error) {
      _addBotMessage('Sorry, I couldn\'t answer your question right now. Please try again.');
    }
  }
  
  void _showExpenseConfirmation(ParsedExpense parsedExpense) {
    showDialog(
      context: context,
      builder: (context) => ExpenseConfirmationDialog(
        parsedExpense: parsedExpense,
        onConfirm: (expense) => _saveExpense(expense),
        onCancel: () => _addBotMessage('Expense cancelled. Feel free to try again!'),
      ),
    );
  }
  
  Future<void> _saveExpense(Expense expense) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final sheetsService = Provider.of<GoogleSheetsService>(context, listen: false);
    
    try {
      // Add to local state
      appState.addExpense(expense);
      
      // Save to Google Sheets if available
      if (appState.spreadsheetId != null) {
        await sheetsService.addExpense(appState.spreadsheetId!, expense);
      }
      
      _addBotMessage('✅ Expense saved successfully!\n\n${ExpenseCategory.getCategoryIcon(expense.category)} ${expense.category}: \$${expense.amount.toStringAsFixed(2)}\n📝 ${expense.description}');
    } catch (error) {
      _addBotMessage('Expense saved locally, but couldn\'t sync to Google Sheets. Please check your connection.');
    }
  }
  
  void _addBotMessage(String text) {
    final botMessage = ChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(botMessage);
    });
    
    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  Future<void> _startListening() async {
    final speechService = Provider.of<SpeechService>(context, listen: false);
    
    if (!speechService.isInitialized) {
      await speechService.initialize();
    }
    
    if (!speechService.isAvailable) {
      _addBotMessage('Speech recognition is not available on this device.');
      return;
    }
    
    setState(() {
      _isListening = true;
    });
    
    try {
      await speechService.startListening(
        onResult: (result) {
          setState(() {
            _isListening = false;
          });
          
          if (result.isNotEmpty) {
            _messageController.text = result;
            _sendMessage(result);
          }
        },
        language: _currentLanguage,
      );
    } catch (error) {
      setState(() {
        _isListening = false;
      });
      _addBotMessage('Sorry, I couldn\'t start listening. Please check your microphone permissions.');
    }
  }
  
  Future<void> _stopListening() async {
    final speechService = Provider.of<SpeechService>(context, listen: false);
    await speechService.stopListening();
    
    setState(() {
      _isListening = false;
    });
  }
  
  void _showLanguageSelector() {
    final speechService = Provider.of<SpeechService>(context, listen: false);
    final languages = speechService.getSupportedLanguages();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) => ListTile(
            title: Text(lang.name),
            subtitle: Text(lang.nativeName),
            selected: lang.code == _currentLanguage,
            onTap: () {
              setState(() {
                _currentLanguage = lang.code;
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }
  
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        _showProfile();
        break;
      case 'sheets':
        _openGoogleSheets();
        break;
      case 'settings':
        _showSettings();
        break;
      case 'logout':
        _logout();
        break;
    }
  }
  
  void _showProfile() {
    final appState = Provider.of<AppState>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${appState.userName ?? 'Not set'}'),
            Text('Email: ${appState.userEmail ?? 'Not set'}'),
            Text('Total Expenses: ${appState.expenses.length}'),
            Text('Total Amount: \$${appState.getTotalAmount().toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _openGoogleSheets() {
    final appState = Provider.of<AppState>(context, listen: false);
    final sheetsService = Provider.of<GoogleSheetsService>(context, listen: false);
    
    if (appState.spreadsheetId != null) {
      final url = sheetsService.getSpreadsheetUrl(appState.spreadsheetId!);
      _addBotMessage('Here\'s your Google Sheets URL:\n$url');
    } else {
      _addBotMessage('You haven\'t connected to Google Sheets yet. Would you like to set it up?');
    }
  }
  
  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Dark Mode'),
              subtitle: Text('Coming soon'),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              subtitle: Text('Coming soon'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? This will clear all your data and you\'ll need to set up again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (shouldLogout == true) {
      try {
        // Clear SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Sign out from Google Sheets
        final sheetsService = Provider.of<GoogleSheetsService>(context, listen: false);
        await sheetsService.signOut();
        
        // Clear app state
        final appState = Provider.of<AppState>(context, listen: false);
        await appState.clearAll();
        
        // Navigate to onboarding
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/onboarding', 
            (route) => false,
          );
        }
      } catch (error) {
        _addBotMessage('Error during logout: $error');
      }
    }
  }
} 