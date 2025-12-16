import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

import 'custom_nav_bar.dart';

/// Defines the stages in the conversation guide flow.
/// This enum represents the three main phases of the conversation guide:
/// - chooseColor: User selects a bracelet color
/// - shakeToReveal: User shakes phone to reveal icebreaker
/// - showIcebreaker: Display the generated conversation starter
enum ConvoStage { chooseColor, shakeToReveal, showIcebreaker }

/// ConvoGuideScreen is a StatefulWidget that implements an interactive conversation guide.
/// Users select a bracelet color, shake their phone, and receive conversation starters
/// tailored to different perspectives on cancel culture based on the color chosen.
class ConvoGuideScreen extends StatefulWidget {
  final String stanceText;
  final String imagePath;
  final String statementText;
  final String statementId;

  const ConvoGuideScreen({
    super.key,
    required this.stanceText,
    required this.imagePath,
    required this.statementText,
    required this.statementId,
});
  @override
  _ConvoGuideScreenState createState() => _ConvoGuideScreenState();
}

class _ConvoGuideScreenState extends State<ConvoGuideScreen> {
  // Current stage in the conversation flow
  ConvoStage stage = ConvoStage.chooseColor;
  
  // Currently selected bracelet color (null if none selected)
  String? selectedColor;
  
  // The generated icebreaker text to display
  String? icebreakerText;
  
  // Previous accelerometer readings for shake detection
  double lastX = 0, lastY = 0, lastZ = 0;
  
  // Opacity for fade-in animation of icebreaker text
  double _opacity = 0.0;

  /// Map containing conversation prompts organized by bracelet color.
  /// Each color represents a different perspective on cancel culture:
  /// - Blue: Pro-cancel culture questions
  /// - Pink: Anti-cancel culture questions  
  /// - Yellow: Neutral/balanced questions
  final Map<String, List<String>> cancelCulturePrompts = {
    'blue': [
      'Why do you think cancel culture is necessary?',
      'What are the benefits of holding people accountable publicly?',
      'Do you think cancel culture can bring justice?'
    ],
    'pink': [
      'What are the dangers of cancel culture in your opinion?',
      'Have you seen examples where it went too far?',
      'How do you think cancel culture impacts freedom of expression?'
    ],
    'yellow': [
      'Do you think cancel culture is more good or more harm?',
      'Can cancel culture be helpful in some cases but damaging in others?',
      'How can we find a middle ground when it comes to calling out bad behavior?'
    ]
  };

  @override
  void initState() {
    super.initState();
    // Start listening for device shake gestures
    _startShakeDetection();
  }

  /// Initializes accelerometer listening to detect shake gestures.
  /// Uses the sensors_plus package to monitor device movement and trigger
  /// icebreaker revelation when sufficient shake is detected.
  void _startShakeDetection() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      // Calculate the change in acceleration from the last reading
      double dx = event.x - lastX;
      double dy = event.y - lastY;
      double dz = event.z - lastZ;
      
      // Calculate the magnitude of movement using 3D distance formula
      double shakeMagnitude = sqrt(dx * dx + dy * dy + dz * dz);

      // If shake is strong enough and we're past color selection, reveal icebreaker
      if (shakeMagnitude > 15 && stage != ConvoStage.chooseColor) {
        _revealIcebreaker();
      }

      // Store current readings for next comparison
      lastX = event.x;
      lastY = event.y;
      lastZ = event.z;
    });
  }

  /// Reveals a random icebreaker question based on the selected color.
  /// Provides haptic feedback, selects a random prompt from the appropriate
  /// color category, and animates the text appearance.
  void _revealIcebreaker() {
    // Don't proceed if no color is selected
    if (selectedColor == null) return;

    // Provide tactile feedback to user
    HapticFeedback.mediumImpact();

    List<String> options = cancelCulturePrompts[selectedColor!] ??
        ['Let\'s talk about cancel culture!'];
    final random = Random();
    
    // Select a random prompt from the available options
    String newPrompt = options[random.nextInt(options.length)];

    // Update state to show the icebreaker stage
    setState(() {
      icebreakerText = newPrompt;
      stage = ConvoStage.showIcebreaker;
      _opacity = 0.0; // Start with invisible text for fade-in effect
    });

    // Delay slightly then fade in the text for smooth animation
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  /// Handles color selection and advances to the shake-to-reveal stage.
  /// Called when user taps on one of the color buttons.
  void selectColor(String color) {
    setState(() {
      selectedColor = color;
      stage = ConvoStage.shakeToReveal;
    });
  }

  /// Resets the entire conversation flow back to the beginning.
  /// Clears all selections and returns to color selection stage.
  void resetConversation() {
    setState(() {
      selectedColor = null;
      icebreakerText = null;
      stage = ConvoStage.chooseColor;
      _opacity = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      // Pass the initial data to the custom bottom navigation bar
      stanceText: widget.stanceText,
      imagePath: widget.imagePath,
      statementText: widget.statementText,
      statementId: widget.statementId,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Color(0xFF3775FC), Color(0xFFA5C9FD)], // gradient colors
              center: Alignment.center,
              radius: 0.8,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Conversation Guide',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the appropriate content widget based on the current conversation stage.
  /// Returns different UI components depending on where the user is in the flow.
  Widget _buildContent() {
    switch (stage) {
      case ConvoStage.chooseColor:
        return _buildColorSelector();
      case ConvoStage.shakeToReveal:
        return _buildShakePrompt();
      case ConvoStage.showIcebreaker:
        return _buildIcebreakerCard();
      default:
        return const SizedBox();
    }
  }

  /// Builds the color selection interface.
  /// Displays instructions and three colored buttons (blue, pink, yellow)
  /// representing different perspectives on the conversation topic.
  Widget _buildColorSelector() {
    return Center(
      child: SizedBox(
        height: 340,
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Instructions for the user
              const Text(
                'Spot a bracelet?',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the color of the bracelet of the person you want to talk to.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 28),
              ColorButton(color: Colors.blue, onTap: () => selectColor('blue')),
              const SizedBox(height: 16),
              ColorButton(
                  color: Colors.pinkAccent, onTap: () => selectColor('pink')),
              const SizedBox(height: 16),
              ColorButton(
                  color: Colors.yellow, onTap: () => selectColor('yellow')),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the shake prompt interface.
  /// Displays instructions telling the user to shake their phone
  /// to reveal the conversation starter.
  Widget _buildShakePrompt() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.purpleAccent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Get Ready to Break the Ice!',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Shake Your Phone To Reveal',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the icebreaker display card.
  /// Shows the generated conversation starter with a fade-in animation
  /// and provides a "Start Over" button to reset the flow.
  Widget _buildIcebreakerCard() {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 800),
        opacity: _opacity,
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purpleAccent, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header text
              const Text(
                'Let the Conversation Begin:',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // The generated icebreaker question
              Text(
                '"$icebreakerText"',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              // Reset button to start the process over
              ElevatedButton(
                onPressed: resetConversation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Start Over"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ColorButton is a custom widget that creates a colored, tappable button.
/// Used in the color selection stage to let users choose bracelet colors.
class ColorButton extends StatelessWidget {
  final Color color;          // The background color of the button
  final VoidCallback onTap;   // Callback function when button is tapped

  const ColorButton({
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}