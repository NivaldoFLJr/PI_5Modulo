import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // No emulador Android use 10.0.2.2; no dispositivo físico use o IP da máquina
  static const String _base = 'http://10.0.2.2:3000';

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