// navigation_app.dart: tabs, stack navigation, and passing data both ways
import 'package:flutter/material.dart';

void main() => runApp(const ShopApp());

// A small shared data layer: screens look products up by their ID
class Product {
  const Product(this.id, this.name, this.price);
  final int id;
  final String name;
  final int price; // in rupees
}

const products = [
  Product(1, 'Notebook', 250),
  Product(2, 'Calculator', 1800),
  Product(3, 'Backpack', 3500),
];

Product? findProduct(int id) {
  for (final p in products) {
    if (p.id == id) return p;
  }
  return null;
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.orange),
      home: const HomeTabs(),
    );
  }
}

// Tab navigation: two sections, switched with a bottom navigation bar
class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _tab = 0;
  int _cartItems = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      ProductList(onAdded: (n) => setState(() => _cartItems += n)),
      Center(child: Text('Items in cart: $_cartItems')),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(_tab == 0 ? 'Shop' : 'Cart')),
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.store), label: 'Shop'),
          NavigationDestination(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  const ProductList({super.key, required this.onAdded});
  final void Function(int) onAdded;

  Future<void> _open(BuildContext context, Product p) async {
    // Stack navigation: push the details screen, sending only the ID,
    // and wait for the value it returns when it is popped
    final quantity = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => ProductDetails(productId: p.id)),
    );
    if (quantity != null && quantity > 0) {
      onAdded(quantity);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $quantity x ${p.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final p in products)
          ListTile(
            title: Text(p.name),
            subtitle: Text('Rs ${p.price}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, p),
          ),
      ],
    );
  }
}

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key, required this.productId});
  final int productId; // the data received from the previous screen

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final p = findProduct(widget.productId); // validate the received ID
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Product not found')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Price: Rs ${p.price}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(() {
                    if (_quantity > 1) _quantity--;
                  }),
                ),
                Text('$_quantity'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
            FilledButton(
              // Pop this screen and send the quantity back
              onPressed: () => Navigator.pop(context, _quantity),
              child: Text('Add to cart (Rs ${p.price * _quantity})'),
            ),
          ],
        ),
      ),
    );
  }
}
