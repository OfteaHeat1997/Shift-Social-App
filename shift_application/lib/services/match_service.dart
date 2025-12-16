import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class MatchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Starts searching for a match, creating a temporary doc in Firestore.
  Future<void> startMatchSearch({
    required String userId,
    required String statementId,
    required String opinion,
  }) async {
    final Position position = await Geolocator.getCurrentPosition();
    final GeoPoint geoPoint = GeoPoint(position.latitude, position.longitude);

    await _db.collection('match_search').doc(userId).set({
      'userId': userId,
      'statementId': statementId,
      'opinion': opinion,
      'location': geoPoint,
      'timestamp': FieldValue.serverTimestamp(),
      'matched': false,
      'matchedWith': null,
    });
  }

  /// Stops searching for a match and deletes the temporary doc from Firestore.
  Future<void> stopMatchSearch(String userId) async {
    await _db.collection('match_search').doc(userId).delete();
  }

  /// Listen for nearby matches with DIFFERENT opinions on the same statement
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> listenNearbyMatches({
    required String statementId,
    required String opinion,
  }) {
    // We can't use a "not equal" query directly with Firestore
    // So we need to get all users for this statement and filter client-side
    print('Looking for matches with different opinions than: $opinion');
    return _db.collection('match_search')
        .where('statementId', isEqualTo: statementId)
        .where('matched', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          print('Found ${snapshot.docs.length} potential matches for statement: $statementId');
          
          // Filter out users with the same opinion
          final differentOpinions = snapshot.docs.where((doc) {
            final data = doc.data();
            final otherOpinion = data['opinion'];
            final otherUserId = data['userId'];
            final isMatch = otherOpinion != opinion;
            
            if (isMatch) {
              print('MATCH FOUND: User $otherUserId has different opinion: $otherOpinion');
            } else {
              print('Not a match: User $otherUserId has same opinion: $otherOpinion');
            }
            
            return isMatch;
          }).toList();
          
          print('Filtered to ${differentOpinions.length} matches with different opinions');
          return differentOpinions;
        });
  }
  
  /// Calculate distance between two coordinates in meters using Haversine formula
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const earthRadius = 6371000; // meters
    final dLat = _degreesToRadians(endLatitude - startLatitude);
    final dLon = _degreesToRadians(endLongitude - startLongitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLatitude)) *
            cos(_degreesToRadians(endLatitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
  
  /// Calculate bearing (direction) from start point to end point
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final startLat = _degreesToRadians(startLatitude);
    final startLng = _degreesToRadians(startLongitude);
    final endLat = _degreesToRadians(endLatitude);
    final endLng = _degreesToRadians(endLongitude);

    final dLng = endLng - startLng;

    final y = sin(dLng) * cos(endLat);
    final x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLng);

    final bearing = atan2(y, x);
    
    // Convert to radians for the radar display (0 is up, clockwise)
    return bearing;
  }
}
