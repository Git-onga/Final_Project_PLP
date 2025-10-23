import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _universityController;
  late TextEditingController _locationController;
  
  String? _selectedGender;
  DateTime? _selectedDate;
  String? _profileImageUrl;
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  final List<String> _universities = [
    'University of California, Berkeley',
    'Stanford University',
    'MIT',
    'Harvard University',
    'New York University',
    'University of Michigan',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = (authProvider.user ?? {}) as Map<String, dynamic>;

    _nameController = TextEditingController(text: user['name'] ?? '');
    _emailController = TextEditingController(text: user['email'] ?? '');
    _bioController = TextEditingController(text: user['bio'] ?? '');
    _phoneController = TextEditingController(text: user['phone'] ?? '');
    _universityController = TextEditingController(text: user['university'] ?? '');
    _locationController = TextEditingController(text: user['location'] ?? '');
    _selectedGender = user['gender'];
    _profileImageUrl = user['profileImage'];

    if (user['birthDate'] != null) {
      _selectedDate = DateTime.tryParse(user['birthDate']);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _profileImageUrl = image.path;
        });
        // In a real app, you would upload the image to your server here
        print('Selected image: ${image.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar('Failed to pick image');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      final phoneRegex = RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
      if (!phoneRegex.hasMatch(value)) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      final updatedUser = {
        'name': _nameController.text,
        'email': _emailController.text,
        'bio': _bioController.text,
        'phone': _phoneController.text,
        'university': _universityController.text,
        'location': _locationController.text,
        'gender': _selectedGender,
        'birthDate': _selectedDate?.toIso8601String(),
        'profileImage': _profileImageUrl,
      };

      // Update user in provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateUser(updatedUser);

      _showSnackBar('Profile updated successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Failed to update profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('Failed') ? Colors.red : Colors.green,
      ),
    );
  }

  void _showDiscardDialog() {
    if (_hasChanges()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Discard'),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
  }

  bool _hasChanges() {
    final user = (Provider.of<AuthProvider>(context, listen: false).user ?? {}) as Map<String, dynamic>;
    return _nameController.text != user['name'] ||
        _emailController.text != user['email'] ||
        _bioController.text != user['bio'] ||
        _phoneController.text != user['phone'] ||
        _universityController.text != user['university'] ||
        _locationController.text != user['location'] ||
        _selectedGender != user['gender'] ||
        _selectedDate?.toIso8601String() != user['birthDate'] ||
        _profileImageUrl != user['profileImage'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges()) {
          _showDiscardDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showDiscardDialog,
          ),
          actions: [
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: _saveProfile,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Profile Picture Section
                        _buildProfilePictureSection(),
                        const SizedBox(height: 24),
                        
                        // Personal Information
                        _buildSectionHeader('Personal Information'),
                        _buildNameField(),
                        _buildEmailField(),
                        _buildBioField(),
                        
                        // Contact Information
                        _buildSectionHeader('Contact Information'),
                        _buildPhoneField(),
                        _buildLocationField(),
                        
                        // Additional Information
                        _buildSectionHeader('Additional Information'),
                        _buildUniversityField(),
                        _buildGenderField(),
                        _buildBirthDateField(),
                        
                        const SizedBox(height: 32),
                        
                        // Action Buttons
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 3),
              ),
              child: ClipOval(
                child: _profileImageUrl != null
                    ? Image.network(
                        _profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 40, color: Colors.grey);
                        },
                      )
                    : const Icon(Icons.person, size: 40, color: Colors.grey),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  onPressed: _pickImage,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _pickImage,
          child: const Text('Change Profile Picture'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Full Name',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      validator: _validateName,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email Address',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
      ),
      validator: _validateEmail,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      decoration: const InputDecoration(
        labelText: 'Bio (Optional)',
        prefixIcon: Icon(Icons.info_outline),
        border: OutlineInputBorder(),
        hintText: 'Tell us about yourself...',
      ),
      maxLines: 3,
      maxLength: 150,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: const InputDecoration(
        labelText: 'Phone Number (Optional)',
        prefixIcon: Icon(Icons.phone_outlined),
        border: OutlineInputBorder(),
      ),
      validator: _validatePhone,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: 'Location (Optional)',
        prefixIcon: Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(),
        hintText: 'City, State',
      ),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildUniversityField() {
    return TextFormField(
      controller: _universityController,
      decoration: InputDecoration(
        labelText: 'University (Optional)',
        prefixIcon: const Icon(Icons.school_outlined),
        border: const OutlineInputBorder(),
        suffixIcon: PopupMenuButton<String>(
          icon: const Icon(Icons.arrow_drop_down),
          onSelected: (value) {
            setState(() {
              _universityController.text = value;
            });
          },
          itemBuilder: (BuildContext context) {
            return _universities.map((String university) {
              return PopupMenuItem<String>(
                value: university,
                child: Text(university),
              );
            }).toList();
          },
        ),
      ),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'Gender (Optional)',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      items: _genders.map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          _selectedGender = value;
        });
      },
      hint: const Text('Select Gender'),
    );
  }

  Widget _buildBirthDateField() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Birth Date (Optional)',
        prefixIcon: const Icon(Icons.cake_outlined),
        border: const OutlineInputBorder(),
        hintText: _selectedDate == null ? 'Select your birth date' : null,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: _selectDate,
        ),
      ),
      controller: TextEditingController(
        text: _selectedDate == null ? '' : 
          '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
      ),
      onTap: _selectDate,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _showDiscardDialog,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}