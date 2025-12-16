import 'package:cloud_firestore/cloud_firestore.dart';

class OpinionService {
  final _db = FirebaseFirestore.instance;

  /// Streams a map of stance → count for a given statementId.
  Stream<Map<String,double>> streamOpinionCounts(String statementId) {
    // Enhanced debug log
    print('======= OPINION SERVICE =======');
    print('Fetching opinion counts for statement: "$statementId"');
    print('Statement ID length: ${statementId.length}');
    print('Statement ID characters: ${statementId.split('').join(',')}');
    print('==============================');
    
    // Handle empty statementId
    if (statementId.isEmpty) {
      print('WARNING: Empty statementId provided to streamOpinionCounts');
      print('Returning actual zeros for empty statementId');
      return Stream.value({
        'Disagree': 0.0,
        'Neutral': 0.0,
        'Agree': 0.0,
      });
    }
    
    // Check for whitespace or invisible characters
    if (statementId.trim().isEmpty) {
      print('WARNING: statementId contains only whitespace');
      return Stream.value({
        'Disagree': 0.0,
        'Neutral': 0.0,
        'Agree': 0.0,
      });
    }
    
    try {
      print('QUERY DEBUG: Querying "opinions" collection with statementId="$statementId"');
      
      // IMPORTANT CHANGE: Instead of using a where clause, get all opinions and filter in the app
      // This avoids any potential issues with how the statementId is stored in the database
      return _db
          .collection('opinions')
          .snapshots()
          .map((snap) {
            
        // List all opinions to debug
        print('FOUND ${snap.docs.length} TOTAL OPINIONS IN DATABASE');
        
        // Check if there are any opinions with matching statementId
        bool foundMatch = false;
        for (var doc in snap.docs) {
          final data = doc.data();
          final docStatementId = data['statementId'] as String?;
          
          print('Opinion: id=${doc.id}, statementId=${docStatementId}, stance=${data['stance']}');
          
          // Check if this opinion matches our statementId
          if (docStatementId == statementId) {
            print('MATCH FOUND! This opinion matches our statementId');
            foundMatch = true;
          }
          
          // Check if there's a case-sensitivity issue
          if (docStatementId?.toLowerCase() == statementId.toLowerCase() && docStatementId != statementId) {
            print('CASE SENSITIVITY ISSUE! Database has "$docStatementId" but we\'re searching for "$statementId"');
          }
          
          // Check if there's a whitespace issue
          if (docStatementId?.trim() == statementId.trim() && docStatementId != statementId) {
            print('WHITESPACE ISSUE! Database has "$docStatementId" but we\'re searching for "$statementId"');
          }
        }
        
        if (!foundMatch) {
          print('NO MATCHING OPINIONS FOUND for statementId="$statementId"');
        }
        // Debug log
        print('======= OPINION SNAPSHOT =======');
        
        // initialize counts
        var agree = 0, neutral = 0, disagree = 0;
        
        // Filter opinions by statementId in the app
        final filteredDocs = snap.docs.where((doc) {
          final data = doc.data();
          final docStatementId = data['statementId'] as String?;
          return docStatementId == statementId;
        }).toList();
        
        print('Filtered to ${filteredDocs.length} opinions for statement: "$statementId"');
        
        for (var doc in filteredDocs) {
          try {
            final data = doc.data();
            final stance = data['stance'] as String?;
            
            // Debug log
            print('Opinion document: ${doc.id}, stance: $stance');
            
            if (stance == 'Agree') agree++;
            else if (stance == 'Neutral') neutral++;
            else if (stance == 'Disagree') disagree++;
          } catch (e) {
            print('Error processing opinion document: $e');
          }
        }
        
        // If no opinions found, return actual zeros instead of test data
        if (agree == 0 && neutral == 0 && disagree == 0) {
          print('NO OPINIONS FOUND - Returning actual zeros for statement: "$statementId"');
          // We'll return actual zeros so the chart shows real data
        }
        
        // Return in this order to match: red (Disagree), yellow (Neutral), green (Agree)
        final result = {
          'Disagree': disagree.toDouble(),
          'Neutral': neutral.toDouble(),
          'Agree': agree.toDouble(),
        };
        
        // Debug log
        print('Final opinion counts: $result');
        print('==============================');
        
        return result;
      });
    } catch (e) {
      print('CRITICAL ERROR in streamOpinionCounts: $e');
      
      // Return actual zeros on error to ensure chart shows real data
      print('Returning actual zeros due to error');
      return Stream.value({
        'Disagree': 0.0,
        'Neutral': 0.0,
        'Agree': 0.0,
      });
    }
  }
}
