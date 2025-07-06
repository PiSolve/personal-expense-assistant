import 'package:dart_openai/dart_openai.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class OpenAIService {
  bool _isInitialized = false;
  
  // Initialize with API key
  void initialize(String apiKey) {
    OpenAI.apiKey = apiKey;
    _isInitialized = true;
  }
  
  // Parse expense from natural language
  Future<ParsedExpense?> parseExpense(String input) async {
    if (!_isInitialized) {
      print('OpenAI service not initialized');
      return null;
    }
    
    try {
      final prompt = _buildExpenseParsingPrompt(input);
      
      final response = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'You are a helpful assistant that extracts expense information from natural language input.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        temperature: 0.1,
        maxTokens: 200,
      );
      
      if (response.choices.isNotEmpty) {
        final content = response.choices.first.message.content?.first.text;
        if (content != null) {
          return _parseExpenseFromResponse(content);
        }
      }
      
      return null;
    } catch (error) {
      print('Error parsing expense with OpenAI: $error');
      return null;
    }
  }
  
  // Build prompt for expense parsing
  String _buildExpenseParsingPrompt(String input) {
    final categories = ExpenseCategory.categories.join(', ');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    return '''
Parse the following expense input and return ONLY a JSON object with these exact fields:
- amount: number (required)
- category: string (required, must be one of: $categories)
- description: string (required)
- date: string in YYYY-MM-DD format (default to today: $today if not specified)

Input: "$input"

Rules:
1. If no amount is found, return null
2. If no category matches, use "General"
3. If no date is specified, use today's date
4. Return ONLY the JSON object, no other text
5. Amount should be a number without currency symbols

Example output:
{"amount": 25.50, "category": "Food", "description": "lunch at restaurant", "date": "2024-01-15"}
''';
  }
  
  // Parse expense from OpenAI response
  ParsedExpense? _parseExpenseFromResponse(String response) {
    try {
      // Clean the response to extract JSON
      final cleanResponse = response.trim();
      final startIndex = cleanResponse.indexOf('{');
      final endIndex = cleanResponse.lastIndexOf('}') + 1;
      
      if (startIndex == -1 || endIndex == 0) {
        return null;
      }
      
      final jsonString = cleanResponse.substring(startIndex, endIndex);
      final data = ParsedExpense.fromJsonString(jsonString);
      
      return data;
    } catch (error) {
      print('Error parsing OpenAI response: $error');
      return null;
    }
  }
  
  // Answer questions about expenses
  Future<String?> answerExpenseQuestion(String question, List<Expense> expenses) async {
    if (!_isInitialized) {
      print('OpenAI service not initialized');
      return null;
    }
    
    try {
      final expenseData = _formatExpensesForAI(expenses);
      
      final response = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                '''You are a financial assistant that helps analyze expense data. 
            Provide clear, helpful answers about spending patterns, totals, and insights.
            Be concise and use numbers/percentages when relevant.''',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                '''Based on this expense data, please answer the question.
            
Expense Data:
$expenseData

Question: $question''',
              ),
            ],
          ),
        ],
        temperature: 0.3,
        maxTokens: 300,
      );
      
      if (response.choices.isNotEmpty) {
        return response.choices.first.message.content?.first.text;
      }
      
      return null;
    } catch (error) {
      print('Error answering expense question: $error');
      return null;
    }
  }
  
  // Format expenses for AI processing
  String _formatExpensesForAI(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return 'No expenses recorded yet.';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('Total expenses: ${expenses.length}');
    buffer.writeln('');
    
    // Group by category
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    buffer.writeln('By Category:');
    for (final entry in categoryTotals.entries) {
      buffer.writeln('- ${entry.key}: \$${entry.value.toStringAsFixed(2)}');
    }
    
    buffer.writeln('');
    buffer.writeln('Recent expenses:');
    final recentExpenses = expenses.take(10).toList();
    for (final expense in recentExpenses) {
      buffer.writeln('- ${expense.date}: ${expense.category} - ${expense.description} - \$${expense.amount}');
    }
    
    return buffer.toString();
  }
}

// Data class for parsed expense
class ParsedExpense {
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  
  ParsedExpense({
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });
  
  factory ParsedExpense.fromJsonString(String jsonString) {
    final json = jsonString.replaceAll(RegExp(r'[{}]'), '');
    final pairs = json.split(',');
    
    double? amount;
    String? category;
    String? description;
    DateTime? date;
    
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        final key = parts[0].trim().replaceAll('"', '');
        final value = parts[1].trim().replaceAll('"', '');
        
        switch (key) {
          case 'amount':
            amount = double.tryParse(value);
            break;
          case 'category':
            category = value;
            break;
          case 'description':
            description = value;
            break;
          case 'date':
            date = DateTime.tryParse(value);
            break;
        }
      }
    }
    
    return ParsedExpense(
      amount: amount ?? 0.0,
      category: category ?? 'General',
      description: description ?? '',
      date: date ?? DateTime.now(),
    );
  }
  
  // Convert to Expense model
  Expense toExpense() {
    return Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      category: category,
      description: description,
      amount: amount,
      createdAt: DateTime.now(),
    );
  }
} 