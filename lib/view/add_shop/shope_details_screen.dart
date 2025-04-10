import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/shope_details_controller.dart';
import 'package:provider/provider.dart';

class ShopeDetailsScreen extends StatelessWidget {
  final String shopId;

  const ShopeDetailsScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopeDetailsProvider()..loadShopeDetails(shopId),
      child: Scaffold(
        appBar: AppBar(title: const Text("Shop Details")),
        body: Consumer<ShopeDetailsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.shopDetails == null) {
              return Center(child: Text(provider.errorMessage));
            }

            final shop = provider.shopDetails!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(shop.headerImage),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    shop.shopName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Category: ${shop.category.join(', ')}"),
                  Text("Seller Type: ${shop.sellerType}"),
                  Text("Location: ${shop.place}, ${shop.state}"),
                  Text("Pincode: ${shop.pinCode}"),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
