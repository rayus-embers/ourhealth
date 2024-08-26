import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/utils/token_service.dart';
import 'create_medprofile.dart';
import 'med_profile.dart';
import 'login_screen.dart';
import 'package:frontend/utils/formatdate.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool? isMed;
  int? id;
  String? username;

  List<dynamic> _posts = [];
  bool _isLoading = true;
  String _errorMessage = '';
  TextEditingController _searchController = TextEditingController();
  List<String> _selectedBodyParts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _checkIsMed();
    _fetchPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkIsMed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isMed = prefs.getBool('isMed');
    id = prefs.getInt('id');
    username = prefs.getString('username');

    if (isMed == null || id == null || username == null ) {
      // If one of them is not set, make the request to get it
      final tokenService = Provider.of<TokenService>(context, listen: false);
      final response = await tokenService.makeAuthenticatedRequest('http://127.0.0.1:8000/core/getmyid/');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        isMed = data['isMed'];
        id = data['id'];
        username = data['username'];
        await prefs.setBool('isMed', isMed!);
        await prefs.setString('username', username!);
        await prefs.setInt('id', id!);

      } else {
      }
    }

    setState(() {});
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final tokenService = Provider.of<TokenService>(context, listen: false);
    try {
      final queryParameters = {
        'search': _searchController.text,
        if (_selectedBodyParts.isNotEmpty)
          'area_of_pain': _selectedBodyParts.join(',')
      };
      final uri = Uri.http('127.0.0.1:8000', '/socials/posts/', queryParameters);

      final response = await tokenService.makeAuthenticatedRequest(uri.toString());

      if (response.statusCode == 200) {
        setState(() {
          _posts = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load posts';
          _isLoading = false;
        });
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage == "Exception: Access token is null") {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  void _onSearchChanged() {
    _fetchPosts();
  }

  void _onBodyPartSelected(String part) {
    setState(() {
      if (_selectedBodyParts.contains(part)) {
        _selectedBodyParts.remove(part);
      } else if (_selectedBodyParts.length < 6) {
        _selectedBodyParts.add(part);
      }
      _fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600 && screenHeight > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search posts by title...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(isMed == true ? 'View Medical Profile' : 'Create Medical Profile'),
              onTap: () {
                Navigator.pop(context);
                if (isMed == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedProfileScreen(userId: id!),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateEditMedProfileScreen(
                      ),
                    ),
                  ).then((result) {
                    if (result == true) {
                      setState(() {
                        _checkIsMed();
                      });
                    }
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.health_and_safety),
              title: const Text('LeaderBoard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/leaderboard');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                final tokenService = Provider.of<TokenService>(context, listen: false);
                tokenService.logout();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: isLargeScreen ? 150 : 50,
            child: isLargeScreen
                ? _buildBodyPartGrid()
                : _buildBodyPartScrollable(),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Card(
                  child: ListTile(
                    title: Text(post['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatDate(post['date']) ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4.0),
                        Wrap(
                          spacing: 4.0,
                          children: (post['area_of_pain'] as List<dynamic>).map((area) {
                            return Chip(
                              label: Text(area),
                              backgroundColor: Colors.lightBlueAccent.withOpacity(0.2),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/postDetail',
                        arguments: post['id'],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreatePostScreen())).then((result) {
            if (result == true) {
              setState(() {
                _fetchPosts();
              });
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBodyPartGrid() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _buildBodyPartTiles(),
    );
  }

  Widget _buildBodyPartScrollable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _buildBodyPartTiles(),
      ),
    );
  }

  List<Widget> _buildBodyPartTiles() {
    List<String> bodyParts = [
      'full body', 'upper body', 'lower body', 'head', 'neck', 'nose',
      'mouth', 'teeth', 'eyes', 'ears', 'forehead', 'shoulder',
      'chest', 'arm', 'forearm', 'hand', 'elbow', 'wrist', 'upper back',
      'lower back', 'abdomen', 'glutes', 'hips', 'genitals', 'fingers/toes',
      'palm', 'thigh', 'knee', 'calf', 'ankle', 'foot'
    ];

    return bodyParts.map((part) {
      final isSelected = _selectedBodyParts.contains(part);
      return GestureDetector(
        onTap: () => _onBodyPartSelected(part),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.grey[200],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            part,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
    }).toList();
  }
}

