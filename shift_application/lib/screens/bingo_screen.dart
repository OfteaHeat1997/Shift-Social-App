import 'package:flutter/material.dart';

class BingoCardScreen extends StatefulWidget {
  const BingoCardScreen({super.key});

  @override
  State<BingoCardScreen> createState() => _BingoCardScreenState();
}

class _BingoCardScreenState extends State<BingoCardScreen> {
  List<List<bool>> selected = List.generate(3, (_) => List.filled(3, false));
  int points = 0;

  void _toggleCell(int row, int col) {
    setState(() {
      selected[row][col] = !selected[row][col];
      _calculatePoints();
    });
  }

  void _calculatePoints() {
    int newPoints = 0;
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (selected[r][c]) {
          newPoints += 10;
        }
      }
    }
    points = newPoints;
  }

 
  final List<List<String>> bingoTexts = [
    ["Talk to Green", "Talk to Yellow", "Talk to Red"], 
    ["Break the ice", "FREE", "Agree"], 
    ["Reach middleground", "Disagree", "Visit all booths"], 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Interaction Bingo",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  int row = index ~/ 3;
                  int col = index % 3;
                  bool isSelected = selected[row][col];

                  return GestureDetector(
                    onTap: () => _toggleCell(row, col),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.purpleAccent : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          bingoTexts[row][col],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Text(
            'Points: $points',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
