import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shift_application/services/reflection_service.dart';
import 'package:shift_application/models/reflection.dart';

/// Example showing how to connect the reflection screen to Firestore
class ReflectionFirestoreExample extends StatefulWidget {
  const ReflectionFirestoreExample({Key? key}) : super(key: key);

  @override
  State<ReflectionFirestoreExample> createState() => _ReflectionFirestoreExampleState();
}

class _ReflectionFirestoreExampleState extends State<ReflectionFirestoreExample> {
  final ReflectionService _reflectionService = ReflectionService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _discussionController = TextEditingController();
  String? _selectedEmoji;
  String? _opinionChanged;
  bool _isLoading = false;
  List<Reflection> _reflections = [];

  @override
  void initState() {
    super.initState();
    _loadReflections();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _discussionController.dispose();
    super.dispose();
  }

  // Load reflections from Firestore
  Future<void> _loadReflections() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID (you'll need to implement authentication)
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'test-user';
      
      // Load reflections for this user
      _reflections = await _reflectionService.getUserReflections(userId);
    } catch (e) {
      print('Error loading reflections: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reflections: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save a new reflection to Firestore
  Future<void> _saveReflection() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID (you'll need to implement authentication)
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'test-user';
      
      // Get current statement ID (from your app state or navigation)
      final statementId = 'current-statement-id';
      
      // Save to Firestore
      await _reflectionService.saveReflection(
        who: _nameController.text,
        emoji: _selectedEmoji,
        opinionChanged: _opinionChanged,
        whatWasDiscussed: _discussionController.text,
        statementId: statementId,
        userId: userId,
      );
      
      // Clear form
      _nameController.clear();
      _discussionController.clear();
      setState(() {
        _selectedEmoji = null;
        _opinionChanged = null;
      });
      
      // Reload reflections
      await _loadReflections();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reflection saved successfully')),
      );
    } catch (e) {
      print('Error saving reflection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save reflection: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflection Example'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form to add a new reflection
                  const Text('Add New Reflection', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Who field
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Who did you talk to?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Emoji selection
                  const Text('How did the conversation feel?'),
                  Wrap(
                    spacing: 8,
                    children: ['😊', '😐', '😢', '😠', '❤'].map((emoji) {
                      return ChoiceChip(
                        label: Text(emoji),
                        selected: _selectedEmoji == emoji,
                        onSelected: (selected) {
                          setState(() {
                            _selectedEmoji = selected ? emoji : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Opinion changed
                  const Text('Did your opinion change?'),
                  Row(
                    children: ['Yes', 'No'].map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: option,
                              groupValue: _opinionChanged,
                              onChanged: (value) {
                                setState(() {
                                  _opinionChanged = value;
                                });
                              },
                            ),
                            Text(option),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Discussion field
                  TextField(
                    controller: _discussionController,
                    decoration: const InputDecoration(
                      labelText: 'What was discussed?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  
                  // Save button
                  ElevatedButton(
                    onPressed: _saveReflection,
                    child: const Text('Save Reflection'),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Display existing reflections
                  const Text('Your Reflections', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  if (_reflections.isEmpty)
                    const Text('No reflections yet')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _reflections.length,
                      itemBuilder: (context, index) {
                        final reflection = _reflections[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            title: Text(reflection.who),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (reflection.emoji != null)
                                  Text('Feeling: ${reflection.emoji}'),
                                if (reflection.opinionChanged != null)
                                  Text('Opinion changed: ${reflection.opinionChanged}'),
                                if (reflection.whatWasDiscussed != null)
                                  Text('Discussed: ${reflection.whatWasDiscussed}'),
                                Text('Date: ${reflection.timestamp.toString().split('.')[0]}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}