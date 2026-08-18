
import 'package:flutter/material.dart';

void main() {
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

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  final pages = const [
    HomeScreen(),
    ExploreScreen(),
    OrdersScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFFF0C7),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Explorar'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Pedidos'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    child: const Icon(Icons.room_service, color: orange, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Text.rich(
                    TextSpan(
                      text: 'Food',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: dark),
                      children: [
                        TextSpan(text: 'Sale', style: TextStyle(color: orange)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined)),
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
            sliver: SliverToBoxAdapter(child: _SearchBar()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            sliver: SliverToBoxAdapter(child: _PromoCard()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            sliver: SliverToBoxAdapter(child: _SectionTitle(title: 'Categorías', action: 'Ver todas')),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(child: _Categories()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            sliver: SliverToBoxAdapter(child: _SectionTitle(title: 'Restaurantes destacados', action: 'Ver todos')),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                RestaurantCard(
                  name: 'Burger House',
                  rating: '4.6',
                  time: '30–40 min',
                  category: 'Hamburguesas · Americana',
                  icon: Icons.lunch_dining,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RestaurantScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                RestaurantCard(
                  name: 'Pizzería La Italiana',
                  rating: '4.5',
                  time: '35–45 min',
                  category: 'Pizzas · Italiana',
                  icon: Icons.local_pizza,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RestaurantScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                RestaurantCard(
                  name: 'Healthy Green',
                  rating: '4.7',
                  time: '25–35 min',
                  category: 'Saludable · Vegana',
                  icon: Icons.eco,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RestaurantScreen()),
                  ),
                ),
              ]),
            ),
          ),
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
            child: Text('La Calera, Chile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 56,
            decoration: _cardDecoration(),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 10),
                Text('Buscar platos, restaurantes...', style: TextStyle(color: Colors.grey, fontSize: 15)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(18)),
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
                const Text('¡Pide tu comida', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const Text('favorita!', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: orange)),
                const SizedBox(height: 8),
                const Text('Rápido, fácil y delicioso.', style: TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 15),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
              color: Colors.white.withOpacity(.55),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lunch_dining, size: 88, color: Color(0xFF8B5A2B)),
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
        Expanded(child: Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
        Text(action, style: const TextStyle(color: orange, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Categories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      ('Hamburguesas', Icons.lunch_dining),
      ('Pizzas', Icons.local_pizza),
      ('Saludable', Icons.eco),
      ('Bebidas', Icons.local_drink),
      ('Postres', Icons.cake),
      ('Más', Icons.more_horiz),
    ];

    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          return SizedBox(
            width: 82,
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: _cardDecoration(),
                  child: Icon(items[i].$2, color: i == 0 ? orange : dark, size: 30),
                ),
                const SizedBox(height: 7),
                Text(items[i].$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String name;
  final String rating;
  final String time;
  final String category;
  final IconData icon;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.name,
    required this.rating,
    required this.time,
    required this.category,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: _cardDecoration(),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Container(
              width: 120,
              height: 125,
              color: const Color(0xFFFFE7B0),
              child: Icon(icon, size: 64, color: const Color(0xFF8B5A2B)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('★ $rating  ·  $time  ·  \$', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(category, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Envío gratis', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.favorite_border),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Burger House', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
            child: const Icon(Icons.lunch_dining, size: 110, color: Color(0xFF8B5A2B)),
          ),
          const SizedBox(height: 18),
          const Text('Burger House', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('★ 4.6  ·  30–40 min  ·  \$', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Hamburguesas · Americana', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          const Text('Menú', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          MenuItem(name: 'Cheese Burger', description: 'Carne, queso cheddar, lechuga, tomate y salsa especial', price: '\$4.990'),
          MenuItem(name: 'Double Bacon', description: 'Doble carne, bacon, queso y cebolla caramelizada', price: '\$6.490'),
          MenuItem(name: 'Papas Rústicas', description: 'Papas doradas con romero y sal de mar', price: '\$2.490'),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String name;
  final String description;
  final String price;

  const MenuItem({
    super.key,
    required this.name,
    required this.description,
    required this.price,
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
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 7),
                Text(price, style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            style: IconButton.styleFrom(backgroundColor: orange, foregroundColor: Colors.white),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi carrito'), backgroundColor: Colors.white, surfaceTintColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _AddressCard(),
          const SizedBox(height: 18),
          _CartRow(name: 'Cheese Burger', price: '\$4.990', quantity: '1'),
          _CartRow(name: 'Papas Rústicas', price: '\$2.490', quantity: '1'),
          _CartRow(name: 'Bebida en lata', price: '\$1.490', quantity: '2'),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(),
            child: const Column(
              children: [
                SummaryRow(label: 'Subtotal', value: '\$10.960'),
                SummaryRow(label: 'Despacho', value: '\$1.990'),
                Divider(height: 24),
                SummaryRow(label: 'Total', value: '\$12.950', bold: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen())),
              style: FilledButton.styleFrom(backgroundColor: orange, foregroundColor: Colors.white),
              child: const Text('Continuar con el pago', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: const Row(
        children: [
          Icon(Icons.location_on, color: orange),
          SizedBox(width: 10),
          Expanded(child: Text('Av. Primero de Mayo 1234, La Calera')),
          Text('Cambiar', style: TextStyle(color: orange, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final String name;
  final String price;
  final String quantity;

  const _CartRow({required this.name, required this.price, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Color(0xFFFFF0C7), child: Icon(Icons.fastfood, color: orange)),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text(price, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Text('× $quantity'),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const SummaryRow({super.key, required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w500, fontSize: bold ? 18 : 14);
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
      appBar: AppBar(title: const Text('Pago'), backgroundColor: Colors.white, surfaceTintColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Dirección de entrega', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _InfoTile(icon: Icons.location_on, text: 'Av. Primero de Mayo 1234, La Calera'),
          const SizedBox(height: 22),
          const Text('Método de pago', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _InfoTile(icon: Icons.credit_card, text: 'Tarjeta terminada en 4582'),
          const SizedBox(height: 22),
          const Text('Resumen', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(),
            child: const Column(
              children: [
                SummaryRow(label: 'Pedido', value: '\$10.960'),
                SummaryRow(label: 'Despacho', value: '\$1.990'),
                Divider(height: 24),
                SummaryRow(label: 'Total', value: '\$12.950', bold: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TrackingScreen()),
              ),
              style: FilledButton.styleFrom(backgroundColor: orange, foregroundColor: Colors.white),
              child: const Text('Confirmar pedido', style: TextStyle(fontWeight: FontWeight.w800)),
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
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rastrea tu pedido'), backgroundColor: Colors.white, surfaceTintColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4EA),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delivery_dining, size: 80, color: green),
                SizedBox(height: 8),
                Text('Tu pedido va en camino 🚴', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                SizedBox(height: 5),
                Text('Llegada estimada: 20–30 min', style: TextStyle(color: green, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _StatusTimeline(),
          const SizedBox(height: 20),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEF8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(Icons.map_outlined, size: 100, color: Color(0xFF6682A8)),
            ),
          ),
          const SizedBox(height: 16),
          _InfoTile(icon: Icons.person, text: 'Carlos R. · Tu repartidor'),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Confirmado', Icons.check_circle),
      ('Preparando', Icons.restaurant),
      ('En camino', Icons.delivery_dining),
      ('Entregado', Icons.home),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        final active = item.$1 != 'Entregado';
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: active ? const Color(0xFFFFF0C7) : Colors.grey.shade200,
                child: Icon(item.$2, color: active ? orange : Colors.grey),
              ),
              const SizedBox(height: 7),
              Text(item.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
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
          const Text('Mi perfil', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(),
            child: const Row(
              children: [
                CircleAvatar(radius: 32, backgroundColor: Color(0xFFFFF0C7), child: Icon(Icons.person, color: orange, size: 34)),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Juan Pérez', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('juan.perez@email.com', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _ProfileOption(icon: Icons.receipt_long, text: 'Mis pedidos'),
          const _ProfileOption(icon: Icons.location_on, text: 'Direcciones guardadas'),
          const _ProfileOption(icon: Icons.credit_card, text: 'Métodos de pago'),
          const _ProfileOption(icon: Icons.favorite, text: 'Favoritos'),
          const _ProfileOption(icon: Icons.local_offer_outlined, text: 'Cupones y ofertas'),
          const _ProfileOption(icon: Icons.help_outline, text: 'Ayuda y soporte'),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProfileOption({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: dark),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
          const Icon(Icons.chevron_right, color: Colors.grey),
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
          child: Text('Explorar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Mis pedidos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Favoritos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.05),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
