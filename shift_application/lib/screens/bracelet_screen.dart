// lib/screens/bracelet_screen.dart
import 'package:shift_application/screens/match_user/match_reveal_screen.dart';
import 'package:flutter/material.dart';
import 'package:shift_application/screens/custom_nav_bar.dart';

// This screen shows the user's bracelet stance, a corresponding image, and a statement.
// It also wraps the screen with a custom bottom navigation bar.

class BraceletScreen extends StatefulWidget {
  // The user's stance on a topic ("agree", "disagree", "inbetween")
  final String stanceText;
  // Path to the image representing the bracelet color
  final String imagePath;
  // The current statement which is also on the homepage
  final String statementText;
  // The statement ID
  final String statementId;
  // The color for the bracelet from the database
  final Color braceletColor;

  const BraceletScreen({
    super.key,
    required this.stanceText,
    required this.imagePath,
    required this.statementText,
    required this.statementId,
    required this.braceletColor,
  });

  @override
  State<BraceletScreen> createState() => _BraceletScreenState();
}

class _BraceletScreenState extends State<BraceletScreen> {
  // Local copies of the stance, image, statement, and color that can be updated
  late String currentStance;
  late String currentImage;
  late String currentStatement;
  late Color currentBraceletColor;

  @override
  void initState() {
    super.initState();
    // Initialize the screen with data passed from the widget constructor
    currentStance = widget.stanceText;
    currentImage = widget.imagePath;
    currentStatement = widget.statementText;
    currentBraceletColor = widget.braceletColor;
  }
  
  // Method to update the bracelet's appearance, statement, and color
  void updateBracelet(String newStance, String newImage, String newOpinion, Color newColor) {
    setState(() {
      currentStance = newStance;
      currentImage = newImage;
      currentStatement = newOpinion;
      currentBraceletColor = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      // Pass initial data to the custom bottom nav bar
      stanceText: widget.stanceText,
      imagePath: widget.imagePath,
      statementText: widget.statementText,
      statementId: widget.statementId,
      // Main screen content inside the navigation
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Keeps content centered vertically
            children: [
              // Statement box
              Container(
                height: 40,
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFF404040),
                ),
                alignment: Alignment.center,
                child: Text(
                  currentStatement,
                  style: const TextStyle(fontFamily: 'Manrope', color: Colors.white),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ), 
              const SizedBox(height: 20),
              
              // Text displaying the stance
              Text(
                "You $currentStance",
                style: const TextStyle(fontFamily: 'SpaceGrotesk', color: Color(0xFFC084FC)),
              ),
              
              // Bracelet image with color indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  // Bracelet image
                  Image.asset(
                    currentImage,
                    height: 300,
                    width: 400, 
                    fit: BoxFit.contain,
                  ),
                  // Colored circle on top of the bracelet image
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentBraceletColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 50),
              
              // Inform user that bracelet color has changed
              Transform.translate(
                offset: const Offset(0, -30),
                child: const Text(
                  'Bracelet Color changed',
                  style: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.white),
                ),
              ),
              
              // 1) Wrap your Vector.png in a GestureDetector to navigate to MatchScreen
              GestureDetector(
                onTap: () {
                  // You might first send the color‐change command to the watch here.
                  // Then navigate to the MatchRevealScreen first:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchRevealScreen(
                        stanceText: widget.stanceText,
                        imagePath: widget.imagePath,
                        statementText: widget.statementText,
                        statementId: widget.statementId,
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/Vector.png',
                  height: 60,
                  width: 60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
