import 'package:flutter/material.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:poketstore/view/notification/notification.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton; // New parameter for back button visibility
  final String? title; // Added title parameter for more flexibility

  const CustomAppBar({
    super.key,
    this.showBackButton = false, // Default to false (no back button)
    this.title, // Initialize title
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading:
          showBackButton, // Control leading based on showBackButton
      leading:
          showBackButton // Conditionally show back button
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
              : null, // No leading widget if showBackButton is false
      backgroundColor: const Color.fromARGB(255, 7, 3, 201),
      title:
          title !=
                  null // Use the provided title if available
              ? Text(
                title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
              : RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'Poket',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Aparajita',
                      ),
                    ),
                    TextSpan(
                      text: 'Stor',
                      style: TextStyle(
                        color: Color(0xFFFFEA00),
                        fontFamily: 'Aparajita',
                      ),
                    ),
                  ],
                ),
              ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_business_outlined, color: Colors.white),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddShop()),
              ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_sharp, color: Colors.white),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationScreen()),
              ),
        ),
      ],
    );
  }
}
