// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// OnboardingScreen that shows the first time the user opens the app.
// It introduces the app's concept and flow using multiple pages.

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  // Content for each onboarding page
  final List<Map<String, dynamic>> pages = [
    {
      "title": "Welcome to Shift",
      "description": "Share your opinion on interesting topics, have engaging conversations and shift your mind!",
      "image": "assets/images/onboarding1.png",
    },
    {
      "title": "How it Works?",
      "description": "Connect your watch to the app!",
      "image": "assets/images/onboarding2.png",
    },
    {
      "title": "How it Works?",
      "description": "Open the app each week to see the statement of the day. And choose your opinion: Agree, Disagree or Neutral!",
      "image": "assets/images/onboarding3.png",
    },
    {
      "title": "How it Works?",
      "description": "See others' opinions by their watch and start a conversation IRL at the events we've selected. With the help of our conversation starters!",
      "image": "assets/images/onboarding4.png",
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Skip button
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: _completeOnboarding,
                            child: const Text("Skip", style: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.black)),
                          ),
                        ),

                        // Image
                        Image.asset(
                          pages[index]["image"],
                          height: 300,
                          fit: BoxFit.contain,
                        ),

                        // Title
                        Text(
                          pages[index]["title"],
                          style: const TextStyle(fontFamily: 'SpaceGrotesk',color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),

                        // Description
                        Text(
                          pages[index]["description"],
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // If it's the last page, show "Let's get started" button
                        index == pages.length - 1
                            ? ElevatedButton(
                                onPressed: _completeOnboarding,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                                  child: Text("Let's get started!", style: TextStyle(fontFamily: 'Manrope',fontSize: 16, color: Colors.black)),
                                ),
                              )
                            // Otherwise, show next arrow button
                            : IconButton(
                                onPressed: () => _controller.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                ),
                                icon: const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFFC084FC),
                                ),
                              ),

                        // Page indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            pages.length,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 8,
                              ),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == i ? Colors.black : Colors.white
                              ),
                            ),
                          ),
                        ),
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