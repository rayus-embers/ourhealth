import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/custom_http_client.dart';
import 'dart:convert';
import '../utils/token_service.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int _descriptionLength = 0;
  List<String> _selectedBodyParts = [];

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_updateDescriptionLength);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateDescriptionLength() {
    setState(() {
      _descriptionLength = _descriptionController.text.length;
    });
  }

  Future<void> _createPost() async {
    if (_formKey.currentState!.validate() && _selectedBodyParts.isNotEmpty) {
      final customHttpClient = Provider.of<CustomHttpClient>(context, listen: false);

      final Map<String, dynamic> postData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'area_of_pain': _selectedBodyParts,
        'author':1
      };
      final response = await customHttpClient.request(
        'POST',
        Uri.parse('http://127.0.0.1:8000/socials/post/'),
        headers: {'Content-Type': 'application/json'},
        body: postData,
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);  // the true is to send a signal to reload the posts
      } else {
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields and select at least one body part.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Column(
                children: [
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$_descriptionLength/500',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              _buildBodyPartSelection(),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _createPost,
                child: const Text('Create Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyPartSelection() {
    List<String> bodyParts = [
      'full body', 'upper body', 'lower body', 'head', 'neck', 'nose',
      'mouth', 'teeth', 'eyes', 'ears', 'forehead', 'shoulder',
      'chest', 'arm', 'forearm', 'hand', 'elbow', 'wrist', 'upper back',
      'lower back', 'abdomen', 'glutes', 'hips', 'genitals', 'fingers/toes',
      'palm', 'thigh', 'knee', 'calf', 'ankle', 'foot'
    ];

    return Wrap(
      spacing: 8.0,
      children: bodyParts.map((part) {
        return FilterChip(
          label: Text(part),
          selected: _selectedBodyParts.contains(part),
          onSelected: (bool selected) {
            setState(() {
              if (selected && _selectedBodyParts.length < 6) {
                _selectedBodyParts.add(part);
              } else {
                _selectedBodyParts.remove(part);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
