// lib/screens/match_user_screen.dart

import 'package:flutter/material.dart';
import 'package:shift_application/services/match_user_service.dart';
import 'package:shift_application/screens/convo_guide_screen.dart';

/// A screen that shows the match user interface with the purple radar animation
class MatchUserScreen extends StatefulWidget {
  final String stanceText;
  final String imagePath;
  final String statementText;
  final String statementId;

  const MatchUserScreen({
    Key? key,
    required this.stanceText,
    required this.imagePath,
    required this.statementText,
    required this.statementId,
  }) : super(key: key);

  @override
  State<MatchUserScreen> createState() => _MatchUserScreenState();
}

class _MatchUserScreenState extends State<MatchUserScreen> {
  final MatchUserService _matchUserService = MatchUserService();
  int _currentStep = 0;
  
  // Steps for the match user process
  final List<Map<String, String>> _steps = [
    {
      "title": "Find your Match",
      "description": "It's so cold in here!",
      "buttonText": "Continue",
    },
    {
      "title": "Find your Match",
      "description": "You are getting warmer, keep going!",
      "buttonText": "Continue",
    },
    {
      "title": "Find your Match",
      "description": "Keep going!",
      "buttonText": "Continue",
    },
    {
      "title": "Find your Match",
      "description": "Almost there!",
      "buttonText": "Continue",
    },
    {
      "title": "You have found your match!",
      "description": "Now you can start talking!",
      "buttonText": "Start Conversation",
    },
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Navigate to the conversation guide screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConvoGuideScreen(
            stanceText: widget.stanceText,
            imagePath: widget.imagePath,
            statementText: widget.statementText,
            statementId: widget.statementId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    
    return _matchUserService.createMatchUserWidget(
      size: MediaQuery.of(context).size.width * 0.7,
      title: step["title"]!,
      description: step["description"]!,
      buttonText: step["buttonText"]!,
      onButtonPressed: _nextStep,
    );
  }
}