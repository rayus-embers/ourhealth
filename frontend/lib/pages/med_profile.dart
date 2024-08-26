import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/custom_http_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_medprofile.dart';
class MedProfileScreen extends StatefulWidget {
  final int userId;

  MedProfileScreen({required this.userId});

  @override
  State<MedProfileScreen> createState() => _MedProfileScreenState();
}

class _MedProfileScreenState extends State<MedProfileScreen> {
  Future<Map<String, dynamic>> _fetchMedProfile(BuildContext context) async {
    final httpClient = Provider.of<CustomHttpClient>(context, listen: false);
    final response = await httpClient.request('GET', Uri.parse('http://127.0.0.1:8000/core/read/med/${widget.userId}/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load medical profile');
    }
  }

  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Profile'),
        actions: [
          FutureBuilder(
              future: _getCurrentUserId(),
              builder: (builder, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                else if (snapshot.hasData && snapshot.data == widget.userId){
                  return IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateEditMedProfileScreen(
                            userId: widget.userId,
                            isEditing: true,
                          ),
                        ),
                      );
                      if (result == true) {
                        setState(() {
                          _fetchMedProfile(context);
                        });

                      }
                    },
                  );
                }
                else{
                  return Container();
                }
              }
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchMedProfile(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final profile = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (profile['user_avatar'] != null)
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage("http://127.0.0.1:8000${profile['user_avatar']}"),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        'Job: ${profile['job'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Specialization: ${profile['spec'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Bio: ${profile['bio'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Points: ${profile['points'] ?? 0}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No profile found.'));
          }
        },
      ),
    );
  }
}
