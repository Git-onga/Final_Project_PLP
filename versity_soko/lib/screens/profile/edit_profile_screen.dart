import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';

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
  String? _profileImage;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadUserProfile();
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

  Future<void> uploadProfileImage({
      required BuildContext context,
      required File imageFile,
    }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not signed in");

      // ✅ Limit image size to 2MB
      final fileSize = imageFile.lengthSync();
      if (fileSize > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❗Please select an image smaller than 2 MB')),
        );
        return;
      }

      // ✅ Create unique file path
      final filePath = '${user.id}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // ✅ Upload to Supabase Storage
      await supabase.storage.from('avatars').upload(filePath, imageFile);

      // ✅ Get the public URL
      final imageUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

      // ✅ Update user profile record
      await supabase.from('profiles').update({
        'avatar_url': imageUrl,
      }).eq('id', user.id);

      // ✅ Also update auth user metadata
      await supabase.auth.updateUser(UserAttributes(
        data: {'avatar_url': imageUrl},
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile image uploaded successfully!')),
      );

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Upload failed: $error')),
      );
    }
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
      if (user == null) throw Exception('User not logged in.');

      // ✅ Upload image if user picked one
      if (_imageFile != null) {
        await uploadProfileImage(context: context, imageFile: _imageFile!);
      }

      // ✅ Update user metadata
      final updateResponse = await supabase.auth.updateUser(
        UserAttributes(
          data: {'name': newName, 'bio': newBio},
        ),
      );

      if (updateResponse.user == null) {
        throw Exception('Failed to update user profile');
      }

      // ✅ Update your profiles table (recommended)
      await supabase.from('profiles').upsert({
        'id': user.id,
        'name': newName,
        'bio': newBio,
        'updated_at': DateTime.now().toIso8601String(),
      });

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

  Future<void> _loadUserProfile() async{
    final authService = AuthService();
    final data = await authService.fetchUserProfile();

    setState(() {
      _profileImage = data?['avatar_url'] as String?;
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color.fromARGB(255, 241, 238, 246),
                    const Color.fromARGB(255, 225, 230, 244),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Label under the picture
                  const Text(
                    'Profile Picture',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 103, 103, 103),
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  // Profile Picture
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!) as ImageProvider
                              : NetworkImage('$_profileImage'),
                        ),

                        // Camera button
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 91, 144, 94),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(1, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Optional small instruction text (safe to remove)
                  Text(
                    'Tap the camera to update your picture',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container (
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: /*_isDarkMode
                      ? [
                          const Color(0xFF1E1A33), // deep indigo-black
                          const Color(0xFF2C254A), // dark lavender hue
                        ]
                      : */[
                          const Color.fromARGB(255, 241, 238, 246),
                          const Color.fromARGB(255, 225, 230, 244),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
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
                  
                  const SizedBox(height: 25),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF764BA2),
                            Color(0xFF667EEA) // soft teal green
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _saveProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ), 
      ),
    );
  }
}