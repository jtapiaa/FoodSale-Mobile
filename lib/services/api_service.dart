import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.220:5001/api';

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

  static Future<List<dynamic>> getRestaurantProducts(int restaurantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurants/$restaurantId/products'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error al obtener productos: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> createOrder({
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    int delivery = 1990,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'restaurant_id': restaurantId,
        'items': items,
        'delivery': delivery,
        'delivery_address': deliveryAddress,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Error al crear pedido: ${response.statusCode} ${response.body}',
    );
  }

  static Future<List<dynamic>> getOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/orders'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error al obtener pedidos: ${response.statusCode}');
  }

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error al obtener categorías: ${response.statusCode}');
  }

  static Future<List<dynamic>> search(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=${Uri.encodeQueryComponent(query)}'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error al buscar: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/orders/$orderId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Error al actualizar estado: '
      '${response.statusCode} ${response.body}',
    );
  }
}
