import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/expense.dart';

class AppState extends ChangeNotifier {
  // User information
  String? _userName;
  String? _userEmail;
  GoogleSignInAccount? _googleUser;
  String? _spreadsheetId;
  
  // App state
  bool _isLoading = false;
  bool _isSignedIn = false;
  String? _errorMessage;
  
  // Expenses
  List<Expense> _expenses = [];
  
  // Getters
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  GoogleSignInAccount? get googleUser => _googleUser;
  String? get spreadsheetId => _spreadsheetId;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;
  String? get errorMessage => _errorMessage;
  List<Expense> get expenses => _expenses;
  
  // Initialize app state
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    _spreadsheetId = prefs.getString('spreadsheet_id');
    _isSignedIn = prefs.getBool('is_signed_in') ?? false;
    notifyListeners();
  }
  
  // Set user information
  Future<void> setUserInfo(String name, String email) async {
    _userName = name;
    _userEmail = email;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setBool('is_onboarded', true);
    
    notifyListeners();
  }
  
  // Set Google user
  void setGoogleUser(GoogleSignInAccount? user) {
    _googleUser = user;
    _isSignedIn = user != null;
    notifyListeners();
  }
  
  // Set spreadsheet ID
  Future<void> setSpreadsheetId(String id) async {
    _spreadsheetId = id;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spreadsheet_id', id);
    
    notifyListeners();
  }
  
  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Set error message
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Add expense
  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }
  
  // Update expenses list
  void updateExpenses(List<Expense> expenses) {
    _expenses = expenses;
    notifyListeners();
  }
  
  // Get expenses by category
  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }
  
  // Get total amount
  double getTotalAmount() {
    return _expenses.fold(0.0, (total, expense) => total + expense.amount);
  }
  
  // Get monthly total
  double getMonthlyTotal(DateTime month) {
    return _expenses
        .where((expense) => 
            expense.date.year == month.year && 
            expense.date.month == month.month)
        .fold(0.0, (total, expense) => total + expense.amount);
  }
  
  // Sign out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _userName = null;
    _userEmail = null;
    _googleUser = null;
    _spreadsheetId = null;
    _isSignedIn = false;
    _expenses.clear();
    
    notifyListeners();
  }
  
  // Clear all app state
  Future<void> clearAll() async {
    _userName = null;
    _userEmail = null;
    _googleUser = null;
    _spreadsheetId = null;
    _isLoading = false;
    _isSignedIn = false;
    _errorMessage = null;
    _expenses.clear();
    
    // Clear SharedPreferences is already handled by the logout method
    // Just notify listeners of the state change
    notifyListeners();
  }
} 