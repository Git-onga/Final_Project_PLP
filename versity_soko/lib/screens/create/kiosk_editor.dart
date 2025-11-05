import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../create/shop_redirector.dart';
import '../../models/shop_model.dart';
import 'dart:io';
import '../../services/showcase_service.dart';
import '../../services/shop_profile_service.dart';


class ShopProfileEditor extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController categoryController;
  final TextEditingController emailController;
  final TextEditingController imageUrlController;
  final VoidCallback? onImageChanged;
  final String shopId;
  final VoidCallback? onProfileUpdated;
  

  const ShopProfileEditor({
    super.key,
    required this.nameController,
    required this.categoryController,
    required this.emailController,
    required this.imageUrlController,
    this.onImageChanged,
    this.onProfileUpdated,
    required this.shopId,
  });

  @override
  State<ShopProfileEditor> createState() => _ShopProfileEditorState();
}

class _ShopProfileEditorState extends State<ShopProfileEditor> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _categoryFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final shopService = ShopProfileService();
  final shopIdClass = ShopHelper();
  ShopModel? shopDetails; // holds fetched shop details
  // Fetch shop profile

  @override
  void initState() {
    super.initState();
    // Add focus listeners to trigger UI updates
    _nameFocusNode.addListener(() => setState(() {}));
    _categoryFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
  }
  

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _categoryFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadImage(image);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (photo != null) {
        await _uploadImage(photo);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  Future<void> _uploadImage(XFile file) async {
    if (!mounted) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Generate unique file name
      final String fileName = 'shop_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload to Supabase storage
      final String imageUrl = await _uploadToSupabaseStorage(file, fileName);
      
      if (mounted) {
        setState(() {
          widget.imageUrlController.text = imageUrl;
        });
        
        // Notify parent about image change
        widget.onImageChanged?.call();
        
        _showSuccessSnackBar('Image uploaded successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to upload image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<String?> _shopId() async {
    final shopId = await shopIdClass.getCurrentShopId();
    return shopId;
  }

  Future<void> fetchCurrentShopDetails() async {
    try {
      final shopId = await _shopId();

      if (shopId == null || shopId.isEmpty) {
        shopDetails = null;
        setState(() {});
        return;
      }

      final shopData = await shopService.fetchShopProfile(shopId);

      if (shopData != null) {
        setState(() {
          shopDetails = ShopModel.fromJson(shopData);
        });
      } else {
        setState(() => shopDetails = null);
      }
    } catch (e) {
      setState(() => shopDetails = null);
    }
  }

  Future<String> _uploadToSupabaseStorage(XFile file, String shopId) async {
    // Convert XFile to File
    final File imageFile = File(file.path);

    // Use the improved uploadProfileImage function
    final publicUrl = await shopService.uploadProfileImage(
    imageFile: imageFile,
    shopId: shopId,
    );

    if (publicUrl == null) {
    throw Exception('❌ Failed to upload image to Supabase.');
    }

    return publicUrl;
  }

  Future<void> _saveShopProfile() async {
    try {
      // Get current shop ID 
      final shopId = await shopIdClass.getCurrentShopId();

      if (shopId == null) {
        throw Exception('Shop ID not found');
      }

      // Update profile using service
      final success = await shopService.updateShopProfile(
        shopId: shopId,
        name: widget.nameController.text.trim(),
        category: widget.categoryController.text.trim(), // Using category as description
        profileImageUrl: widget.imageUrlController.text.trim(),
      );

      if (success) {
        if (mounted) {
          widget.onProfileUpdated?.call();

          Navigator.pop(context);
        }
         // ✅ Trigger the callback to notify parent
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                'Choose Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.3))],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      title: 'Gallery',
                      color: Colors.blue.shade100,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      title: 'Camera',
                      color: Colors.green.shade100,
                      onTap: () {
                        Navigator.pop(context);
                        _takePhoto();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.blue.shade800),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  InputDecoration _buildGradientInputDecoration({
    required String labelText,
    required IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: const Color(0xFF4CAF50),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefixIcon! != null ? Icon(prefixIcon) : null,
      prefixIconColor: Colors.green,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      filled: true,
      fillColor:  const Color.fromARGB(255, 210, 210, 210),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
    );
      
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shop Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ---- Shop Image Section ----
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromARGB(255, 241, 238, 246),
                    Color.fromARGB(255, 225, 230, 244),
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
                  const Text(
                    'Shop Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 103, 103, 103),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: widget.imageUrlController.text.isNotEmpty
                            ? NetworkImage(widget.imageUrlController.text)
                            : null,
                        child: widget.imageUrlController.text.isEmpty
                            ? const Icon(Icons.store, size: 50, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: _isUploading ? null : _showImageSourceDialog,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667EEA),
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
                  const SizedBox(height: 12),
                  Text(
                    'Tap the camera to upload your shop logo',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ---- Shop Details Section ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromARGB(255, 241, 238, 246),
                    Color.fromARGB(255, 225, 230, 244),
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
                    controller: widget.nameController,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 103, 103, 103)),
                    decoration: _buildGradientInputDecoration(
                      labelText: 'Shop Name',
                      prefixIcon: Icons.store,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: widget.categoryController,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 103, 103, 103)),
                    decoration: _buildGradientInputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icons.category_outlined,
                      
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: widget.emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 103, 103, 103)),
                    decoration: _buildGradientInputDecoration(
                      labelText: 'Business Email',
                      prefixIcon: Icons.email_outlined,
                      
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ---- Save Button ----
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
                      Color(0xFF667EEA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _saveShopProfile();
                   
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Save Shop Profile',
                    style: TextStyle(fontWeight: FontWeight.bold),
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



class BusinessHoursEditor extends StatefulWidget {
  final String shopId;
  final VoidCallback? onProfileUpdated;

  const BusinessHoursEditor({
    super.key,
    this.onProfileUpdated,
    required this.shopId,
  });
  
  
  @override
  State<BusinessHoursEditor> createState() => _BusinessHoursEditorState();
}

class _BusinessHoursEditorState extends State<BusinessHoursEditor> {
  TimeOfDay _openingTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 18, minute: 0);
  final Map<String, bool> _daysOpen = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': false,
    'Sunday': false,
  };

  Future<void> _pickTime(bool isOpening) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? _openingTime : _closingTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667EEA),
              secondary: Color(0xFF764BA2),
              onPrimary: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
      });
    }
  }

  Widget _buildTimePickerCard(String title, TimeOfDay time, bool isOpening) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF667EEA).withOpacity(0.1),
              const Color(0xFF764BA2).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF667EEA).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _pickTime(isOpening),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF667EEA),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                elevation: 2,
                shadowColor: const Color(0xFF667EEA).withOpacity(0.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOpening ? Icons.sunny : Icons.nightlight_round,
                    size: 18,
                    color: const Color(0xFF667EEA),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time.format(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildDayToggle(String day, bool isOpen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isOpen 
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isOpen ? Icons.check_circle : Icons.circle_outlined,
            color: isOpen ? const Color(0xFF4CAF50) : Colors.grey,
            size: 20,
          ),
        ),
        title: Text(
          day,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          isOpen ? 'Open' : 'Closed',
          style: TextStyle(
            color: isOpen ? const Color(0xFF4CAF50) : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Switch(
          value: isOpen,
          onChanged: (value) {
            setState(() {
              _daysOpen[day] = value;
            });
          },
          activeColor: const Color(0xFF4CAF50),
          activeTrackColor: const Color(0xFF4CAF50).withOpacity(0.3),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar( 
      title: const Text( 
        'Shop Profile', 
        style: TextStyle(
          fontWeight: FontWeight.bold), 
        ), 
      centerTitle: true, 
      backgroundColor: Colors.white, 
      foregroundColor: Colors.black, 
      elevation: 0, 
    ), 
    backgroundColor: Colors.white,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
          const SizedBox(height: 30), // space for FAB
          // ---- Operating Hours Card ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.fromARGB(255, 241, 238, 246),
                  Color.fromARGB(255, 225, 230, 244),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667EEA).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.schedule,
                        size: 20,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Daily Operating Hours',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildTimePickerCard('Opening Time', _openingTime, true),
                    const SizedBox(width: 16),
                    _buildTimePickerCard('Closing Time', _closingTime, false),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 20, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your shop will be open from ${_openingTime.format(context)} to ${_closingTime.format(context)} on selected days',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ---- Open Days Card ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.fromARGB(255, 241, 238, 246),
                  Color.fromARGB(255, 225, 230, 244),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF764BA2).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Color(0xFF764BA2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Open Days',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._daysOpen.entries
                    .map((entry) => _buildDayToggle(entry.key, entry.value))
                    .toList(),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ---- Save Button ----
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF764BA2), Color(0xFF667EEA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                    // Handle save action
                    // Keep original _daysOpen map since it's already in the correct format
                    try {
                    final shopService = ShopProfileService();
                    final shopHelper = ShopHelper();
                    
                    // Get current shop ID
                    final shopId = await shopHelper.getCurrentShopId();
                    
                    if (shopId != null) {
                      await shopService.updateShopBusinessHrs(
                      shopId: shopId,
                      openingTime: TimeOfDay(hour: _openingTime.hour, minute: _openingTime.minute),
                      closingTime: TimeOfDay(hour: _closingTime.hour, minute: _closingTime.minute),
                      openDays: _daysOpen,
                      );
                      
                      if (mounted) {
                      widget.onProfileUpdated?.call();
                      Navigator.pop(context);
                      }
                    }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                        content: Text('Failed to update business hours: $e'),
                        backgroundColor: Colors.red,
                        ),
                      );
                    }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'Save Business Hours',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),

);
}

}

