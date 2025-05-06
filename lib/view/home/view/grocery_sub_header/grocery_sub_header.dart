import 'package:flutter/material.dart';

class SubGroceryCategoryScreen extends StatelessWidget {
  final String header;
  final List<String> subCategories;

  const SubGroceryCategoryScreen({
    super.key,
    required this.header,
    required this.subCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(header)),
      body: ListView.builder(
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(subCategories[index]),
          );
        },
      ),
    );
  }
}
