import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../utils/custom_http_client.dart';
import 'med_profile.dart.';
import '../models/lists.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> _leaders = [];
  bool _isLoading = true;
  String? _selectedJob;
  String? _selectedSpec;
  bool? _selectedStud;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final customHttpClient = Provider.of<CustomHttpClient>(context, listen: false);
    String url = 'http://127.0.0.1:8000/core/leaderboard/?';

    if (_selectedJob != null) {
      url += 'job=$_selectedJob&';
    }
    if (_selectedSpec != null) {
      url += 'spec=$_selectedSpec&';
    }
    if (_selectedStud != null) {
      url += 'stud=$_selectedStud&';
    }

    try {
      final response = await customHttpClient.request('GET', Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _leaders = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load leaderboard';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our top 50 heroes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('Select Job'),
                    value: _selectedJob,
                    items: Jobs.map((String job) {
                      return DropdownMenuItem<String>(
                        value: job,
                        child: Text(job),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedJob = value;
                        if(_selectedJob == 'Dentist') {
                          _selectedSpec = 'none';
                        }
                        _fetchLeaderboard();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('Select Specialty'),
                    value: _selectedSpec,
                    items: Spec.map((String spec) {
                      return DropdownMenuItem<String>(
                        value: spec,
                        child: Text(spec),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        if(_selectedJob != 'Dentist') {
                          _selectedSpec = value;
                        }
                        else{
                          _selectedSpec = 'none';
                        }
                        _fetchLeaderboard();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _leaders.length,
              itemBuilder: (context, index) {
                final leader = _leaders[index];
                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${index + 1}',
                        style: const TextStyle(fontSize: 20.0),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundImage: NetworkImage("${leader['user_avatar']}"),
                        radius: 20.0,
                      ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Text(leader['person_username']),
                      if (leader['isStudent'] == true)
                        const Icon(
                          Icons.school,
                          color: Colors.green,
                          size: 16,
                        ),
                      if (leader['is_verified'] == true)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 16,
                        ),
                    ],
                  ),
                  subtitle: Text(
                    '${leader['job']} - ${leader['spec']}',
                  ),
                  trailing: Text(
                    '${leader['points']} pts',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedProfileScreen(
                          userId: leader['pk'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
