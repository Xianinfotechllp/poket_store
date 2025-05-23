import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/controllers/favorite_controller/favorite_controller.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the list when screen is created
    Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.favorites.isEmpty) {
            return const Center(child: Text("No favorites added yet"));
          }

          return ListView.builder(
            itemCount: controller.favorites.length,
            itemBuilder: (context, index) {
              final item = controller.favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Image.network(
                    item.productImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.name),
                  subtitle: Text(item.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('₹${item.price}'),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          // call delete
                          await controller.removeFromFavorite(item.id);
                          if (controller.isSuccess) {
                            // remove from local list
                            setState(() {
                              controller.favorites.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Removed from favorites')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to remove favorite')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
