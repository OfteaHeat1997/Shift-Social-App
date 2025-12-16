import 'package:flutter/material.dart';
import 'package:shift_application/screens/bingo_screen.dart';
import 'package:shift_application/screens/floor_plan.dart';
import 'custom_nav_bar.dart';  // Import the custom nav bar

class SettingsScreen extends StatefulWidget {
  final String stanceText;
  final String imagePath;
  final String statementText;
  final String statementId;

  const SettingsScreen({
    super.key,
    required this.stanceText,
    required this.imagePath,
    required this.statementText,
    required this.statementId,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      stanceText: widget.stanceText,
      imagePath: widget.imagePath,
      statementText: widget.statementText,
      statementId: widget.statementId,
      child: Scaffold(
        backgroundColor: Color(0xFF1E1E1E), // Dark background for settings
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Settings",
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF3775FC), Color(0xFFA5C9FD)], // gradient colors
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const SizedBox(height: 16),
              _buildSettingTile(Icons.person, "Account", () {
                // Show a dialog instead of navigating to a non-existent LoginScreen
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Account"),
                      content: const Text("Account management feature coming soon."),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }),
              _buildSettingTile(Icons.notifications, "Notifications", () {}),
              _buildSettingTile(Icons.lock, "Privacy", () {}),
              _buildSettingTile(Icons.info, "About", () {}),
              _buildSettingTile(Icons.accessibility_new, "Accessibility (Floor Plan)", () {
                // Navigate to FloorPlanScreen for testing
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FloorPlanScreen()),
                );
              }),
              _buildSettingTile(Icons.watch, "Bracelet (Bingo)", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BingoCardScreen()),
                );
              }),
              _buildSettingTile(Icons.filter_alt, "Filters", () {}),
              _buildSettingTile(Icons.link, "Connections", () {}),
              _buildSettingTile(Icons.language, "Language", () {}),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildSettingTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white,
        ),
        onTap: onTap,
        tileColor: Color(0xFFFFFFFF), // Dark background for each tile
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
