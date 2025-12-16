import 'dart:async';
import 'dart:convert';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
// Removed emoji_picker_flutter import
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift_application/screens/custom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shift_application/services/firebase_test_service.dart';
import 'package:shift_application/services/reflection_service.dart';

class ReflectionScreen extends StatefulWidget {
  final String stanceText;
  final String imagePath;
  final String statementText;
  final String statementId;

  const ReflectionScreen({
    super.key,
    required this.stanceText,
    required this.imagePath,
    required this.statementText,
    required this.statementId,
  });
  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _discussionController = TextEditingController();
  String? _selectedEmoji, _customEmoji, _opinionChanged;

  final List<String> emojis = ['😊', '😐', '😢', '😠', '❤'];

  late RecorderController _recorderController;
  final AudioPlayer _player = AudioPlayer();
  String? _recordedFilePath;
  bool _isRecording = false, _isRecorded = false;
  StreamSubscription<Duration>? _recSub;
  Duration _currentDuration = Duration.zero;
  
  // Initialize reflection service
  final ReflectionService _reflectionService = ReflectionService();

  @override
  void initState() {
    super.initState();
    _recorderController = RecorderController()..checkPermission();
    
    // Test Firebase connectivity
    _testFirebase();
  }
  
  // Test Firebase connectivity
  Future<void> _testFirebase() async {
    print('===== TESTING FIREBASE CONNECTIVITY =====');
    try {
      final result = await FirebaseTestService.testFirestore();
      print('Firebase test result: $result');
      if (result['success'] == true) {
        print('Firebase connectivity test passed!');
        
        // Check if the reflections collection exists using the service
        await _reflectionService.ensureCollectionExists();
      } else {
        print('Firebase connectivity test failed: ${result['error']}');
      }
    } catch (e) {
      print('Error testing Firebase: $e');
    }
    print('===== FIREBASE TEST COMPLETE =====');
  }

  @override
  void dispose() {
    _textController.dispose();
    _discussionController.dispose();
    _recorderController.dispose();
    _player.dispose();
    _recSub?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission denied'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      await _recorderController.record();
      setState(() {
        _isRecording = true;
        _isRecorded = false;
      });
      _recSub = _recorderController.onCurrentDuration.listen((dur) {
        setState(() => _currentDuration = dur);
      });
    } catch (e) {
      debugPrint("Failed to start recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorderController.stop();
      setState(() {
        _recordedFilePath = path;
        _isRecording = false;
        _isRecorded = true;
      });
      _recSub?.cancel();
    } catch (e) {
      debugPrint("Failed to stop recording: $e");
    }
  }

  Future<void> _playRecording() async {
    if (_recordedFilePath == null) return;
    await _player.setFilePath(_recordedFilePath!);
    _player.play();
  }

  void _reRecord() {
    setState(() {
      _isRecorded = false;
      _currentDuration = Duration.zero;
    });
  }

