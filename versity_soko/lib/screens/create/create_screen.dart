import 'package:flutter/material.dart';
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
  
  String name = '', desc = '', category = '', email = '', phone = '';
  bool delivery = false;
  bool isLoading = false;

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

      // Navigate to kiosk
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

  bool _isToggled = false;
  String? _selectedCategory;
  
  final List<String> _categories = [
    'Food & Drinks',
    'Cloth Store',
    'Service Provider',
    'Accessories',
    'Turtor',
    'Technology',
    'Other'
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Set Up Your Shop',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            _buildTitleSection(),
            
            const SizedBox(height: 20),
            
            // Business Information Section
            _buildBusinessInfoSection(),
            
            const SizedBox(height: 32),
            
            // Operation Contacts Section
            _buildOperationContactsSection(),
            
            const SizedBox(height: 32),
            
            // Visual Presentation Section
            _buildVisualPresentationSection(),
            
            const SizedBox(height: 40),
            
            // Create Profile Button
            _buildCreateProfileButton(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Title Section
  Widget _buildTitleSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Create Your Business Profile',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Provide essential details to get your shop up and running. This information will be visible to your customers.',
        ),
      ],
    );
  }

  // Business Information Section
  Widget _buildBusinessInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 212, 210, 210), width: .5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          _buildSectionHeader('Business Information'),
          const SizedBox(height: 15),
          
          // Logo
          _buildLogoSection(),
          const SizedBox(height: 15),
          
          // Business Name
          _buildFormFieldTitle('Name'),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _businessNameController,
            hintText: 'Enter your business name',
            prefixIcon: Icons.business,
          ),
          const SizedBox(height: 15),
          
          // Business Description
          _buildFormFieldTitle('Business Description'),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _descriptionController,
            hintText: 'Tell your customers about your business',
            prefixIcon: Icons.description,
          ),
          const SizedBox(height: 15),
          
          // Business Category
          _buildFormFieldTitle('Business Category'),
          const SizedBox(height: 10),
          _buildCategoryDropdown(),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // Operation Contacts Section
  Widget _buildOperationContactsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 212, 210, 210), width: .5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          _buildSectionHeader('Operation Contacts'),
          const SizedBox(height: 15),
          
          // Email Handle
          _buildFormFieldTitle('Email Handle'),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _emailController,
            hintText: 'Enter your email address',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          
          // Phone Number
          _buildFormFieldTitle('Phone Number'),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _phoneController,
            hintText: 'Enter your phone number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
          
          // Delivery Toggle
          _buildDeliveryToggleSection(),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // Visual Presentation Section
  Widget _buildVisualPresentationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormFieldTitle('Visual Presentation'),
        const SizedBox(height: 16),
        _buildImageUploadSection(),
      ],
    );
  }

  // Individual Component Methods
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 1,
          width: double.infinity,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildFormFieldTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
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
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 30,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 8),
            const Text(
              'Logo',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Add logo, storefront, or Shop brand',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: 'Select your business category',
        ),
        items: _categories.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        isExpanded: true,
      ),
    );
  }

  Widget _buildDeliveryToggleSection() {
    return Row(
      children: [
        _buildFormFieldTitle('Delivery'),
        const Spacer(),
        _buildToggleButton(),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 40,
                color: Colors.grey[500],
              ),
              const SizedBox(height: 8),
              Text(
                'Upload Business Images',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add logo, storefront, or product photos',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSmallImagePlaceholder(),
            const SizedBox(width: 8),
            _buildSmallImagePlaceholder(),
            const SizedBox(width: 8),
            _buildSmallImagePlaceholder(),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isToggled = !_isToggled;
        });
      },
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
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.add,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildCreateProfileButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Create Business Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _createBusinessProfile() {
    // Validate form data
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
    
    // Process the business profile creation
    final businessData = {
      'name': _businessNameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'category': _selectedCategory,
      'delivery': _isToggled,
    };
    
    print('Business Profile Created: $businessData');
    
    // Navigate to KioskScreen
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const KioskScreen())
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}