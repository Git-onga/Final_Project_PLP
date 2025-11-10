import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:versity_soko/screens/create/kiosk_screen.dart';
import '../../providers/shop_provider.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateBusinessScreen();
}

class _CreateBusinessScreen extends State<CreateScreen> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _provider = ShopProvider();
  final SupabaseClient database = Supabase.instance.client;

  bool _isToggled = false;
  String? _selectedCategory;
  bool isLoading = false;

  final List<String> _categories = [
    'Food & Drinks',
    'Cloth Store',
    'Service Provider',
    'Accessories',
    'Tutor',
    'Technology',
    'Other'
  ];

  void _handleSubmit() async {
    if (_businessNameController.text.isEmpty) {
      _showSnackBar('Please enter your business name');
      return;
    }
    if (_phoneController.text.isEmpty) {
      _showSnackBar('Please enter your phone number');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showSnackBar('Please enter your email address');
      return;
    }
    if (_selectedCategory == null) {
      _showSnackBar('Please select a business category');
      return;
    }

    setState(() => isLoading = true);

    try {
      await _provider.createShop(
        name: _businessNameController.text,
        description: _descriptionController.text,
        category: _selectedCategory!,
        email: _emailController.text,
        phone: _phoneController.text,
        delivery: _isToggled,
      );

      _showSnackBar("✅ Shop created successfully");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KioskScreen()),
      );
    } catch (e) {
      _showSnackBar("❌ Error creating shop: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Gradient Background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF1E1A33), Color(0xFF2C254A)]
                : const [Color.fromARGB(255, 241, 238, 246), Color.fromARGB(255, 225, 230, 244)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(isDark),
                const SizedBox(height: 20),
                _buildTitleSection(),
                const SizedBox(height: 20),
                _buildBusinessInfoSection(isDark),
                const SizedBox(height: 32),
                _buildOperationContactsSection(isDark),
                const SizedBox(height: 32),
                _buildVisualPresentationSection(isDark),
                const SizedBox(height: 40),
                _buildCreateProfileButton(isDark),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Components ----------------

  Widget _buildAppBar(bool isDark) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Set Up Your Shop',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48), // Placeholder for alignment
      ],
    );
  }

  Widget _buildTitleSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Create Your Business Profile',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        Text(
          'Provide essential details to get your shop up and running. This information will be visible to your customers.',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildBusinessInfoSection(bool isDark) {
    return _buildSectionContainer(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          _buildSectionHeader('Business Information', isDark),
          const SizedBox(height: 15),
          _buildLogoSection(),
          const SizedBox(height: 15),
          _buildFormFieldTitle('Name', isDark),
          const SizedBox(height: 10),
          _buildTextField(_businessNameController, 'Enter your business name', Icons.business, isDark),
          const SizedBox(height: 15),
          _buildFormFieldTitle('Business Description', isDark),
          const SizedBox(height: 10),
          _buildTextField(_descriptionController, 'Tell your customers about your business', Icons.description, isDark),
          const SizedBox(height: 15),
          _buildFormFieldTitle('Business Category', isDark),
          const SizedBox(height: 10),
          _buildCategoryDropdown(isDark),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildOperationContactsSection(bool isDark) {
    return _buildSectionContainer(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          _buildSectionHeader('Operation Contacts', isDark),
          const SizedBox(height: 15),
          _buildFormFieldTitle('Email Handle', isDark),
          const SizedBox(height: 10),
          _buildTextField(_emailController, 'Enter your email address', Icons.email, isDark, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 15),
          _buildFormFieldTitle('Phone Number', isDark),
          const SizedBox(height: 10),
          _buildTextField(_phoneController, 'Enter your phone number', Icons.phone, isDark, keyboardType: TextInputType.phone),
          const SizedBox(height: 15),
          _buildDeliveryToggleSection(isDark),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildVisualPresentationSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormFieldTitle('Visual Presentation', isDark),
        const SizedBox(height: 16),
        _buildImageUploadSection(isDark),
      ],
    );
  }

  Widget _buildSectionContainer(bool isDark, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C254A) : Colors.white,
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!, width: .5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 10),
        Container(height: 1, width: double.infinity, color: isDark ? Colors.grey[600] : Colors.grey[400]),
      ],
    );
  }

  Widget _buildFormFieldTitle(String title, bool isDark) {
    return Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87));
  }

  Widget _buildLogoSection() {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(75),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 30, color: Colors.grey[500]),
            const SizedBox(height: 8),
            const Text('Logo', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Add logo, storefront, or Shop brand',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3559) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
        items: _categories.map((value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
        onChanged: (value) => setState(() => _selectedCategory = value),
        icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.grey),
        isExpanded: true,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, bool isDark, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue, width: 2)),
        filled: true,
        fillColor: isDark ? const Color(0xFF3A3559) : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
    );
  }

  Widget _buildDeliveryToggleSection(bool isDark) {
    return Row(
      children: [
        _buildFormFieldTitle('Delivery', isDark),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _isToggled = !_isToggled),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 70,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: _isToggled ? Colors.green : Colors.grey,
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              alignment: _isToggled ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3, offset: const Offset(0, 2))]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection(bool isDark) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF3A3559) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 40, color: isDark ? Colors.white70 : Colors.grey[500]),
              const SizedBox(height: 8),
              Text('Upload Business Images', style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 4),
              Text('Add logo, storefront, or product photos', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[500], fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateProfileButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.deepPurpleAccent : Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: const Text('Create Business Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
