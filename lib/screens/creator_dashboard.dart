import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatorDashboard extends StatefulWidget {
  const CreatorDashboard({super.key});

  @override
  State<CreatorDashboard> createState() => _CreatorDashboardState();
}

class _CreatorDashboardState extends State<CreatorDashboard> {
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _posts = [];
  @override
  void initState() {
    super.initState();
    _fetchMoments();
  }

  Future<void> _fetchMoments() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('moments')
            .orderBy('timestamp', descending: true)
            .get();
    setState(() {
      _posts = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  File? _selectedImage;
  bool _isUploading = false;
  bool _isPosting = false;

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
        _isPosting = true;
      });
      _uploadMoment(_selectedImage!, _descriptionController.text);
    }
  }

  Future<void> _uploadMoment(File imageFile, String description) async {
    // Upload image to Firebase Storage
    final fileName =
        'moments/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final ref = FirebaseStorage.instance.ref().child(fileName);
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    final imageUrl = await snapshot.ref.getDownloadURL();

    // Save post to Firestore
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';
    String firstName = '';
    String lastName = '';
    String profileImage = '';
    if (userId.isNotEmpty) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users-travellers')
              .doc(userId)
              .get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        if (data['firstName'] != null) {
          firstName = data['firstName'];
        }
        if (data['lastName'] != null) {
          lastName = data['lastName'];
        }
        if (data['profileImage'] != null) {
          profileImage = data['profileImage'];
        }
      }
    }
    final post = {
      'imageUrl': imageUrl,
      'description': description,
      'userID': userId,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance.collection('moments').add(post);
    setState(() {
      _selectedImage = null;
      _descriptionController.clear();
      _isUploading = false;
      _isPosting = false;
    });
    _fetchMoments();
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
          if (_isUploading)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelUploading,
            ),
        ],
      ),
      body: Stack(
        children: [
          _isUploading ? _buildUploadForm() : _buildPostsList(),
          if (_isPosting)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Posting...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          if (!_isUploading && !_isPosting)
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Center(
                child: ElevatedButton(
                  onPressed: _startUploading,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 5, 5, 5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Add Yours',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
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
                      backgroundImage:
                          (post['profileImage'] != null &&
                                  post['profileImage'].toString().isNotEmpty)
                              ? NetworkImage(post['profileImage'])
                              : const AssetImage('assets/user.png')
                                  as ImageProvider,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              post['firstName'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if ((post['lastName'] ?? '')
                                .toString()
                                .isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                post['lastName'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ],
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
                      post['imageUrl'] != null
                          ? Image.network(
                            post['imageUrl'],
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                          )
                          : const SizedBox(
                            height: 200,
                            child: Center(child: Text('No image')),
                          ),
                ),
                const SizedBox(height: 10),
                // Description
                Text(
                  post['description'] ?? '',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 6),
                // Date
                Text(
                  (post['timestamp'] is Timestamp)
                      ? (post['timestamp'] as Timestamp)
                          .toDate()
                          .toLocal()
                          .toString()
                          .split(' ')[0]
                      : post['timestamp']?.toString().split(' ')[0] ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
