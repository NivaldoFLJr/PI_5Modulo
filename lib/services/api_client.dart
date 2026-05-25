import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _base = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000',
  );

  static Future<dynamic> get(String path) async {
    final res = await http.get(Uri.parse('$_base$path'));
    return jsonDecode(res.body);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$_base$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final res = await http.patch(
      Uri.parse('$_base$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }
}