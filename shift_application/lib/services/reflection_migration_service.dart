import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift_application/services/reflection_service.dart';

/// Service to migrate existing reflections from SharedPreferences to Firestore
class ReflectionMigrationService {
  final ReflectionService _reflectionService;
  
  ReflectionMigrationService(this._reflectionService);
  
  /// Migrate all reflections from SharedPreferences to Firestore
  /// Returns the number of reflections migrated
  Future<int> migrateReflections({
    required String userId,
    required String statementId,
  }) async {
    try {
      // Get reflections from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final reflections = prefs.getStringList('reflections') ?? [];
      
      if (reflections.isEmpty) {
        return 0;
      }
      
      int migratedCount = 0;
      
      // Migrate each reflection to Firestore
      for (final reflectionJson in reflections) {
        try {
          final reflection = jsonDecode(reflectionJson) as Map<String, dynamic>;
          
          // Save to Firestore
          await _reflectionService.saveReflection(
            who: reflection['who'] ?? '',
            emoji: reflection['emoji'],
            opinionChanged: reflection['opinionChanged'],
            whatWasDiscussed: reflection['whatWasDiscussed'],
            statementId: statementId,
            userId: userId,
          );
          
          migratedCount++;
        } catch (e) {
          print('Error migrating reflection: $e');
          // Continue with next reflection
        }
      }
      
      // Optionally clear SharedPreferences after successful migration
      // await prefs.remove('reflections');
      
      return migratedCount;
    } catch (e) {
      print('Error in migration process: $e');
      return 0;
    }
  }
}