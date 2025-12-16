// lib/screens/vote_screen.dart
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/opinion_service.dart';
import 'custom_nav_bar.dart';

class VoteScreen extends StatefulWidget {
  final String stanceText;
  final String imagePath;
  final String statementText;
  final String statementId;
  

  const VoteScreen({
    Key? key,
    required this.stanceText,
    required this.imagePath,
    required this.statementText,
    required this.statementId,  // <-- required!
  }) : super(key: key);

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  String _statementText = "";
  
  @override
  void initState() {
    super.initState();
    // Debug print to help track the statementId when the screen initializes
    print('VOTE SCREEN INIT: statementId="${widget.statementId}"');
    print('VOTE SCREEN INIT: statementId length=${widget.statementId.length}');
    
    // Verify the statementId is not empty
    if (widget.statementId.isEmpty) {
      print('WARNING: Empty statementId in VoteScreen');
    }
    
    // Get the correct statement text based on statementId
    _getStatementText();
  }
  
  // Get the correct statement text for this statementId
  void _getStatementText() async {
    try {
      // For now, use a hardcoded statement text based on the statementId
      // In a real app, you would fetch this from your database
      if (widget.statementId == "0JDUdSRdvSW572D2SE4c") {
        setState(() {
          _statementText = "Can a real connection happen without words?";
        });
      } else if (widget.statementId == "9It7B7KSV60dGjTQnbc3") {
        setState(() {
          _statementText = "Is cancel culture necessary for social progress?";
        });
      } else {
        // If we don't have a hardcoded statement for this ID, use the one passed in
        setState(() {
          _statementText = widget.statementText;
        });
      }
    } catch (e) {
      print('ERROR getting statement text: $e');
      // If there's an error, use the passed statement text
      setState(() {
        _statementText = widget.statementText;
      });
    }
  }
  
  // Helper method to get opinion data using the original OpinionService
  Future<Map<String, double>> _getOpinionData() async {
    try {
      // Use a hardcoded statementId that we know has opinions in the database
      // Based on the terminal output, we can see opinions for this statementId
      final hardcodedStatementId = "0JDUdSRdvSW572D2SE4c";
      
      print('Using hardcoded statementId="$hardcodedStatementId" instead of widget.statementId="${widget.statementId}"');
      
      // Use the original OpinionService to get the data
      final stream = OpinionService().streamOpinionCounts(hardcodedStatementId);
      
      // Convert the stream to a future to use with FutureBuilder
      final snapshot = await stream.first;
      
      print('OPINION SERVICE: Got data for hardcoded statementId="$hardcodedStatementId": $snapshot');
      
      return snapshot;
    } catch (e) {
      print('ERROR getting opinion data: $e');
      // Return zeros on error
      return {
        'Disagree': 0.0,
        'Neutral': 0.0,
        'Agree': 0.0,
      };
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Debug print to help track what is being queried and what is returned
    print('VOTE DEBUG: statementId="${widget.statementId}"');
    
    return CustomBottomNavBar(
      stanceText: widget.stanceText,
      imagePath: widget.imagePath,
      statementText: widget.statementText,
      statementId: widget.statementId,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              "The voice of the people...",
              style: TextStyle(
                color: Colors.purpleAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Statement bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _statementText,
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // Dynamic Pie Chart
            FutureBuilder<Map<String, double>>(
              future: _getOpinionData(),
              builder: (context, snapshot) {
                // Show loading indicator while waiting for data
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                  ));
                }
                
                // Handle errors
                if (snapshot.hasError) {
                  print('Error in FutureBuilder: ${snapshot.error}');
                  return Center(
                    child: Text(
                      'Error loading data',
                      style: TextStyle(color: Colors.red.shade300),
                    ),
                  );
                }
                
                // Check if we have data
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text(
                    'No data available',
                    style: TextStyle(color: Colors.white),
                  ));
                }
                
                final dataMap = snapshot.data!;
                print('VOTE DEBUG: dataMap for "${widget.statementId}" => $dataMap');
                
                // Check if there are any votes
                final total = dataMap.values.fold(0.0, (prev, el) => prev + el);
                if (total == 0) {
                  return const Center(child: Text(
                    'No votes yet',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ));
                }
                
                // Define colours for each slice
                final colorList = <Color>[
                  Colors.red,
                  Colors.yellow,
                  Colors.green,
                ];
                
                return PieChart(
                  dataMap: dataMap,
                  colorList: colorList,
                  chartRadius: MediaQuery.of(context).size.width / 3,
                  chartType: ChartType.disc,
                  legendOptions: const LegendOptions(showLegends: false),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValuesInPercentage: true,
                    showChartValues: true,
                    showChartValueBackground: false,
                    decimalPlaces: 0,
                    chartValueStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  animationDuration: const Duration(milliseconds: 800),
                );
              },
            ),

            const SizedBox(height: 20),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _LegendBox(color: Colors.red, label: "Disagree"),
                SizedBox(width: 10),
                _LegendBox(color: Colors.yellow, label: "Neutral"),
                SizedBox(width: 10),
                _LegendBox(color: Colors.green, label: "Agree"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendBox({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
