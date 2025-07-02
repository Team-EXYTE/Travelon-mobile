import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CreatorDashboard extends StatefulWidget {
  const CreatorDashboard({super.key});

  @override
  State<CreatorDashboard> createState() => _CreatorDashboardState();
}

class _CreatorDashboardState extends State<CreatorDashboard> {
  final TextEditingController _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _posts = [
    {
      'username': 'Helena',
      'country': 'England',
      'image': 'assets/post1.jpg', 
      'description': "Taking Sri Lanka's cultural and religious parades to the world",
      'profile': 'assets/user1.jpg',
    },
    {
      'username': 'Daniel',
      'country': 'Australia',
      'image': 'assets/post2.jpeg', 
      'description':
          "Ultimate destination in Sri Lanka",
      'profile': 'assets/user2.jpeg',
    },
  ];

  File? _selectedImage;
  bool _isUploading = false;

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  void _submitPost() {
    if (_selectedImage != null && _descriptionController.text.isNotEmpty) {
      setState(() {
        _posts.insert(0, {
          'username': 'You',
          'country': 'Sri Lanka',
          'image': _selectedImage!,
          'description': _descriptionController.text,
          'profile': 'assets/user1.jpg',
        });
        _selectedImage = null;
        _descriptionController.clear();
        _isUploading = false;
      });
    }
  }

  void _startUploading() {
    setState(() {
      _isUploading = true;
    });
  }

  void _cancelUploading() {
    setState(() {
      _isUploading = false;
      _selectedImage = null;
      _descriptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Travelon Moments',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isUploading)
            IconButton(icon: const Icon(Icons.add), onPressed: _startUploading),
          if (_isUploading)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelUploading,
            ),
        ],
      ),
      body: _isUploading ? _buildUploadForm() : _buildPostsList(),
    );
  }

  Widget _buildUploadForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share a place you admired:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : const Center(child: Text("Tap to select image")),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Write a short description...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitPost,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('Post', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(post['profile']),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          post['country'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(width: 4),
                    const Icon(Icons.more_vert, size: 18),
                  ],
                ),
                const SizedBox(height: 10),
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      post['image'] is File
                          ? Image.file(
                            post['image'],
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                          )
                          : Image.asset(
                            post['image'],
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                          ),
                ),
                const SizedBox(height: 10),
                // Description
                Text(post['description'], style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
