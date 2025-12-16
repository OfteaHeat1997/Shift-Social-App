// lib/services/match_user_service.dart

import 'dart:math';
import 'package:flutter/material.dart';

/// A service for matching users with the radar animation
class MatchUserService {
  /// Creates a match user widget with the radar animation
  Widget createMatchUserWidget({
    required double size,
    required String title,
    required String description,
    required VoidCallback onButtonPressed,
    required String buttonText,
  }) {
    return MatchUserWidget(
      size: size,
      title: title,
      description: description,
      onButtonPressed: onButtonPressed,
      buttonText: buttonText,
    );
  }
}

/// A widget that displays the match user screen with radar animation
class MatchUserWidget extends StatefulWidget {
  final double size;
  final String title;
  final String description;
  final VoidCallback onButtonPressed;
  final String buttonText;

  const MatchUserWidget({
    Key? key,
    required this.size,
    required this.title,
    required this.description,
    required this.onButtonPressed,
    required this.buttonText,
  }) : super(key: key);

  @override
  State<MatchUserWidget> createState() => _MatchUserWidgetState();
}

class _MatchUserWidgetState extends State<MatchUserWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xFFC084FC),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Radar animation
            Expanded(
              child: Center(
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) {
                      return CustomPaint(
                        size: Size(widget.size, widget.size),
                        painter: PurpleRadarPainter(rotation: _ctrl.value * 2 * pi),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                widget.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Button
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: ElevatedButton(
                onPressed: widget.onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC084FC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text(
                  widget.buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter for the simplified purple radar animation
class PurpleRadarPainter extends CustomPainter {
  /// rotation of the gradient arc in radians
  final double rotation;
  PurpleRadarPainter({this.rotation = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Just draw the purple circle background
    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF6840FB).withOpacity(0.1);
    
    canvas.drawCircle(center, radius, circlePaint);

    // Animated gradient sector (semi-circle slice)
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradientPaint = Paint()
      ..shader = SweepGradient(
        startAngle: rotation - pi / 2,       // rotate this sweep
        endAngle: rotation - pi / 2 + pi,    // 180° sweep
        colors: [
          const Color.fromARGB(255, 156, 130, 248), // your base purple
          const Color.fromARGB(255, 120, 114, 126), // brighter secondary purple
          const Color.fromARGB(255, 84, 7, 151).withOpacity(0.0),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawArc(rect, rotation - pi / 2, pi, true, gradientPaint);

    // Draw the purple beacon in the center
    drawPurpleBeacon(canvas, size);
  }

  /// Draws the purple beacon in the center of the radar
  void drawPurpleBeacon(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // radius of the purple core
    final coreRadius = size.width * 0.11;

    // 1) Full, semi-transparent purple halo behind beacon
    canvas.drawCircle(
      center,
      coreRadius * 2.75,
      Paint()..color = const Color(0xFF6840FB).withOpacity(0.3),
    );

    // draw the dark ring just outside the core
    canvas.drawCircle(
      center,
      coreRadius + 4,
      Paint()..color = const Color(0xFF44306B),
    );

    // draw the main purple core
    canvas.drawCircle(
      center,
      coreRadius,
      Paint()..color = const Color(0xFF6840FB),
    );

    // draw eight light-purple rays extending outward
    final rayPaint = Paint()
      ..color = const Color(0xFFAE8CFC)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = coreRadius * 0.2;
    final rayLength = coreRadius * 0.6;
    for (var i = 0; i < 8; i++) {
      final angle = 2 * pi * i / 8;
      final start = center + Offset(cos(angle), sin(angle)) * coreRadius;
      final end =
          center + Offset(cos(angle), sin(angle)) * (coreRadius + rayLength);
      canvas.drawLine(start, end, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PurpleRadarPainter old) =>
      old.rotation != rotation;
}