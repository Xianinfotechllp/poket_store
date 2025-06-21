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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      /// Load user profile from SharedPreferences
      Provider.of<UserProfileController>(
        context,
        listen: false,
      ).loadUserProfileFromPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for a clean look
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 7, 3, 201), // Consistent primary color
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "User Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20, // Slightly larger title
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ), // Ensure icons are white
          ),
        ),
      ),
      body: Consumer<UserProfileController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  controller.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }

          final profile = controller.userProfile;

          if (profile == null) {
            return const Center(
              child: Text(
                "No profile data found. Please ensure you are logged in.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            // Use SingleChildScrollView for potential overflow
            padding: const EdgeInsets.all(20.0), // Increased padding
            child: Card(
              elevation: 8, // Increased elevation for more depth
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25), // More rounded card
              ),
              color: Colors.white,
              shadowColor: Colors.black.withOpacity(0.15), // Softer shadow
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25, // Increased horizontal padding
                  vertical: 40, // Increased vertical padding
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min, // Make column take minimum space
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50, // Larger avatar
                        backgroundColor: const Color.fromARGB(
                          255,
                          7,
                          3,
                          201,
                        ).withOpacity(0.8), // Slightly subdued primary color
                        child: const Icon(
                          Icons.person,
                          size: 60, // Larger icon
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30), // Increased spacing
                    _buildProfileInfoRow("Name", profile.name ?? "N/A"),
                    _buildProfileInfoRow(
                      "Mobile Number",
                      profile.mobileNumber?.toString() ?? "N/A",
                    ),
                    _buildProfileInfoRow("State", profile.state ?? "N/A"),
                    // You can add more fields here if needed
                    // For example:
                    // _buildProfileInfoRow("City", profile.city ?? "N/A"),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget to build each profile information row
  Widget _buildProfileInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ), // Adjusted vertical padding
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align to start for long values
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17, // Slightly larger font
                color: Colors.grey[700], // Softer title color
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 17, // Consistent font size
                color: Colors.black87, // Stronger value color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
