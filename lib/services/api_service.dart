import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  //static const String baseUrl = 'http://127.0.0.1:5000/api';
  static const String baseUrl = 'http://192.168.1.220:5001/api';

  static Future<List<dynamic>> getRestaurants() async {
    final response = await http.get(Uri.parse('$baseUrl/restaurants'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error al obtener restaurantes: ${response.statusCode}');
  }

  static Future<List<dynamic>> getRestaurants() async {
    final url = Uri.parse('$baseUrl/restaurants');

    print('URL RESTAURANTES: $url');

    final response = await http.get(url);

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error al obtener restaurantes: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> createOrder({
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    int delivery = 1990,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'restaurant_id': restaurantId,
        'items': items,
        'delivery': delivery,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Error al crear pedido: ${response.statusCode} ${response.body}',
    );
  }
}
