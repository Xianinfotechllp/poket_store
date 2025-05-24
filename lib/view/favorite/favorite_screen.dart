// poketstore/view/favorite_screen/favorite_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/controllers/favorite_controller/favorite_controller.dart';

// 1. Extend with WidgetsBindingObserver
class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

// 2. Implement WidgetsBindingObserver
class _FavoriteScreenState extends State<FavoriteScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // 3. Add this instance as an observer
    WidgetsBinding.instance.addObserver(this);
    // Initial fetch when the screen is first created
    _fetchFavorites();
  }

  // 4. Implement didChangeAppLifecycleState to handle screen resume
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Fetch favorites whenever the app comes to the foreground
      // (which includes returning to this screen from another screen)
      _fetchFavorites();
    }
  }

  // Helper method to call fetchFavorites
  void _fetchFavorites() {
    Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
  }

  @override
  void dispose() {
    // 5. Remove the observer when the state is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

          // You might want to display an error message if controller.errorMessage is not empty
          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading favorites: ${controller.errorMessage}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (controller.favorites.isEmpty) {
            return const Center(child: Text("No favorites added yet."));
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
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 50),
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
                          // Call the delete method from the controller
                          await controller.removeFromFavorite(item.id);
                          // The controller should already re-fetch or update its list
                          // after a successful deletion, so no need for setState to remove locally.
                          // Just show feedback and let the Consumer rebuild the list.
                          if (controller.errorMessage.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Removed from favorites')),
                            );
                            // No need for setState to remove locally,
                            // the controller's notifyListeners() after removal
                            // will cause this Consumer to rebuild.
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to remove favorite: ${controller.errorMessage}')),
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
