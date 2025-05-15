import 'package:flutter/material.dart';
import 'package:poketstore/controllers/user_profile_controller/user_profile_controller.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user profile from SharedPreferences
    Provider.of<UserProfileController>(
      context,
      listen: false,
    ).loadUserProfileFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("User Profile"),
        centerTitle: true,
      ),
      body: Consumer<UserProfileController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(child: Text(controller.error!));
          }

          final profile = controller.userProfile;

          if (profile == null) {
            return const Center(child: Text("No profile data found."));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildRow("Name", profile.name ?? "-"),
                    buildRow("Mobile Number", profile.mobileNumber.toString()),
                    buildRow("State", profile.state ?? "-"),
                    // Do not show password
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
