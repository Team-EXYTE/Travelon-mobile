import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

class CreatorDashboard extends StatefulWidget {
  const CreatorDashboard({super.key});

  @override
  State<CreatorDashboard> createState() => _CreatorDashboardState();
}

class _CreatorDashboardState extends State<CreatorDashboard> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
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
    if (_selectedImage != null &&
        _descriptionController.text.isNotEmpty &&
        _locationController.text.isNotEmpty) {
      setState(() {
        _isPosting = true;
      });
      _uploadMoment(
        _selectedImage!,
        _descriptionController.text,
        _locationController.text,
      );
    }
  }

  Future<void> _uploadMoment(
    File imageFile,
    String description,
    String location,
  ) async {
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
      'location': location,
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
      _locationController.clear();
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
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: AppBar(
              title: const Text(
                'Travelon Moments',
                style: TextStyle(
                  color: Color(0xFF222B45),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
              backgroundColor: Colors.white70.withOpacity(0.55),
              elevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFF222B45)),
              actions: [
                if (_isUploading)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _cancelUploading,
                  ),
              ],
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE3EAF2), Color(0xFFD1E8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            _isUploading ? _buildUploadForm() : _buildPostsList(),
            if (_isPosting)
              Container(
                color: Colors.black.withOpacity(0.3),
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
          ],
        ),
      ),
      floatingActionButton:
          !_isUploading && !_isPosting
              ? FloatingActionButton(
                onPressed: _startUploading,
                backgroundColor: const Color.fromARGB(255, 13, 13, 14),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              )
              : null,
    );
  }

  Widget _buildUploadForm() {
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 18;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, topPadding, 12, 12),
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
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Enter location...',
                border: OutlineInputBorder(),
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
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 18;
    return ListView.builder(
      padding: EdgeInsets.only(top: topPadding, bottom: 18, left: 0, right: 0),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        final fullName =
            (((post['firstName'] ?? '') + ' ' + (post['lastName'] ?? ''))
                .trim());
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with user overlay and glass effect
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child:
                        post['imageUrl'] != null
                            ? Image.network(
                              post['imageUrl'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 220,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: Colors.grey[200],
                                    height: 220,
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 40),
                                    ),
                                  ),
                            )
                            : Container(
                              height: 220,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5F6FA),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 40),
                              ),
                            ),
                  ),
                  // User info overlay with glassmorphism
                  Positioned(
                    left: 18,
                    top: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.7),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                (post['profileImage'] != null &&
                                        post['profileImage']
                                            .toString()
                                            .isNotEmpty)
                                    ? NetworkImage(post['profileImage'])
                                    : const AssetImage('assets/user.png')
                                        as ImageProvider,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            fullName.isNotEmpty ? fullName : 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF222B45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Title (use description or fallback)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Text(
                  (post['description'] ?? '').isNotEmpty
                      ? post['description']
                      : 'Untitled',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF222B45),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Location (use a placeholder or add a location field if available)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        post['location'] ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF8F9BB3),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Date
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Text(
                  (post['timestamp'] is Timestamp)
                      ? (post['timestamp'] as Timestamp)
                          .toDate()
                          .toLocal()
                          .toString()
                          .split(' ')[0]
                      : post['timestamp']?.toString().split(' ')[0] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8F9BB3),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
