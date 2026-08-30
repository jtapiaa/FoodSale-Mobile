import 'services/api_service.dart';

Future<void> testApi() async {
  try {
    final restaurants = await ApiService.getRestaurants();

    print('RESTAURANTES RECIBIDOS:');
    print(restaurants);
  } catch (e) {
    print('ERROR API: $e');
  }
}