// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/models/catalog.dart';
import 'package:flutter_application_1/widgets/drawer.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Item> _cartItems = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    try {
      final catalogJson =
          await rootBundle.loadString("asset/file/catalog.json");
      final decodedData = jsonDecode(catalogJson);
      var productsData = decodedData["products"];

      CatalogModel.items = List.from(productsData)
          .map<Item>((item) => Item.fromMap(item))
          .toList();
      setState(() {});
    } catch (error) {
      print("Error loading catalog data: $error");
    }
  }

  void addToCart(Item item) {
    setState(() {
      _cartItems.add(item);
    });
  }

  void removeFromCart(Item item) {
    setState(() {
      _cartItems.remove(item);
    });
  }

  void clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  double getCartTotal() {
    double total = 0;
    for (var item in _cartItems) {
      total += item.price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catalog App"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(
                    height: 300,
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text(
                            'Cart',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final cartItem = _cartItems[index];
                              return ListTile(
                                title: Text(cartItem.name),
                                subtitle: Text(
                                    '\$${cartItem.price.toStringAsFixed(2)}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_shopping_cart),
                                  onPressed: () {
                                    removeFromCart(cartItem);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '\$${getCartTotal().toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            clearCart();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear Cart'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: (CatalogModel.items != null && CatalogModel.items.isNotEmpty)
            ? ListView.builder(
                itemCount: CatalogModel.items.length,
                itemBuilder: (context, index) {
                  final item = CatalogModel.items[index];
                  final isInCart = _cartItems.contains(item);
                  return GestureDetector(
                    onTap: () {
                      if (!isInCart) {
                        addToCart(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item added to cart'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: ItemWidget(
                      item: item,
                      isInCart: isInCart,
                    ),
                  );
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
      drawer: const MyDrawer(),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final Item item;
  final bool isInCart;

  const ItemWidget({
    super.key,
    required this.item,
    required this.isInCart,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(item.image),
      title: Text(item.name),
      subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
      trailing: isInCart
          ? const Icon(Icons.check_circle)
          : const Icon(Icons.add_circle),
    );
  }
}