  // List of common emojis to choose from
  final List<String> _commonEmojis = [
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇',
    '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘', '😗', '😙', '😚',
    '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐', '🤓', '😎', '🤩',
    '😏', '😒', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣', '😖',
    '😫', '😩', '🥺', '😢', '😭', '😤', '😠', '😡', '🤬', '🤯'
  ];

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            Navigator.pop(context);
            setState(() {
              _customEmoji = emoji.emoji;
              _selectedEmoji = emoji.emoji;
            });
          },
          config: Config(
          emojiViewConfig: const EmojiViewConfig(
            columns: 7,
            backgroundColor: Color(0xFF1A1A1A),
            /* adjust spacing, sizes, etc */
            noRecents: Text('No Recents', style: TextStyle(color: Colors.white54)),
          ),
          categoryViewConfig: const CategoryViewConfig(
            indicatorColor: Color(0xFFC084FC),
            iconColor: Colors.grey,
            iconColorSelected: Color(0xFFC084FC),
            backspaceColor: Colors.white,
          ),
          skinToneConfig: const SkinToneConfig(
            dialogBackgroundColor: Color(0xFF1A1A1A),
            indicatorColor: Color(0xFFC084FC),
          ),
          // optionally customize other sections:
          // bottomActionBarConfig, searchViewConfig, etc.
        ),
      ),
    ),
  );
}
  void _handleSave() async {
    // 1. Save to SharedPreferences (original functionality)
    final prefs = await SharedPreferences.getInstance();
    final reflections = prefs.getStringList('reflections') ?? [];

    final localReflection = {
      'who': _textController.text,
      'emoji': _selectedEmoji,
      'opinionChanged': _opinionChanged,
      'whatWasDiscussed': _discussionController.text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    reflections.add(jsonEncode(localReflection));
    await prefs.setStringList('reflections', reflections);

    // 2. Save to Firestore using ReflectionService
    try {
      print('===== FIRESTORE SAVE ATTEMPT =====');
      print('Attempting to save reflection to Firestore using ReflectionService');
      
      // Get current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous-user';
      
      // Use the service to save the reflection
      final docId = await _reflectionService.saveReflection(
        who: _textController.text,
        emoji: _selectedEmoji,
        opinionChanged: _opinionChanged,
        whatWasDiscussed: _discussionController.text,
        audioPath: _recordedFilePath,
        statementId: widget.statementId,
        userId: userId,
      );
      
      print('Reflection saved to Firestore successfully');
      print('Document ID: $docId');
      print('===== FIRESTORE SAVE COMPLETE =====');
      
    } catch (e) {
      print('===== FIRESTORE SAVE ERROR =====');
      print('Error saving to Firestore: $e');
      print('Error details: ${e.toString()}');
      print('Stack trace: ${StackTrace.current}');
    }

    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Saved Successfully', style: TextStyle(color: Colors.white)),
        content: const Text('Your reflection has been saved.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _textController.clear();
                _discussionController.clear();
                _selectedEmoji = _customEmoji = null;
                _opinionChanged = null;
                _isRecorded = false;
                _recordedFilePath = null;
                _currentDuration = Duration.zero;
              });
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFFC084FC))),
          ),
        ],
      ),
    );
  }

  void _showPastReflections() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('reflections') ?? [];

    final List<Map<String, dynamic>> reflections =
        saved.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reflections.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white12),
        itemBuilder: (_, index) {
          final r = reflections[index];
          final title = r['who'] ?? 'Unnamed';
          final timestamp = DateTime.tryParse(r['timestamp'] ?? '');
          final date = timestamp != null
              ? '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day}'
              : 'Unknown date';
          return ListTile(
            title: Text(title, style: const TextStyle(color: Colors.white)),
            subtitle: Text(date, style: const TextStyle(color: Colors.white60)),
            onTap: () => _showReflectionDetails(r),
          );
        },
      ),
    );
  }

  void _showReflectionDetails(Map<String, dynamic> r) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(r['who'] ?? 'Reflection', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (r['emoji'] != null)
              Text("Feeling: ${r['emoji']}", style: const TextStyle(color: Colors.white)),
            if (r['opinionChanged'] != null)
              Text("Opinion changed: ${r['opinionChanged']}", style: const TextStyle(color: Colors.white)),
            if (r['whatWasDiscussed'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Discussed:\n${r['whatWasDiscussed']}", style: const TextStyle(color: Colors.white)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFFC084FC))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final durText = _currentDuration.toString().split('.').first;
    return CustomBottomNavBar(
      // Pass initial data to the custom bottom nav bar
      stanceText: widget.stanceText,
      imagePath: widget.imagePath,
      statementText: widget.statementText,
      statementId: widget.statementId,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
  onPressed: _showPastReflections,
  icon: const Icon(Icons.event_note, color: Color(0xFFC084FC)),
  iconSize: 32.0,
  tooltip: 'View Past Reflections',
),

                    ),
                    const Text('New Reflection', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 28),
                    const Text('Who did you talk to?', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        hintText: 'Enter a name...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('How did the conversation feel?', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ...emojis.map((e) {
                          final sel = _selectedEmoji == e;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedEmoji = e),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sel ? const Color(0xFFC084FC) : const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(e, style: const TextStyle(fontSize: 24)),
                            ),
                          );
                        }),
                        GestureDetector(
                          onTap: _showEmojiPicker,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _selectedEmoji == _customEmoji ? const Color(0xFFC084FC) : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(_customEmoji ?? '+',
                                style: TextStyle(
                                    fontSize: _customEmoji != null ? 24 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text('Did your opinion change?', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    const SizedBox(height: 10),
                    Row(
                      children: ['Yes', 'No'].map((v) {
                        return Row(
                          children: [
                            Checkbox(
                              value: _opinionChanged == v,
                              onChanged: (_) => setState(() => _opinionChanged = v),
                              activeColor: const Color(0xFFC084FC),
                              checkColor: Colors.black,
                            ),
                            Text(v, style: const TextStyle(color: Colors.white)),
                            const SizedBox(width: 20),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    const Text('What was discussed?', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _discussionController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        hintText: 'Type here...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('Any additional notes?', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onLongPress: _isRecording ? null : _startRecording,
                            onLongPressUp: _isRecording ? _stopRecording : null,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                size: 30,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          if (_isRecording || _isRecorded) ...[
                            const SizedBox(height: 16),
                            AudioWaveforms(
                              enableGesture: false,
                              size: const Size(double.infinity, 60),
                              recorderController: _recorderController,
                            ),
                            const SizedBox(height: 8),
                            Text(durText, style: const TextStyle(color: Colors.white)),
                          ],
                          if (_isRecorded && !_isRecording) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: _playRecording,
                                  child: const Text('🔁 Play', style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 24),
                                TextButton(
                                  onPressed: _reRecord,
                                  child: const Text('🗑 Re-record', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC084FC),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Save Reflection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    // Test button for Firestore using ReflectionService
                    ElevatedButton(
                      onPressed: () async {
                        print('===== MANUAL FIRESTORE TEST =====');
                        try {
                          // Test using the reflection service
                          final result = await _reflectionService.testFirestoreConnection();
                          
                          print('Test result: $result');
                          
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Firestore test successful!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          print('Error in manual Firestore test: $e');
                          
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Firestore test failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Test Firestore Connection', style: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}