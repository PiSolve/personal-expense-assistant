import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense {
  final String id;
  final DateTime date;
  final String category;
  final String description;
  final double amount;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  // Convert to Google Sheets row format
  List<dynamic> toSheetsRow() {
    return [
      DateFormat('yyyy-MM-dd').format(date),
      category,
      description,
      amount,
    ];
  }

  // Create from sheets row
  static Expense fromSheetsRow(List<dynamic> row, String id) {
    return Expense(
      id: id,
      date: DateFormat('yyyy-MM-dd').parse(row[0].toString()),
      category: row[1].toString(),
      description: row[2].toString(),
      amount: double.parse(row[3].toString()),
      createdAt: DateTime.now(),
    );
  }

  static List<String> get sheetsHeaders => [
    'Date',
    'Category',
    'Description',
    'Amount',
  ];
}

// Available expense categories
class ExpenseCategory {
  static const List<String> categories = [
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

  static String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return '🍽️';
      case 'transportation':
        return '🚗';
      case 'entertainment':
        return '🎬';
      case 'shopping':
        return '🛍️';
      case 'health':
        return '🏥';
      case 'bills':
        return '💡';
      case 'education':
        return '📚';
      case 'travel':
        return '✈️';
      case 'general':
        return '💼';
      default:
        return '📝';
    }
  }
} 