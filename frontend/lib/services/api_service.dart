import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

  // Add Book
  Future<dynamic> addBook({
    required String name,
    required String description,
    required int credit,
    required double price,
    required File image,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/books/');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${await _getToken()}'
        ..fields['name'] = name
        ..fields['description'] = description
        ..fields['credit'] = credit.toString()
        ..fields['price'] = price.toString()
        ..files.add(await http.MultipartFile.fromPath('image', image.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return jsonDecode(responseBody);
      }
      throw Exception('Failed to add book: $responseBody');
    } catch (e) {
      throw Exception('Add book failed: ${e.toString()}');
    }
  }

  // Edit Book
  Future<dynamic> updateBook(String bookId, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/books/$bookId/'),
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Update failed: ${response.body}');
    } catch (e) {
      throw Exception('Update error: ${e.toString()}');
    }
  }

  // Delete Book
  Future<void> deleteBook(String bookId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/books/$bookId/'),
        headers: {'Authorization': 'Bearer ${await _getToken()}'},
      );

      if (response.statusCode != 204) {
        throw Exception('Delete failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Delete error: ${e.toString()}');
    }
  }

  Future<dynamic> createBook({
    required String name,
    required String description,
    required int credit,
    required double price,
    required File image,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/books/');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${await _getToken()}'
        ..fields['name'] = name
        ..fields['description'] = description
        ..fields['credit'] = credit.toString()
        ..fields['price'] = price.toString()
        ..files.add(await http.MultipartFile.fromPath('image', image.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return jsonDecode(responseBody);
      }
      throw Exception('Failed to create book: $responseBody');
    } catch (e) {
      throw Exception('Book creation failed: ${e.toString()}');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access');
  }

  Map<String, String> _convertData(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<dynamic> multipartPost(
      String endpoint, Map<String, dynamic> data, File image) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(await _getHeaders())
        ..fields.addAll(data.map((k, v) => MapEntry(k, v.toString())))
        ..files.add(await http.MultipartFile.fromPath('image', image.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return jsonDecode(responseBody);
      }
      throw Exception(
          'Request failed with status ${response.statusCode}: $responseBody');
    } catch (e) {
      throw Exception('Book creation failed: ${e.toString()}');
    }
  }

// Add PUT method
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      _handleError(response);
    } catch (e) {
      throw Exception('PUT request failed: ${e.toString()}');
    }
  }

  // Generic GET method
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      _handleError(response);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 204) {
        throw Exception('Delete failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Delete request failed: ${e.toString()}');
    }
  }

  void _handleError(http.Response response, [String? responseBody]) {
    String errorDetails;
    try {
      final decodedBody = jsonDecode(response.body);
      errorDetails = decodedBody['detail'] ?? response.body;
    } catch (_) {
      errorDetails = response.body;
    }

    final errorMessage = _getErrorMessage(response.statusCode);
    throw Exception('$errorMessage\n$errorDetails');
  }

  String _getErrorMessage(int statusCode) {
    return switch (statusCode) {
      400 => 'Bad request',
      401 => 'Unauthorized - Please login again',
      403 => 'Forbidden',
      404 => 'Resource not found',
      500 => 'Internal server error',
      _ => 'Request failed with status: $statusCode',
    };
  }

  // Specific method for getting books
  Future<List<dynamic>> getBooks() async {
    final response = await get('books/');
    return response as List<dynamic>;
  }

  Future<bool> _checkTokenExpiration() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    if (token == null) return true;

    final parts = token.split('.');
    if (parts.length != 3) return true;

    final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

    final exp = payload['exp'] as int;
    return DateTime.now().millisecondsSinceEpoch > exp * 1000;
  }
}
