import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/custom_http_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../models/lists.dart';
import '../utils/token_service.dart';

class CreateEditMedProfileScreen extends StatefulWidget {
  final int? userId;
  final bool isEditing;

  CreateEditMedProfileScreen({this.userId, this.isEditing = false});

  @override
  _CreateEditMedProfileScreenState createState() => _CreateEditMedProfileScreenState();
}

class _CreateEditMedProfileScreenState extends State<CreateEditMedProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool? isMed;
  int? id;
  String? username;
  String? _job;
  String? _spec;
  String? _bio;
  bool _isStudent = false;
  String? _avatarUrl;
  File? _avatarImage;
  int? _userId;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _fetchMedProfile();
    }
  }

  Future<void> _fetchMedProfile() async {
    final httpClient = Provider.of<CustomHttpClient>(context, listen: false);
    final response = await httpClient.request(
        'GET', Uri.parse('http://127.0.0.1:8000/core/read/med/${widget.userId}/'));

    if (response.statusCode == 200) {
      final profile = jsonDecode(response.body);
      setState(() {
        _job = profile['job'];
        _spec = profile['spec'];
        _bio = profile['bio'];
        _isStudent = profile['isStudent'];
        _avatarUrl ="http://127.0.0.1:8000${profile['user_avatar']}";
      });
    }
  }

  Future<void> _pickImage() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Use ImagePicker for Android and iOS
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _avatarImage = File(pickedFile.path);
          _avatarUrl = null;
        });
      }
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Use FilePicker for Windows, Linux, and macOS
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        setState(() {
          _avatarImage = File(result.files.single.path!);
          _avatarUrl = null;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('id');
    final httpClient = Provider.of<CustomHttpClient>(context, listen: false);
    final url = widget.isEditing
        ? Uri.parse('http://127.0.0.1:8000/core/registerMed/update/')
        : Uri.parse('http://127.0.0.1:8000/core/registerMed/');

    var request = http.MultipartRequest(
        widget.isEditing ? 'PUT' : 'POST', url);
    if (_job == 'dentist') {
      _spec = 'none';
    }
    request.fields['job'] = _job!;
    request.fields['spec'] = _spec!;
    request.fields['person'] = _userId.toString();
    request.fields['bio'] = _bio!;
    request.fields['isStudent'] = _isStudent.toString();

    if (_avatarImage != null) {
      request.files.add(await http.MultipartFile.fromPath('user_avatar', _avatarImage!.path));
    }

    final response = await httpClient.sendMultipartRequest(request);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if(widget.isEditing){
        await prefs.remove('isMed');
      }
      Navigator.of(context).pop(true);
      if (isMed == null || id == null || username == null ) {
        // If one of them is not set, make the request to get it
        isMed = true;
        await prefs.setBool('isMed', isMed!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Profile' : 'Create Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_avatarUrl!),
                  ),
                ),
              if (_avatarImage != null)
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(_avatarImage!),
                  ),
                ),
              if (_avatarUrl == null && _avatarImage == null)
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                ),
              SizedBox(height: 20),
              TextButton.icon(
                icon: Icon(Icons.image),
                label: Text('Pick an Image'),
                onPressed: _pickImage,
              ),
              DropdownButtonFormField<String>(
                value: _job,
                onChanged: (value) => setState(() => _job = value),
                items: Jobs.map((job) => DropdownMenuItem(
                  value: job,
                  child: Text(job),
                )).toList(),
                decoration: InputDecoration(labelText: 'Job'),
                validator: (value) => value == null ? 'Please select a job' : null,
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _spec,
                onChanged: (value) => setState(() => _spec = value),
                items: Spec.map((spec) => DropdownMenuItem(
                  value: spec,
                  child: Text(spec),
                )).toList(),
                decoration: InputDecoration(labelText: 'Specialization'),
                validator: (value) => value == null ? 'Please select a specialization' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: _bio,
                maxLength: 500,
                decoration: InputDecoration(labelText: 'Bio'),
                onChanged: (value) => setState(() => _bio = value),
                validator: (value) => value!.isEmpty ? 'Please enter a bio' : null,
              ),
              SizedBox(height: 16.0),
              CheckboxListTile(
                title: Text('Are you a student?'),
                value: _isStudent,
                onChanged: (value) => setState(() => _isStudent = value!),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text(widget.isEditing ? 'Save Changes' : 'Create Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
