import 'package:shift_application/main.dart';
import 'package:shift_application/screens/convo_guide_screen.dart';
import 'package:shift_application/screens/match_user/match_reveal_screen.dart';
import 'package:shift_application/services/match_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bracelet_screen.dart';
import 'custom_nav_bar.dart';
class  MatchScreen extends StatefulWidget {
  final String stanceText;
  final String imagePath;
  final String statementText;
  final String statementId;
  const MatchScreen({
    super.key,
    required this.stanceText,
    required this.imagePath,
    required this.statementText,
    required this.statementId,
});
  @override
  State<MatchScreen> createState() => _MatchScreenState();
}
class _MatchScreenState extends State<MatchScreen> {
  final PageController _controller = PageController(); // Controls swiping between pages
  int _currentPage = 0; // Tracks the current onboarding page index
  final MatchService _matchService = MatchService(); // Service for match functionality
  @override
  void initState() {
    super.initState();
    // Start searching for a match when the screen loads
    _startMatchSearch();
  }
  @override
  void dispose() {
    // Stop searching for a match when the screen is closed
    _stopMatchSearch();
    super.dispose();
  }
  // Start searching for a match
  void _startMatchSearch() async {
    try {
      await _matchService.startMatchSearch(
        userId: 'current_user_id', // Replace with actual user ID
        statementId: widget.statementId,
        opinion: widget.stanceText,
      );
    } catch (e) {
      print('Error starting match search: $e');
    }
  }
  // Stop searching for a match
  void _stopMatchSearch() async {
    try {
      await _matchService.stopMatchSearch('current_user_id'); // Replace with actual user ID
    } catch (e) {
      print('Error stopping match search: $e');
    }
  }
  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', true); // Avoid showing onboarding again

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

// Content for each onboarding page: title, description, and image
  List<Map<String, dynamic>> pages = [
    {
      "title": "Find Your Match",
      "description": "You are getting warmer, keep going!",
      "image": "assets/images/smallfire.png",
    },
    {
      "title": "Find Your Match",
      "description": "Keep going!",
      "image": "assets/images/mediumfire.png",
    },
    {
      "title": "Find Your Match",
      "description": "Almost there!",
      "image": "assets/images/bigfire.png",
    },
    {
      "title": "You've Found Your Match",
      "description": "Now you can start talking!",
      "image": "assets/images/matched_image.png",
    },
  ];

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index), // Update dot indicator
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // "Skip" button in top right corner
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: _completeOnboarding,
                            child: const Text("Skip", style: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.black)),
                          ),
                        ),

                        // Stack to maintain the same UI structure
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Original image
                            Image.asset(pages[index]["image"], height: 300),
                            // Purple radar animation removed as requested
                          ],
                        ),
                        // Page title
                        Text(
                          pages[index]["title"],
                          style: const TextStyle(fontFamily: 'SpaceGrotesk',color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),

                        // Page description
                        Text(
                          pages[index]["description"],
                          style: const TextStyle(fontFamily: 'Manrope', color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),

                        // If it's the last page, show "Let's get started" button
                        index == pages.length - 1
                            ? ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => ConvoGuideScreen(
                                    stanceText: widget.stanceText,
                                    imagePath: widget.imagePath,
                                    statementText: widget.statementText,
                                    statementId: widget.statementId,
                                  )),
                                  );
                                }, 
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                                  child: Text("Go to Match Reveal!", style: TextStyle(fontFamily: 'Manrope',fontSize: 16, color: Colors.black)),
                                ),
                              )

                            // Otherwise, show next arrow button
                            : IconButton(
                                onPressed: () => _controller.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                ),
                                icon: const Icon(Icons.arrow_forward, color: Colors.black),
                              ),

                         // Dots indicator for onboarding progress      
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            pages.length,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == i ? Colors.black : Colors.white
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}