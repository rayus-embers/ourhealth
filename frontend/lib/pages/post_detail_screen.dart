import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/token_service.dart';
import '../utils/custom_http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:frontend/utils/formatdate.dart';

import 'med_profile.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  PostDetailScreen({required this.postId});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Map<String, dynamic>? _post;
  List<dynamic> _comments = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int? _userId;
  String? _username;
  bool? _isMed;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchPostDetails();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('id');
      _isMed = prefs.getBool('isMed');
      _username = prefs.getString('username');
    });
  }

  Future<void> _fetchPostDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final tokenService = Provider.of<TokenService>(context, listen: false);
    try {
      final postResponse = await tokenService.makeAuthenticatedRequest(
        'http://127.0.0.1:8000/socials/post/${widget.postId}/',
      );

      if (postResponse.statusCode == 200) {
        setState(() {
          _post = jsonDecode(postResponse.body);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load post details';
        });
      }

      final commentsResponse = await tokenService.makeAuthenticatedRequest(
        'http://127.0.0.1:8000/socials/posts/${widget.postId}/comments/',
      );

      if (commentsResponse.statusCode == 200) {
        setState(() {
          _comments = jsonDecode(commentsResponse.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load comments';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.isEmpty) return;

    final customHttpClient = Provider.of<CustomHttpClient>(context, listen: false);
    final url = Uri.parse('http://127.0.0.1:8000/socials/comments/create/');

    try {
      final response = await customHttpClient.request(
        'POST',
        url,
        body: {'content': _commentController.text, 'commented_on': widget.postId},
      );

      if (response.statusCode == 201) {
        _commentController.clear();
        _fetchPostDetails();
      } else {
        setState(() {
          _errorMessage = 'Failed to post comment';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  Future<void> _editComment(int commentId, String updatedContent) async {
    final customHttpClient = Provider.of<CustomHttpClient>(context, listen: false);

    try {
      final response = await customHttpClient.request(
        'PUT',
        Uri.parse('http://127.0.0.1:8000/socials/comments/$commentId/edit/'),
        body: {'content': updatedContent, 'commented_on': widget.postId},
      );

      if (response.statusCode == 200) {
        _fetchPostDetails();
      } else {
        print('Failed to edit comment: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> _voteOnComment(int commentId, bool isUpvote) async {
    final customHttpClient = Provider.of<CustomHttpClient>(context, listen: false);
    final url = Uri.parse('http://127.0.0.1:8000/socials/comments/react/');

    try {
      final response = await customHttpClient.request(
        'POST',
        url,
        body: {'reaction': isUpvote ? 1 : -1, "reacted_on":commentId},
      );

      if (response.statusCode == 200) {
        _fetchPostDetails();
      } else {
        print('Failed to vote on comment: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _post?['title'] ?? '',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                _post?['description'] ?? '',
                style: const TextStyle(fontSize: 16.0),
              ),
              Text(
                formatDate(_post?['date']) ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8.0),
              if (_post?['area_of_pain'] != null && (_post!['area_of_pain'] as List).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Areas of Pain:',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      for (var area in _post!['area_of_pain'] as List<dynamic>)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '• $area',
                            style: const TextStyle(fontSize: 16.0, color: Colors.green),
                          ),
                        ),
                    ],
                  ),
                ),
              const Divider(),
              if (_isMed == true)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add a comment',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your comment',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: _postComment,
                        child: Text('Post Comment'),
                      ),
                    ],
                  ),
                ),
              const Divider(),
              const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              ..._comments.map((comment) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_upward),
                              onPressed: () {
                                _voteOnComment(comment['id'], true);
                              },
                            ),
                            Text(comment['score'].toString()),
                            IconButton(
                              icon: Icon(Icons.arrow_downward),
                              onPressed: () {
                                _voteOnComment(comment['id'], false);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MedProfileScreen(
                                            userId: comment['commentor_id'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'By: ${comment['commentor_username']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (comment['commentor_school'] == true)
                                    const Icon(
                                      Icons.school,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                  if (comment['commentor_status'] == true)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                  if (comment['edited'] == true)
                                    const Text(" (edited)"),
                                ],
                              ),

                              const SizedBox(height: 4.0),
                              Text(comment['content']),
                              if (_username == comment['commentor_username'])
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showEditDialog(comment['id'], comment['content']);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(int commentId, String originalContent) {
    TextEditingController _editController = TextEditingController(text: originalContent);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Comment'),
          content: TextField(
            controller: _editController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Update your comment',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _editComment(commentId, _editController.text);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
