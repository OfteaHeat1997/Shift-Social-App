// lib/screens/match_reveal_screen.dart
// This file implements the screen that reveals to users they have been matched

import 'package:flutter/material.dart';
import 'package:shift_application/screens/custom_nav_bar.dart';         // Custom navigation bar
import 'package:shift_application/components/slide_stance_button.dart'; // Interactive button component
import 'package:shift_application/screens/hot_cold_match.dart'; // Hot and cold match screen


/// A screen that says "You have been matched", shows an illustration,
/// a subtitle, and a "show my symbol match" button.
///
/// This is a key moment in the user journey - it's the celebratory screen
/// that appears when the system has found a match for the user. From here,
/// they can proceed to draw the spiral symbol to activate the radar.
class MatchRevealScreen extends StatelessWidget {
  final String stanceText;
  final String imagePath;
  final String statementText;
  final String statementId;

  const MatchRevealScreen({
    super.key,
    this.stanceText = 'Neutral',
    this.imagePath = 'assets/images/neutral_watch.png',
    this.statementText = 'You have been matched',
    this.statementId = '',
  });

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      // Navigation bar configuration
      stanceText: stanceText,
      imagePath: imagePath,
      statementText: statementText,  // Shows the match status in the nav bar
      statementId: statementId,
      child: Container(
        // Full-screen black container
        color: const Color.fromARGB(255, 0, 0, 0),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 80),  // Adjusted top spacing

              // ─────────── ❶ Main Title ───────────
              // Large purple heading announcing the match
              const Text(
                'You have been matched',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFC084FC),  // Updated purple color to match design
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),  // Adjusted spacing

              // ─────────── ❷ Match Illustration ───────────
              // Visual representation of the match with a celebratory image
              Expanded(
                flex: 3,
                child: Center(
                  child: Image.asset(
                    'assets/images/match_hot_cold.png',
                    // Responsive width based on screen size
                    width: MediaQuery.of(context).size.width * 0.8,
                    fit: BoxFit.contain,  // Maintain aspect ratio
                  ),
                ),
              ),

              // ─────────── ❸ Instructional Subtitle and Button ───────────
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),  // Reduced bottom padding
                child: Column(
                  mainAxisSize: MainAxisSize.min,  // Use minimum space needed
                  children: [
                    // Instructional text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: const Text(
                        'Find your match using the cold/hot radar. '
                        'Let\'s see how fast you can do it!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,  // Slightly smaller font
                          height: 1.4,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),  // Reduced spacing
                    
                    // ─────────── ❹ Action Button ───────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: SlideStanceButton(
                        label: 'Find my Match',
                        // Purple gradient for the button
                        gradient: const [Color(0xFFC084FC), Color(0xFFC084FC)],
                        onTap: () {
                          // Navigate to the spiral instruction screen when tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchScreen(
                                stanceText: stanceText,
                                imagePath: imagePath,
                                statementText: 'Find your match',
                                statementId: statementId,
                              ),
                            ),
                          );
                        },
                        // Button text styling
                        textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
