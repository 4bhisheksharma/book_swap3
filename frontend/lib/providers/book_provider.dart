import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:book_swap/services/api_service.dart';
import 'package:book_swap/models/book.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookProvider with ChangeNotifier {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access');
  }

  final ApiService _apiService = ApiService();
  List<Book> _books = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  Future<void> fetchBooks() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _getToken();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/books/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['results'];
        _books = data.map((book) => Book.fromJson(book)).toList();
      }
    } catch (e) {
      throw Exception('Failed to load books: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBook(
    String name,
    String description,
    int credit,
    double price,
    File image,
  ) async {
    try {
      final token = await _getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/books/'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['credit'] = credit.toString();
      request.fields['price'] = price.toString();

      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        fetchBooks(); // Refresh list
      }
    } catch (e) {
      throw Exception('Add failed: ${e.toString()}');
    }
  }

  Future<void> editBook({
    required String id, // Add as named parameter
    String? name,
    String? description,
    int? credit,
    double? price,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/api/books/$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (credit != null) 'credit': credit,
          if (price != null) 'price': price,
        }),
      );
      if (response.statusCode == 200) {
        fetchBooks();
      }
    } catch (e) {
      throw Exception('Update failed: ${e.toString()}');
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/api/books/$bookId/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 204) {
        await fetchBooks(); // Force refresh
      }
    } catch (e) {
      throw Exception('Delete failed: ${e.toString()}');
    }
  }
}
