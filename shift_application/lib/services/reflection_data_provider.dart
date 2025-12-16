import 'package:flutter/material.dart';
import 'package:shift_application/models/reflection.dart';
import 'package:shift_application/services/reflection_service.dart';

/// Provider for reflection data that can be used throughout the app
class ReflectionDataProvider extends ChangeNotifier {
  final ReflectionService _reflectionService;
  
  List<Reflection> _userReflections = [];
  bool _isLoading = false;
  String? _error;
  
  ReflectionDataProvider(this._reflectionService);
  
  /// Get all reflections for the current user
  List<Reflection> get reflections => _userReflections;
  
  /// Check if data is currently loading
  bool get isLoading => _isLoading;
  
  /// Get any error that occurred during data loading
  String? get error => _error;
  
  /// Load reflections for a specific user
  Future<void> loadUserReflections(String userId) async {
    _setLoading(true);
    
    try {
      _userReflections = await _reflectionService.getUserReflections(userId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load reflections: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Add a new reflection
  Future<void> addReflection({
    required String who,
    String? emoji,
    String? opinionChanged,
    String? whatWasDiscussed,
    String? audioPath,
    required String statementId,
    required String userId,
  }) async {
    _setLoading(true);
    
    try {
      await _reflectionService.saveReflection(
        who: who,
        emoji: emoji,
        opinionChanged: opinionChanged,
        whatWasDiscussed: whatWasDiscussed,
        audioPath: audioPath,
        statementId: statementId,
        userId: userId,
      );
      
      // Reload reflections to update the list
      await loadUserReflections(userId);
      _error = null;
    } catch (e) {
      _error = 'Failed to add reflection: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Delete a reflection
  Future<void> deleteReflection(String reflectionId, String userId) async {
    _setLoading(true);
    
    try {
      await _reflectionService.deleteReflection(reflectionId);
      
      // Reload reflections to update the list
      await loadUserReflections(userId);
      _error = null;
    } catch (e) {
      _error = 'Failed to delete reflection: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
