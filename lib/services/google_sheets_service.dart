import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../models/expense.dart';
import '../config/app_config.dart';

class GoogleSheetsService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: AppConfig.googleSignInWebClientId,
    scopes: [
      'https://www.googleapis.com/auth/spreadsheets',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );
  
  GoogleSignInAccount? _currentUser;
  
  // Sign in with Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      print('Starting Google Sign-In...');
      print('Client ID: ${AppConfig.googleSignInWebClientId}');
      print('Scopes: ${_googleSignIn.scopes}');
      
      final account = await _googleSignIn.signIn();
      if (account != null) {
        print('Sign-in successful: ${account.email}');
        _currentUser = account;
        return account;
      } else {
        print('Sign-in was cancelled by user');
        return null;
      }
    } catch (error) {
      print('Error signing in: $error');
      print('Error type: ${error.runtimeType}');
      if (error.toString().contains('popup_closed_by_user')) {
        print('User closed the popup');
      } else if (error.toString().contains('access_denied')) {
        print('Access denied - check OAuth consent screen configuration');
      } else if (error.toString().contains('redirect_uri_mismatch')) {
        print('Redirect URI mismatch - check authorized origins in Google Console');
      } else if (error.toString().contains('invalid_client')) {
        print('Invalid client - check web client ID configuration');
      }
      return null;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }
  
  // Get current user
  GoogleSignInAccount? get currentUser => _currentUser;
  
  // Check if user is signed in
  bool get isSignedIn => _currentUser != null;
  
  // Get authenticated HTTP client
  Future<http.Client> _getAuthenticatedClient() async {
    if (_currentUser == null) {
      throw Exception('User not signed in');
    }
    
    final auth = await _currentUser!.authentication;
    final credentials = AccessCredentials(
      AccessToken('Bearer', auth.accessToken!, DateTime.now().toUtc().add(const Duration(hours: 1))),
      auth.idToken,
      [
        'https://www.googleapis.com/auth/spreadsheets',
        'https://www.googleapis.com/auth/drive.file',
      ],
    );
    
    return authenticatedClient(http.Client(), credentials);
  }
  
  // Create a new spreadsheet
  Future<String?> createSpreadsheet(String title) async {
    try {
      final client = await _getAuthenticatedClient();
      final sheetsApi = sheets.SheetsApi(client);
      
      final spreadsheet = sheets.Spreadsheet()
        ..properties = (sheets.SpreadsheetProperties()..title = title);
      
      final createdSpreadsheet = await sheetsApi.spreadsheets.create(spreadsheet);
      
      // Set up the header row
      await _setupSpreadsheetHeaders(sheetsApi, createdSpreadsheet.spreadsheetId!);
      
      client.close();
      return createdSpreadsheet.spreadsheetId;
    } catch (error) {
      print('Error creating spreadsheet: $error');
      return null;
    }
  }
  
  // Setup spreadsheet headers
  Future<void> _setupSpreadsheetHeaders(sheets.SheetsApi sheetsApi, String spreadsheetId) async {
    final headers = Expense.sheetsHeaders;
    
    final request = sheets.BatchUpdateSpreadsheetRequest()
      ..requests = [
        sheets.Request()
          ..updateCells = (sheets.UpdateCellsRequest()
            ..range = (sheets.GridRange()
              ..sheetId = 0
              ..startRowIndex = 0
              ..endRowIndex = 1
              ..startColumnIndex = 0
              ..endColumnIndex = headers.length)
            ..rows = [
              sheets.RowData()
                ..values = headers.map((header) => 
                  sheets.CellData()
                    ..userEnteredValue = (sheets.ExtendedValue()..stringValue = header)
                    ..userEnteredFormat = (sheets.CellFormat()
                      ..textFormat = (sheets.TextFormat()
                        ..bold = true
                        ..fontSize = 12)
                      ..backgroundColor = (sheets.Color()
                        ..red = 0.9
                        ..green = 0.9
                        ..blue = 0.9)
                    )
                ).toList(),
            ]
            ..fields = 'userEnteredValue,userEnteredFormat')
      ];
    
    await sheetsApi.spreadsheets.batchUpdate(request, spreadsheetId);
  }
  
  // Add expense to spreadsheet
  Future<bool> addExpense(String spreadsheetId, Expense expense) async {
    try {
      final client = await _getAuthenticatedClient();
      final sheetsApi = sheets.SheetsApi(client);
      
      final values = [expense.toSheetsRow()];
      
      final request = sheets.ValueRange()
        ..values = values;
      
      await sheetsApi.spreadsheets.values.append(
        request,
        spreadsheetId,
        'Sheet1!A:D',
        valueInputOption: 'RAW',
      );
      
      client.close();
      return true;
    } catch (error) {
      print('Error adding expense to spreadsheet: $error');
      return false;
    }
  }
  
  // Get all expenses from spreadsheet
  Future<List<Expense>> getExpenses(String spreadsheetId) async {
    try {
      final client = await _getAuthenticatedClient();
      final sheetsApi = sheets.SheetsApi(client);
      
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'Sheet1!A2:D', // Skip header row
      );
      
      final expenses = <Expense>[];
      if (response.values != null) {
        for (int i = 0; i < response.values!.length; i++) {
          final row = response.values![i];
          if (row.length >= 4) {
            try {
              final expense = Expense.fromSheetsRow(row, 'sheet_$i');
              expenses.add(expense);
            } catch (e) {
              print('Error parsing expense row: $e');
            }
          }
        }
      }
      
      client.close();
      return expenses;
    } catch (error) {
      print('Error getting expenses from spreadsheet: $error');
      return [];
    }
  }
  
  // Get spreadsheet URL
  String getSpreadsheetUrl(String spreadsheetId) {
    return 'https://docs.google.com/spreadsheets/d/$spreadsheetId/edit';
  }
} 