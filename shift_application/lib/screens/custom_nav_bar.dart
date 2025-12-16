import 'package:flutter/material.dart';
import 'package:shift_application/screens/bracelet_screen.dart';
import 'package:shift_application/screens/reflection.dart';
import 'vote_screen.dart';
import 'settings_screen.dart';


class CustomBottomNavBar extends StatelessWidget {
  final String stanceText;
  final String imagePath;
  final String statementText;
  final String statementId;
  final Widget child;

  const CustomBottomNavBar({
    super.key,
    required this.stanceText,
    required this.imagePath,
    required this.statementText,
    required this.statementId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFA5C9FD),
      // Page content:
      body: child,
      // Curved nav as bottomNavigationBar:
      bottomNavigationBar: SizedBox(
        height: 75,
        child: Stack(
          children: [
            // a) the curved background
            CustomPaint(
              size: Size(size.width, 75),
              painter: BNBCustomPainter(),
            ),

            // b) center FAB
            Positioned(
              bottom: 20,
              left: size.width / 2 - 28,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BraceletScreen(
                        stanceText: stanceText,
                        imagePath: imagePath,
                        statementText: statementText,
                        statementId: statementId,
                        braceletColor: Colors.purple, // Default color
                      ),
                    ),
                  );
                },
                backgroundColor: Colors.white,
                elevation: 2,
                child: Image.asset('assets/icons/watch_neutral.png', width: 20),
              ),
            ),

            // c) nav icons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/home'),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home, color: Colors.black),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Text("Home", style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Debug print to verify statementId before navigation
                      print('NAV DEBUG: Navigating to VoteScreen with statementId="$statementId"');
                      print('NAV DEBUG: statementId length=${statementId.length}');
                      
                      // Verify the statementId is not empty
                      if (statementId.isEmpty) {
                        print('WARNING: Empty statementId in CustomBottomNavBar when navigating to VoteScreen');
                      }
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VoteScreen(
                            stanceText: stanceText,
                            imagePath: imagePath,
                            statementText: statementText,
                            statementId: statementId,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pie_chart, color: Colors.black),
                        SizedBox(height: 4), // spacing between icon and text
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Vote",
                            style: TextStyle(fontFamily: 'SpaceGrotesk',
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 56), // space for FAB
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReflectionScreen(
                            stanceText: stanceText,
                            imagePath: imagePath,
                            statementText: statementText,
                            statementId: statementId,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.self_improvement, color: Colors.black),
                        SizedBox(height: 4), // spacing between icon and text
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Reflect",
                            style: TextStyle(fontFamily: 'SpaceGrotesk',
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(
                            stanceText: stanceText,
                            imagePath: imagePath,
                            statementText: statementText,
                            statementId: statementId,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, color: Colors.black),
                        SizedBox(height: 4), // spacing between icon and text
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Profile",
                            style: TextStyle(fontFamily: 'SpaceGrotesk',
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(0, 20);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(
      Offset(size.width * 0.60, 20),
      radius: const Radius.circular(10.0),
      clockwise: false,
    );
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    //canvas.drawShadow(path, Colors.white, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
