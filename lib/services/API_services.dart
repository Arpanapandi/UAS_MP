import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.100/api";

  static Future<List<dynamic>> getBarang() async {
    final url = Uri.parse("$baseUrl/barang");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Gagal load data barang");
    }
  }
}