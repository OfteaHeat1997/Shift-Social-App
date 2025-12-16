import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// A service to test Firebase connectivity
class FirebaseTestService {
  /// Test if Firebase is initialized and Firestore is accessible
  static Future<Map<String, dynamic>> testFirestore() async {
    final result = <String, dynamic>{};
    
    try {
      // Check if Firebase is initialized
      result['firebaseInitialized'] = Firebase.apps.isNotEmpty;
      print('Firebase initialized: ${result['firebaseInitialized']}');
      
      if (!result['firebaseInitialized']) {
        result['error'] = 'Firebase is not initialized';
        return result;
      }
      
      // Try to write a test document to Firestore
      print('Attempting to write test document to Firestore...');
      final testData = {
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Test document',
      };
      
      final docRef = await FirebaseFirestore.instance
          .collection('test_collection')
          .add(testData);
      
      result['testDocumentId'] = docRef.id;
      print('Test document written with ID: ${docRef.id}');
      
      // Try to read the test document back
      print('Attempting to read test document from Firestore...');
      final docSnapshot = await docRef.get();
      
      result['documentExists'] = docSnapshot.exists;
      print('Test document exists: ${docSnapshot.exists}');
      
      if (docSnapshot.exists) {
        result['documentData'] = docSnapshot.data();
        print('Test document data: ${docSnapshot.data()}');
      }
      
      // Clean up - delete the test document
      print('Cleaning up - deleting test document...');
      await docRef.delete();
      print('Test document deleted');
      
      result['success'] = true;
      print('Firestore test completed successfully');
    } catch (e) {
      print('Error testing Firestore: $e');
      result['success'] = false;
      result['error'] = e.toString();
    }
    
    return result;
  }
}