import 'package:flutter/material.dart';

import 'dart:async';

import 'models/cart_item.dart';

import 'services/api_service.dart';
import 'services/cart_service.dart';
import 'services/favorite_service.dart';
import 'services/address_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FavoriteService.load();
  await AddressService.load();
  runApp(const FoodSaleApp());
}

class FoodSaleApp extends StatelessWidget {
  const FoodSaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodSale',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB000),
          primary: const Color(0xFFFFB000),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

const orange = Color(0xFFFFB000);
const dark = Color(0xFF202124);
const green = Color(0xFF4CAF50);

String getOrderStatusText(String status) {
  switch (status) {
    case 'pending':
      return 'Pendiente';
    case 'preparing':
      return 'Preparando';
    case 'on_the_way':
      return 'En camino';
    case 'delivered':
      return 'Entregado';
    default:
      return status;
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          const HomeScreen(),
          const ExploreScreen(),
          const OrdersScreen(),
          const FavoritesScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFFF0C7),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Explorar'),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> restaurants;
  String searchQuery = '';
  List<dynamic> searchResults = [];

  @override
  void initState() {
    super.initState();
    restaurants = ApiService.getRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0C7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.room_service,
                      color: orange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text.rich(
                    TextSpan(
                      text: 'Food',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: dark,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sale',
                          style: TextStyle(color: orange),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: SliverToBoxAdapter(child: _LocationCard()),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: _SearchBar(
                onChanged: (value) async {
                  setState(() {
                    searchQuery = value;
                  });

                  if (value.trim().isEmpty) {
                    setState(() {
                      searchResults = [];
                    });
                    return;
                  }

                  try {
                    final results = await ApiService.search(value.trim());

                    if (!mounted) return;

                    setState(() {
                      searchResults = results;
                    });
                  } catch (e) {
                    print('ERROR BUSCANDO: $e');
                  }
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            sliver: SliverToBoxAdapter(child: _PromoCard()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            sliver: SliverToBoxAdapter(
              child: _SectionTitle(title: 'Categorías', action: 'Ver todas'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(child: _Categories()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            sliver: SliverToBoxAdapter(
              child: _SectionTitle(
                title: 'Restaurantes destacados',
                action: 'Ver todos',
              ),
            ),
          ),
          //******** */
          SliverToBoxAdapter(
            child: FutureBuilder<List<dynamic>>(
              future: restaurants,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Text(
                        'Error al conectar con FoodSale API:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final data = snapshot.data ?? [];
                final filteredData = data.where((restaurant) {
                  final name =
                      restaurant['name']?.toString().toLowerCase() ?? '';
                  final category =
                      restaurant['category']?.toString().toLowerCase() ?? '';

                  return name.contains(searchQuery.toLowerCase()) ||
                      category.contains(searchQuery.toLowerCase());
                }).toList();

                final isSearching = searchQuery.trim().isNotEmpty;

                if (data.isEmpty) {
                  return const Center(
                    child: Text('No hay restaurantes disponibles'),
                  );
                }

                print('RESTAURANTES RECIBIDOS: ${data.length}');
                print('PRIMER RESTAURANTE: ${data[0]}');

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isSearching && searchResults.isNotEmpty) ...[
                        const Text(
                          'Platos encontrados',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ...searchResults.map((product) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RestaurantScreen(
                                          restaurantId:
                                              product['restaurant_id'],
                                          restaurantName:
                                              product['restaurant_name'] ??
                                              'Restaurante',
                                          rating:
                                              product['restaurant_rating']
                                                  ?.toString() ??
                                              '0.0',
                                          deliveryTime:
                                              product['restaurant_delivery_time']
                                                  ?.toString() ??
                                              '',
                                          category:
                                              product['restaurant_category']
                                                  ?.toString() ??
                                              '',
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      bottom: 6,
                                    ),
                                    child: Text(
                                      '${product['restaurant_name'] ?? 'Restaurante'}'
                                      '  ·  ★ ${product['restaurant_rating'] ?? '0.0'}'
                                      '  ·  ${product['restaurant_delivery_time'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                MenuItem(
                                  productId: product['id'],
                                  name: product['name'],
                                  description: product['description'] ?? '',
                                  price: product['price'],
                                  restaurantId: product['restaurant_id'],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      if (!isSearching) ...[
                        ...filteredData.map((restaurant) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RestaurantCard(
                              restaurantId: restaurant['id'],
                              name: restaurant['name']?.toString() ?? '',
                              rating: restaurant['rating']?.toString() ?? '0.0',
                              time:
                                  restaurant['delivery_time']?.toString() ?? '',
                              category:
                                  restaurant['category']?.toString() ?? '',
                              icon: Icons.lunch_dining,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RestaurantScreen(
                                    restaurantId: restaurant['id'],
                                    restaurantName: restaurant['name'],
                                    rating: restaurant['rating'].toString(),
                                    deliveryTime:
                                        restaurant['delivery_time']
                                            ?.toString() ??
                                        '',
                                    category:
                                        restaurant['category']?.toString() ??
                                        '',
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],

                      if (isSearching && searchResults.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No encontramos resultados',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Prueba con otro nombre o plato',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          //******** */
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: orange),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'La Calera, Chile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.my_location, size: 18),
            label: const Text('Usar mi ubicación'),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 56,
            decoration: _cardDecoration(),
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Buscar platos, restaurantes...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: orange,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0C7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¡Pide tu comida',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const Text(
                  'favorita!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: orange,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rápido, fácil y delicioso.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 15),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Ver ofertas'),
                ),
              ],
            ),
          ),
          Container(
            width: 145,
            height: 145,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .55),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lunch_dining,
              size: 88,
              color: Color(0xFF8B5A2B),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String action;
  const _SectionTitle({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          action,
          style: const TextStyle(color: orange, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _Categories extends StatefulWidget {
  const _Categories();

  @override
  State<_Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<_Categories> {
  late Future<List<dynamic>> categories;

  @override
  void initState() {
    super.initState();
    categories = ApiService.getCategories();
  }

  IconData getCategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'hamburguesas':
        return Icons.lunch_dining;
      case 'pizzas':
        return Icons.local_pizza;
      case 'saludable':
        return Icons.eco;
      case 'bebidas':
        return Icons.local_drink;
      case 'postres':
        return Icons.cake;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: categories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 105,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox(
            height: 105,
            child: Center(child: Text('Error al cargar categorías')),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const SizedBox(
            height: 105,
            child: Center(child: Text('No hay categorías')),
          );
        }

        return SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final category = items[i];
              final name = category['name']?.toString() ?? '';

              return SizedBox(
                width: 82,
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: _cardDecoration(),
                      child: Icon(
                        getCategoryIcon(name),
                        color: i == 0 ? orange : dark,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class RestaurantCard extends StatefulWidget {
  final int restaurantId;
  final String name;
  final String rating;
  final String time;
  final String category;
  final IconData icon;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurantId,
    required this.name,
    required this.rating,
    required this.time,
    required this.category,
    required this.icon,
    required this.onTap,
  });

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  @override
  void initState() {
    super.initState();
    FavoriteService.changes.addListener(_favoriteChanged);
  }

  void _favoriteChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    FavoriteService.changes.removeListener(_favoriteChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: widget.onTap,
      child: Container(
        decoration: _cardDecoration(),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 125,
              color: const Color(0xFFFFE7B0),
              child: Icon(
                widget.icon,
                size: 56,
                color: const Color(0xFF8B5A2B),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '★ ${widget.rating}  ·  ${widget.time}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      widget.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Envío gratis',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 4, top: 6),
              child: IconButton(
                onPressed: () async {
                  await FavoriteService.toggle(widget.restaurantId);

                  if (!mounted) return;

                  setState(() {});
                },
                icon: Icon(
                  FavoriteService.isFavorite(widget.restaurantId)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: FavoriteService.isFavorite(widget.restaurantId)
                      ? Colors.red
                      : dark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantScreen extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;
  final String rating;
  final String deliveryTime;
  final String category;

  const RestaurantScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    required this.rating,
    required this.deliveryTime,
    required this.category,
  });

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  late Future<List<dynamic>> products;

  @override
  void initState() {
    super.initState();

    products = ApiService.getRestaurantProducts(widget.restaurantId);
  }

  void _refreshCart() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.restaurantName,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),

              if (CartService.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${CartService.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE7B0),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.lunch_dining,
              size: 110,
              color: Color(0xFF8B5A2B),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.restaurantName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            '★ ${widget.rating}  ·  ${widget.deliveryTime}  ·  \$',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(widget.category, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          const Text(
            'Menú',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<dynamic>>(
            future: products,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Error al obtener el menú:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final data = snapshot.data ?? [];

              if (data.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Este restaurante no tiene productos disponibles',
                    ),
                  ),
                );
              }

              return Column(
                children: data.map((product) {
                  return MenuItem(
                    productId: product['id'],
                    name: product['name'],
                    description: product['description'] ?? '',
                    price: product['price'],
                    restaurantId: widget.restaurantId,
                    onCartChanged: _refreshCart,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final int productId;
  final String name;
  final String description;
  final int price;
  final int restaurantId;
  final VoidCallback? onCartChanged;

  const MenuItem({
    super.key,
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.restaurantId,
    this.onCartChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFFFF0C7),
            child: Icon(Icons.fastfood, color: orange),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 7),
                Text(
                  '\$$price',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final currentRestaurantId = CartService.restaurantId;

              if (CartService.items.isNotEmpty &&
                  currentRestaurantId != null &&
                  currentRestaurantId != restaurantId) {
                final shouldReplace = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Carrito de otro restaurante'),
                      content: const Text(
                        'Tu carrito contiene productos de otro restaurante. '
                        '¿Quieres vaciarlo y agregar este producto?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: orange,
                          ),
                          child: const Text('Vaciar y agregar'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldReplace != true) {
                  return;
                }

                CartService.clear();
              }

              CartService.restaurantId = restaurantId;

              CartService.addItem(
                productId: productId,
                name: name,
                price: price,
              );

              onCartChanged?.call();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$name agregado al carrito'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },

            style: IconButton.styleFrom(
              backgroundColor: orange,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = CartService.items;
    final subtotal = CartService.subtotal;
    const int delivery = 1990;
    final total = subtotal + delivery;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi carrito',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                CartService.clear();
              });
            },
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Vaciar carrito',
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Tu carrito está vacío',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _AddressCard(
                  onChanged: () {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 18),

                ...items.map(
                  (item) => _CartRow(
                    item: item,
                    onIncrease: () {
                      setState(() {
                        CartService.increaseQuantity(item.productId);
                      });
                    },
                    onDecrease: () {
                      setState(() {
                        CartService.decreaseQuantity(item.productId);
                      });
                    },
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      SummaryRow(
                        label: 'Pedido',
                        value: formatPrice(CartService.subtotal),
                      ),
                      SummaryRow(label: 'Despacho', value: formatPrice(1990)),
                      const Divider(height: 24),
                      SummaryRow(
                        label: 'Total',
                        value: formatPrice(CartService.subtotal + 1990),
                        bold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentScreen(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Continuar con el pago',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final VoidCallback onChanged;

  const _AddressCard({required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: orange),
          const SizedBox(width: 10),

          Expanded(
            child: Text(
              AddressService.address,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressScreen()),
              );

              onChanged();
            },
            child: const Text(
              'Cambiar',
              style: TextStyle(color: orange, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _CartRow({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFFFF0C7),
            child: Icon(Icons.fastfood, color: orange),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          IconButton(onPressed: onDecrease, icon: const Icon(Icons.remove)),

          Text(
            '${item.quantity}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),

          IconButton(onPressed: onIncrease, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
      fontSize: bold ? 18 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value, style: style.copyWith(color: bold ? green : dark)),
        ],
      ),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Dirección de entrega',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _InfoTile(icon: Icons.location_on, text: AddressService.address),
          const SizedBox(height: 22),
          const Text(
            'Método de pago',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _InfoTile(icon: Icons.credit_card, text: 'Tarjeta terminada en 4582'),
          const SizedBox(height: 22),
          const Text(
            'Resumen',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                SummaryRow(
                  label: 'Pedido',
                  value: formatPrice(CartService.subtotal),
                ),
                SummaryRow(label: 'Despacho', value: formatPrice(1990)),
                const Divider(height: 24),
                SummaryRow(
                  label: 'Total',
                  value: formatPrice(CartService.subtotal + 1990),
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: () async {
                try {
                  final restaurantId = CartService.restaurantId;

                  if (restaurantId == null) {
                    throw Exception('No se encontró el restaurante del pedido');
                  }

                  final items = CartService.items.map((item) {
                    return {
                      'product_id': item.productId,
                      'quantity': item.quantity,
                    };
                  }).toList();

                  final order = await ApiService.createOrder(
                    restaurantId: restaurantId,
                    items: items,
                    deliveryAddress: AddressService.address,
                    delivery: 1990,
                  );

                  print('PEDIDO CREADO');
                  print('ID: ${order['id']}');
                  print('SUBTOTAL: ${order['subtotal']}');
                  print('DELIVERY: ${order['delivery']}');
                  print('TOTAL: ${order['total']}');
                  print('DIRECCIÓN: ${order['delivery_address']}');

                  CartService.clear();

                  if (!context.mounted) return;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderConfirmationScreen(order: order),
                    ),
                  );
                } catch (e) {
                  print('ERROR AL CREAR PEDIDO: $e');

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo crear el pedido: $e')),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Confirmar pedido',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pedido #${order['id']}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            order['restaurant_name'] ?? 'Restaurante',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 12),

          _InfoTile(
            icon: Icons.location_on,
            text: order['delivery_address'] ?? 'Dirección no disponible',
          ),

          const SizedBox(height: 20),

          const Text(
            'Productos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 10),

          ...((order['items'] ?? []) as List).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item['quantity']} × ${item['product_name']}',
                    ),
                  ),
                  Text(
                    formatPrice(item['price'] * item['quantity']),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 30),

          Text('Subtotal: ${formatPrice(order['subtotal'])}'),

          Text('Despacho: ${formatPrice(order['delivery'])}'),

          const SizedBox(height: 6),

          Text(
            'Total: ${formatPrice(order['total'])}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackingScreen(order: order),
                  ),
                );
              },
              child: const Text(
                'Ver seguimiento',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedido confirmado'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 30),

          Icon(Icons.check_circle, size: 90, color: green),

          const SizedBox(height: 20),

          const Text(
            '¡Pedido confirmado!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 8),

          Text(
            'Tu pedido #${order['id']} fue creado correctamente.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['restaurant_name'] ?? 'Restaurante',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        order['delivery_address'] ?? 'Dirección no disponible',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '\$${order['total']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackingScreen(order: order),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Ver seguimiento',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 54,
            child: OutlinedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text(
                'Volver al inicio',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrackingScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const TrackingScreen({super.key, required this.order});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late String status;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    status = widget.order['status']?.toString() ?? 'pending';

    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _refreshOrder());
  }

  Future<void> _refreshOrder() async {
    try {
      final updatedOrder = await ApiService.getOrder(widget.order['id']);

      if (!mounted) return;

      final newStatus = updatedOrder['status']?.toString() ?? 'pending';

      if (newStatus != status) {
        setState(() {
          status = newStatus;
        });
      }
    } catch (e) {
      print('ERROR ACTUALIZANDO PEDIDO: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastrea tu pedido'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4EA),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delivery_dining, size: 80, color: green),
                const SizedBox(height: 8),
                Text(
                  'Pedido #${widget.order['id']}',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Estado: ${getOrderStatusText(status)}',
                  style: const TextStyle(
                    color: green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _StatusTimeline(status: status),

          const SizedBox(height: 20),

          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEF8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(
                Icons.map_outlined,
                size: 100,
                color: Color(0xFF6682A8),
              ),
            ),
          ),

          const SizedBox(height: 16),

          _InfoTile(
            icon: Icons.location_on,
            text: widget.order['delivery_address'] ?? 'Dirección no disponible',
          ),

          const SizedBox(height: 12),

          const _InfoTile(
            icon: Icons.person,
            text: 'Repartidor aún no asignado',
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;

  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Confirmado', Icons.check_circle),
      ('Preparando', Icons.restaurant),
      ('En camino', Icons.delivery_dining),
      ('Entregado', Icons.home),
    ];

    final statusIndex =
        {
          'pending': 0,
          'preparing': 1,
          'on_the_way': 2,
          'delivered': 3,
        }[status] ??
        0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        final itemIndex = items.indexOf(item);
        final active = itemIndex <= statusIndex;

        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: active
                    ? const Color(0xFFFFF0C7)
                    : Colors.grey.shade200,
                child: Icon(item.$2, color: active ? orange : Colors.grey),
              ),
              const SizedBox(height: 7),
              Text(
                item.$1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Mi perfil',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFFFFF0C7),
                  child: Icon(Icons.person, color: orange, size: 34),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Juan Pérez',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'juan.perez@email.com',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _ProfileOption(icon: Icons.receipt_long, text: 'Mis pedidos'),
          _ProfileOption(
            icon: Icons.location_on,
            text: 'Direcciones guardadas',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressScreen()),
              );
            },
          ),
          const _ProfileOption(
            icon: Icons.credit_card,
            text: 'Métodos de pago',
          ),
          const _ProfileOption(icon: Icons.favorite, text: 'Favoritos'),
          const _ProfileOption(
            icon: Icons.local_offer_outlined,
            text: 'Cupones y ofertas',
          ),
          const _ProfileOption(
            icon: Icons.help_outline,
            text: 'Ayuda y soporte',
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _ProfileOption({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Icon(icon, color: dark),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: AddressService.address);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> saveAddress() async {
    final address = controller.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ingresa una dirección')));
      return;
    }

    await AddressService.save(address);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Dirección guardada')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Direcciones guardadas',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Dirección de entrega',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: _cardDecoration(),
            child: TextField(
              controller: controller,
              maxLines: 2,
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.location_on, color: orange),
                hintText: 'Ingresa tu dirección',
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: saveAddress,
              style: FilledButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Guardar dirección',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'Explorar',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> orders = [];
  Timer? _timer;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    _loadOrders();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshOrders(),
    );
  }

  Future<void> _loadOrders() async {
    try {
      final data = await ApiService.getOrders();

      if (!mounted) return;

      setState(() {
        orders = data;
        loading = false;
      });
    } catch (e) {
      debugPrint('Error cargando pedidos: $e');

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _refreshOrders() async {
    try {
      final updatedOrders = await ApiService.getOrders();

      if (!mounted) return;

      setState(() {
        orders = updatedOrders;
      });
    } catch (e) {
      debugPrint('Error actualizando pedidos: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis pedidos',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const Center(
              child: Text(
                'No tienes pedidos todavía',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedido #${order['id']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          order['restaurant_name'] ?? 'Restaurante',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 12),

                        ...((order['items'] ?? []) as List).map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              '${item['quantity']} × ${item['product_name']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }),

                        const SizedBox(height: 8),

                        Text(
                          'Estado: ${getOrderStatusText(order['status'])}',
                          style: const TextStyle(
                            color: orange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const Divider(height: 20),

                        Text('Subtotal: ${formatPrice(order['subtotal'])}'),

                        Text('Despacho: ${formatPrice(order['delivery'])}'),

                        const SizedBox(height: 4),

                        Text(
                          'Total: ${formatPrice(order['total'])}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<dynamic>> restaurants;

  @override
  void initState() {
    super.initState();
    restaurants = ApiService.getRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: FavoriteService.changes,
      builder: (context, _, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Favoritos',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          body: FutureBuilder<List<dynamic>>(
            future: restaurants,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar favoritos:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final data = snapshot.data ?? [];

              final favorites = data.where((restaurant) {
                return FavoriteService.isFavorite(restaurant['id']);
              }).toList();

              if (favorites.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No tienes favoritos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Agrega restaurantes a tus favoritos '
                          'para encontrarlos rápidamente.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final restaurant = favorites[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RestaurantCard(
                      restaurantId: restaurant['id'],
                      name: restaurant['name']?.toString() ?? '',
                      rating: restaurant['rating']?.toString() ?? '0.0',
                      time: restaurant['delivery_time']?.toString() ?? '',
                      category: restaurant['category']?.toString() ?? '',
                      icon: Icons.lunch_dining,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RestaurantScreen(
                              restaurantId: restaurant['id'],
                              restaurantName: restaurant['name'],
                              rating: restaurant['rating'].toString(),
                              deliveryTime:
                                  restaurant['delivery_time']?.toString() ?? '',
                              category:
                                  restaurant['category']?.toString() ?? '',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .05),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
    ],
  );
}

String formatPrice(int value) {
  return '\$${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
}
