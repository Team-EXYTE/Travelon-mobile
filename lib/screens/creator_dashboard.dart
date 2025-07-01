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
  final List<Map<String, dynamic>> _posts = [];
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
          'image': _selectedImage!,
          'description': _descriptionController.text,
        });
        _selectedImage = null;
        _descriptionController.clear();
        _isUploading = false;  // Go back to posts view after posting
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
        title: const Text('Travelon Moments', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isUploading)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _startUploading,
            ),
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
            const Text('Share a place you admired:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                child: _selectedImage != null
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
    return Padding(
      padding: const EdgeInsets.all(12),
      child: _posts.isEmpty
          ? const Center(child: Text('No posts shared yet.'))
          : ListView.builder(
              itemCount: _posts.length,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.file(post['image']),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(post['description'], style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