class PaymentMethodsSelector extends StatefulWidget {
  final String shopId;
  final VoidCallback? onProfileUpdated;

  const PaymentMethodsSelector({
    super.key,
    this.onProfileUpdated,
    required this.shopId,
  });

  @override
  State<PaymentMethodsSelector> createState() => _PaymentMethodsSelectorState();
}

class _PaymentMethodsSelectorState extends State<PaymentMethodsSelector> {
  String? _selectedMethod;
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _paybillNumberController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _pochiNumberController = TextEditingController();

  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _paybillFocusNode = FocusNode();
  final FocusNode _accountFocusNode = FocusNode();
  final FocusNode _pochiFocusNode = FocusNode();

  

  @override
  void initState() {
    super.initState();
    _mobileFocusNode.addListener(() => setState(() {}));
    _paybillFocusNode.addListener(() => setState(() {}));
    _accountFocusNode.addListener(() => setState(() {}));
    _pochiFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _paybillNumberController.dispose();
    _accountNumberController.dispose();
    _pochiNumberController.dispose();
    _mobileFocusNode.dispose();
    _paybillFocusNode.dispose();
    _accountFocusNode.dispose();
    _pochiFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _buildGradientInputDecoration({
    required String labelText,
    required String hintText,
    required bool hasFocus,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(
        color: hasFocus ? const Color(0xFF4CAF50) : Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(color: Colors.grey.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 60),
    );
  }

  Widget _buildPaymentMethodCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedMethod == value 
              ? const Color(0xFF4CAF50) 
              : Colors.grey.shade200,
          width: _selectedMethod == value ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: RadioListTile<String>(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        value: value,
        groupValue: _selectedMethod,
        onChanged: (value) => setState(() => _selectedMethod = value),
        activeColor: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildMpesaSendMoneyFields() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00A650).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00A650).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone_android, color: const Color(0xFF00A650), size: 18),
              const SizedBox(width: 8),
              Text(
                'M-Pesa Mobile Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mobileNumberController,
            focusNode: _mobileFocusNode,
            keyboardType: TextInputType.phone,
            decoration: _buildGradientInputDecoration(
              labelText: 'Mobile Number *',
              hintText: '07XX XXX XXX',
              hasFocus: _mobileFocusNode.hasFocus,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  '+254',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaybillFields() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF667EEA).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: const Color(0xFF667EEA), size: 18),
              const SizedBox(width: 8),
              Text(
                'Paybill Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _paybillNumberController,
            focusNode: _paybillFocusNode,
            keyboardType: TextInputType.number,
            decoration: _buildGradientInputDecoration(
              labelText: 'Paybill Number *',
              hintText: 'Enter paybill number',
              hasFocus: _paybillFocusNode.hasFocus,
              prefixIcon: Icon(Icons.numbers, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _accountNumberController,
            focusNode: _accountFocusNode,
            keyboardType: TextInputType.text,
            decoration: _buildGradientInputDecoration(
              labelText: 'Account Number *',
              hintText: 'Enter account number',
              hasFocus: _accountFocusNode.hasFocus,
              prefixIcon: Icon(Icons.person, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPochiFields() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF764BA2).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF764BA2).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: const Color(0xFF764BA2), size: 18),
              const SizedBox(width: 8),
              Text(
                'Pochi la Biashara',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pochiNumberController,
            focusNode: _pochiFocusNode,
            keyboardType: TextInputType.phone,
            decoration: _buildGradientInputDecoration(
              labelText: 'Pochi Number *',
              hintText: 'Enter Pochi number',
              hasFocus: _pochiFocusNode.hasFocus,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  '+254',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateForm() {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a payment method'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return false;
    }

    if (_selectedMethod == 'mpesa_send' && _mobileNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your mobile number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return false;
    }

    if (_selectedMethod == 'paybill' && 
        (_paybillNumberController.text.isEmpty || _accountNumberController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter both paybill and account numbers'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return false;
    }

    if (_selectedMethod == 'pochi' && _pochiNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your Pochi number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _savePaymentMethod() async {
    if (_validateForm()) {
      // Save the payment method
      try {
        final shopHelper = ShopHelper();
        final shopService = ShopProfileService();
        
        // Get current shop ID
        final shopId = await shopHelper.getCurrentShopId();
        
        if (shopId == null) {
          throw Exception('Shop ID not found');
        }

        // Create payment details map based on selected method
        Map<String, dynamic> paymentDetails = {
          'method': _selectedMethod,
        };

        // Add specific details based on payment method
        switch (_selectedMethod) {
          case 'mpesa_send':
            paymentDetails['mobile_number'] = _mobileNumberController.text.trim();
            break;
          case 'paybill':
            paymentDetails['paybill_number'] = _paybillNumberController.text.trim();
            paymentDetails['account_number'] = _accountNumberController.text.trim();
            break;
          case 'pochi':
            paymentDetails['pochi_number'] = _pochiNumberController.text.trim();
            break;
        }

        // Update payment method using service
        final success = await shopService.updatePaymentMethod(
          shopId: shopId,
          paymentDetails: paymentDetails,
        );

        if (success) {
          if (mounted) {
            widget.onProfileUpdated?.call();
            Navigator.pop(context);
          }
        } else {
          throw Exception('Failed to update payment method');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
        content: Text('Error saving payment method: $e'),
        backgroundColor: Colors.red,
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Payment method saved successfully'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
      title: const Text( 
        'Shop Profile', 
        style: TextStyle(
          fontWeight: FontWeight.bold), 
        ), 
      centerTitle: true, 
      backgroundColor: Colors.white, 
      foregroundColor: Colors.black, 
      elevation: 0, 
    ), 
    backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 60), // Space for back button
              
              // Header with Gradient
              
              
              // Payment Methods Selection
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF667EEA).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            size: 20,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentMethodCard(
                      'M-Pesa Send Money',
                      'mpesa_send',
                      Icons.phone_android,
                      const Color(0xFF00A650),
                    ),
                    _buildPaymentMethodCard(
                      'Pochi la Biashara',
                      'pochi',
                      Icons.account_balance_wallet,
                      const Color(0xFF764BA2),
                    ),
                    _buildPaymentMethodCard(
                      'Paybill',
                      'paybill',
                      Icons.receipt_long,
                      const Color(0xFF667EEA),
                    ),
                  ],
                ),
              ),
              
              // Conditional Input Fields
              if (_selectedMethod != null) ...[
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _selectedMethod == 'mpesa_send'
                      ? _buildMpesaSendMoneyFields()
                      : _selectedMethod == 'paybill'
                          ? _buildPaybillFields()
                          : _selectedMethod == 'pochi'
                              ? _buildPochiFields()
                              : const SizedBox.shrink(),
                ),
              ],
              
              const SizedBox(height: 30),
              
              // Save Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _savePaymentMethod,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePreviewScreen extends StatefulWidget {
  final File imageFile;

  const ImagePreviewScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final ShowcaseService _showcaseService = ShowcaseService();

  bool _isUploading = false;

  Future<void> _uploadShowcase() async {
    setState(() => _isUploading = true);

    try {
      final caption = _captionController.text.trim();
      final priceText = _priceController.text.trim();

      // Optional price formatting
      final price = priceText.isNotEmpty ? 'KSh $priceText' : null;
      final fullCaption = price != null ? '$caption • $price' : caption;


      final showcase = await _showcaseService.uploadShowcase(
        imageFile: widget.imageFile,
        caption: fullCaption,
        expiresAt: DateTime.now().add(const Duration(days: 3)), // Example: 3 days expiry
      );

      if (showcase != null) {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text('Failed to set Showcase: $e'),
          backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Preview & Caption'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[400]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[50]!, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Image Preview Section
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: Image.file(
                  widget.imageFile,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Input and Button Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Caption Input
                  TextField(
                    controller: _captionController,
                    decoration: InputDecoration(
                      labelText: 'Caption or Description',
                      prefixIcon: const Icon(Icons.text_fields, color: Colors.purple),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                    cursorColor: Colors.green, // active typing color
                    maxLines: 2
                  ),
                  const SizedBox(height: 12),

                  // Price Input
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price (optional)',
                      prefixIcon: const Icon(Icons.monetization_on_sharp, color: Colors.purple),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                    cursorColor: Colors.green, // active typing color
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _uploadShowcase,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(
                        _isUploading ? 'Uploading...' : 'Post',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.purple[400],
                        elevation: 3,
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
