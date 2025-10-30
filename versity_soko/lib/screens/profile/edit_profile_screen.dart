import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  File? _imageFile;
  bool _isSaving = false;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    _nameController = TextEditingController(text: user?.userMetadata?['name']?.toString() ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _bioController = TextEditingController(text: user?.userMetadata?['bio']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final newName = _nameController.text.trim();
    final newBio = _bioController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in.');
      }

      final updateResponse = await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'name': newName,
            'bio': newBio,
          },
        ),
      );

      if (updateResponse.user == null) {
        throw Exception('Failed to update user profile');
      }

      // 🔹 Optional: update your 'profiles' table as well if you’re using it
      // await supabase.from('profiles').upsert({
      //   'id': user.id,
      //   'name': newName,
      //   'bio': newBio,
      //   'updated_at': DateTime.now().toIso8601String(),
      // });

      // ✅ Clear all text fields after success
      _nameController.clear();
      _bioController.clear();

      setState(() => _isSaving = false);

      authProvider.refreshUser();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey[800],
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!) as ImageProvider
                    : NetworkImage('https://picsum.photos/400/600?random=20'),
                child: Stack(
                  children: [
                    if (_imageFile == null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 91, 144, 94),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Full Name
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Color.fromARGB(255, 103, 103, 103)),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: Color.fromARGB(255, 103, 103, 103)),
                prefixIcon: Icon(Icons.person_outline, color: Color.fromARGB(255, 91, 144, 94)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green,)
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 210, 210, 210),
              ),
            ),
            const SizedBox(height: 15),

            // Email (read-only)
            TextField(
              controller: _emailController,
              readOnly: true,
              style: const TextStyle(color: Color.fromARGB(255, 103, 103, 103)),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Color.fromARGB(255, 103, 103, 103)),
                prefixIcon: const Icon(Icons.email_outlined, color: Color.fromARGB(255, 91, 144, 94)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 210, 210, 210),
              ),
            ),
            const SizedBox(height: 15),

            // Bio
            TextField(
              controller: _bioController,
              style: const TextStyle(color: Color.fromARGB(255, 103, 103, 103)),
              decoration: InputDecoration(
                labelText: 'Bio (optional)',
                labelStyle: const TextStyle(color: Color.fromARGB(255, 103, 103, 103)),
                prefixIcon: const Icon(Icons.info_outline, color: Color.fromARGB(255, 91, 144, 94)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                filled: true,
                fillColor: Color.fromARGB(255, 210, 210, 210),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 25),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 91, 144, 94),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}