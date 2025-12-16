import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shift_application/models/reflection.dart';

/// Service for managing reflection data in Firestore
class ReflectionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  /// Collection reference for reflections
  CollectionReference get _reflectionsCollection => _db.collection('reflections');
  
  /// Save a new reflection to Firestore with detailed logging
  Future<String> saveReflection({
    required String who,
    String? emoji,
    String? opinionChanged,
    String? whatWasDiscussed,
    String? audioPath,
    required String statementId,
    String? userId,
  }) async {
    print('===== FIRESTORE SAVE ATTEMPT =====');
    print('Attempting to save reflection to Firestore');
    
    try {
      // Get current user ID if not provided
      final actualUserId = userId ?? _getCurrentUserId();
      print('User ID: $actualUserId');
      print('Statement ID: $statementId');
      
      // Create the data to save
      final reflectionData = {
        'who': who,
        'emoji': emoji,
        'opinionChanged': opinionChanged,
        'whatWasDiscussed': whatWasDiscussed,
        'audioPath': audioPath,
        'timestamp': FieldValue.serverTimestamp(),
        'statementId': statementId,
        'userId': actualUserId,
      };
      print('Data to save: $reflectionData');
      
      // Save to Firestore
      print('Saving to collection: reflections');
      final docRef = await _reflectionsCollection.add(reflectionData);
      
      print('Reflection saved to Firestore successfully');
      print('Document ID: ${docRef.id}');
      print('===== FIRESTORE SAVE COMPLETE =====');
      
      // Verify the save by reading it back
      final savedDoc = await docRef.get();
      print('Verification - Document exists: ${savedDoc.exists}');
      if (savedDoc.exists) {
        print('Saved data: ${savedDoc.data()}');
      }
      
      return docRef.id;
    } catch (e) {
      print('===== FIRESTORE SAVE ERROR =====');
      print('Error saving reflection: $e');
      print('Error details: ${e.toString()}');
      print('Stack trace: ${StackTrace.current}');
      throw Exception('Failed to save reflection: $e');
    }
  }
  
  /// Get current user ID with fallback to anonymous
  String _getCurrentUserId() {
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? 'anonymous-user';
    } catch (e) {
      print('Error getting user ID: $e');
      return 'anonymous-user';
    }
  }
  
  /// Get all reflections for a specific user
  Future<List<Reflection>> getUserReflections(String userId) async {
    try {
      final querySnapshot = await _reflectionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
          
      return querySnapshot.docs
          .map((doc) => Reflection.fromDoc(doc))
          .toList();
    } catch (e) {
      print('Error fetching user reflections: $e');
      return [];
    }
  }
  
  /// Get all reflections for a specific statement
  Future<List<Reflection>> getStatementReflections(String statementId) async {
    try {
      final querySnapshot = await _reflectionsCollection
          .where('statementId', isEqualTo: statementId)
          .orderBy('timestamp', descending: true)
          .get();
          
      return querySnapshot.docs
          .map((doc) => Reflection.fromDoc(doc))
          .toList();
    } catch (e) {
      print('Error fetching statement reflections: $e');
      return [];
    }
    
  }
  
  /// Test the Firestore connection by writing and reading a test document
  Future<Map<String, dynamic>> testFirestoreConnection() async {
    print('===== MANUAL FIRESTORE TEST =====');
    final result = <String, dynamic>{};
    
    try {
      // Test writing to Firestore
      final testData = {
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Test from ReflectionService',
      };
      
      print('Attempting to write test document...');
      final docRef = await FirebaseFirestore.instance
          .collection('test_collection')
          .add(testData);
      
      print('Test document written with ID: ${docRef.id}');
      result['documentId'] = docRef.id;
      result['success'] = true;
      
      // Read the document back
      final doc = await docRef.get();
      result['documentExists'] = doc.exists;
      result['documentData'] = doc.data();
      
      // Clean up - delete the test document
      await docRef.delete();
      print('Test document deleted');
      
      return result;
    } catch (e) {
      print('Error in manual Firestore test: $e');
      result['success'] = false;
      result['error'] = e.toString();
      return result;
    }
  }
  
  /// Ensure the reflections collection exists
  Future<void> ensureCollectionExists() async {
    print('===== CHECKING REFLECTIONS COLLECTION =====');
    try {
      // Try to get the collection
      final collections = await _reflectionsCollection.limit(1).get();
      print('Collection exists: ${collections.docs.isNotEmpty}');
      
      // If the collection doesn't exist, create it by adding a dummy document
      if (collections.docs.isEmpty) {
        print('Collection does not exist, creating it...');
        final docRef = await _reflectionsCollection.add({
          'dummy': true,
          'timestamp': FieldValue.serverTimestamp(),
          'message': 'Collection initialization document',
        });
        print('Created dummy document with ID: ${docRef.id}');
        
        // Delete the dummy document
        await docRef.delete();
        print('Deleted dummy document');
      }
      
      print('Reflections collection is ready');
    } catch (e) {
      print('Error checking/creating reflections collection: $e');
    }
    print('===== COLLECTION CHECK COMPLETE =====');
  }
  
  /// Stream all reflections for a specific user
  Stream<List<Reflection>> streamUserReflections(String userId) {
    try {
      return _reflectionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Reflection.fromDoc(doc))
                .toList();
          });
    } catch (e) {
      print('Error streaming user reflections: $e');
      return Stream.value([]);
    }
  }
  
  /// Get a specific reflection by ID
  Future<Reflection?> getReflection(String reflectionId) async {
    try {
      final docSnapshot = await _reflectionsCollection.doc(reflectionId).get();
      
      if (docSnapshot.exists) {
        return Reflection.fromDoc(docSnapshot);
      }
      return null;
    } catch (e) {
      print('Error fetching reflection: $e');
      return null;
    }
  }
  
  /// Update an existing reflection
  Future<void> updateReflection(String reflectionId, Map<String, dynamic> data) async {
    try {
      await _reflectionsCollection.doc(reflectionId).update(data);
    } catch (e) {
      print('Error updating reflection: $e');
      throw Exception('Failed to update reflection: $e');
    }
  }
  
  /// Delete a reflection
  Future<void> deleteReflection(String reflectionId) async {
    try {
      await _reflectionsCollection.doc(reflectionId).delete();
    } catch (e) {
      print('Error deleting reflection: $e');
      throw Exception('Failed to delete reflection: $e');
    }
  }
}
