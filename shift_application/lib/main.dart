import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shift_application/firebase_options.dart';
import 'package:shift_application/screens/onboarding_screen.dart';
import 'package:shift_application/screens/reflection.dart';
import 'package:shift_application/screens/bracelet_screen.dart';
import 'package:shift_application/screens/custom_nav_bar.dart';
import 'package:shift_application/components/slide_stance_button.dart';
import 'package:shift_application/models/statement.dart';
import 'package:shift_application/services/statement_service.dart';
import 'package:shift_application/services/bracelet_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}



// The root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shift Application',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(shape: CircleBorder()),
      ),
      home:OnboardingScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/reflection': (context) => ReflectionScreen(
              stanceText: 'Neutral',
              statementText: 'Can smart technology make us better humans?',
              imagePath: 'assets/images/neutral_watch.png',
              statementId: '0JDUdSRdvSW572D2SE4c', // Use the actual statementId from the database
            ),
      },
    );
  }
}


// The main home screen, which shows the stance selection
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const StanceSelectionScreen();
  }
}

// The main screen where users select their stance on a statement
class StanceSelectionScreen extends StatefulWidget {
  const StanceSelectionScreen({super.key});

  @override
  State<StanceSelectionScreen> createState() => _StanceSelectionScreenState();
}

class _StanceSelectionScreenState extends State<StanceSelectionScreen> {
  Statement? _statement; // The current statement
  bool _isLoading = true; // Loading state
  String? _error; // Error message
  String? selectedStance; // User's selected stance

  // Maps stance to image asset
  final Map<String, String> stanceToImage = {
    'Agree': 'assets/images/agree_watch.png',
    'Disagree': 'assets/images/disagree_watch.png',
    'Neutral': 'assets/images/neutral_watch.png',
  };

  // Gets the image path for the selected stance
  String get imagePath =>
      stanceToImage[selectedStance] ?? 'assets/images/neutral_watch.png';
  String statementText = "Pineapple on Pizza is delicious";

  // This method is used for the simple UI without Firebase
  void selectStance(String stance) {
    setState(() {
      selectedStance = stance;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BraceletScreen(
          stanceText: stance,
          imagePath: stanceToImage[stance]!,
          statementText: statementText,
          statementId: '0JDUdSRdvSW572D2SE4c', // Use the actual statementId from the database
          braceletColor: _getBraceletColor(stance, statementText),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadStatement();
  }

  // Loads the statement from the database
  Future<void> _loadStatement() async {
    try {
      final all = await StatementService().fetchAll();
      if (all.isNotEmpty) {
        setState(() {
          _statement = (all..shuffle()).first;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No statements found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading statement: $e';
        _isLoading = false;
      });
    }
  }

  // Handles the user selecting a stance and saves it to Firestore
  // This method is used by the second build method
  void _selectStanceWithFirebase(String stance) {
    // Use anonymous ID since we removed login
    final uid = 'anonymous-user';
    final stmtId = _statement!.id;
    
    // Create document ID
    final docId = stmtId + '_' + uid;
    
    // Set document with specific ID instead of using .add()
    FirebaseFirestore.instance.collection('opinions').doc(docId).set({
      'userId': uid,
      'statementId': stmtId,
      'stance': stance,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    setState(() => selectedStance = stance);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BraceletScreen(
        stanceText: stance,
        imagePath: stanceToImage[stance]!,
        statementText: _statement!.text,
        statementId: _statement!.id,
        braceletColor: BraceletService.getBraceletColor(stance, _statement!),
      ),
    ));
  }

  // Converts a hex color string to a Color
  Color _fromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
  
  // Gets the bracelet color based on the stance and statement text
  Color _getBraceletColor(String stance, String statementText) {
    // Create a simple Statement object with default colors
    final statement = Statement(
      id: '0JDUdSRdvSW572D2SE4c',
      text: statementText,
      agreeColor: '#36EAB7',    // Green
      neutralColor: '#FFD600',  // Yellow
      disagreeColor: '#F64060', // Red
    );
    
    return BraceletService.getBraceletColor(stance, statement);
  }

  @override
  Widget build(BuildContext context) {
    // Show loading spinner if loading
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Show error if there is one
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    }

    final stmt = _statement!;
    final agreeBg = _fromHex(stmt.agreeColor);
    final neutralBg = _fromHex(stmt.neutralColor);
    final disagreeBg = _fromHex(stmt.disagreeColor);

    final agreeText =
        agreeBg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final neutralText =
        neutralBg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final disagreeText =
        disagreeBg.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    // Main UI for stance selection
    return CustomBottomNavBar(
      stanceText: selectedStance ?? 'Neutral',
      imagePath: imagePath,
      statementText: stmt.text,
      statementId: stmt.id,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Statements',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade200,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  stmt.text,
                  style: const TextStyle(
                      fontSize: 20, color: Colors.white, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 200),
              // Slide buttons for each stance
              SlideStanceButton(
                label: 'Slide to Agree',
                gradient: [agreeBg, agreeBg],
                textStyle: TextStyle(color: agreeText),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: agreeText,
                  fontSize: 18,
                ),
                onTap: () => _selectStanceWithFirebase('Agree'),
              ),
              const SizedBox(height: 44),
              SlideStanceButton(
                label: 'Slide to Disagree',
                gradient: [disagreeBg, disagreeBg],
                textStyle: TextStyle(color: disagreeText),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: disagreeText,
                  fontSize: 18,
                ),
                onTap: () => _selectStanceWithFirebase('Disagree'),
              ),
              const SizedBox(height: 44),
              SlideStanceButton(
                label: 'Slide to Neutral',
                gradient: [neutralBg, neutralBg],
                textStyle: TextStyle(color: neutralText),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: neutralText,
                  fontSize: 18,
                ),
                onTap: () => _selectStanceWithFirebase('Neutral'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
