import 'package:flutter/material.dart';
import '../../screens/profile/edit_profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/database_service.dart';

final supabase = Supabase.instance.client;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
  
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? userBio;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadBio();
  }

  /// ✅ Fetch user data from Supabase profiles table
  Future<void> _loadUserProfile() async {
    final dbService = DatabaseService();

    try {
      final name = await dbService.loadName();

      if (name != null) {
        setState(() {
          userName = name['name'] as String?;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Failed to load profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadBio() async {
    final dbService = DatabaseService();

    try {
      final bio = await dbService.loadName();

      if (bio != null) {
        setState(() {
          userBio = bio['bio'] as String?;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Failed to load profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

@override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'logout':
                  _showLogoutDialog(context, /*authProvider*/);
                  break;
                case 'privacy':
                  // Navigate to privacy settings
                  break;
                case 'about':
                  // Navigate to about screen
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'privacy',
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Privacy & Security'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20),
                    SizedBox(width: 8),
                    Text('About App'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Profile Header Section
            _buildProfileHeader(/*user*/ context),
            
            // Stats Section
            _buildStatsSection(),
            
            // Menu Options
            _buildMenuOptions(context, /*authProvider*/),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final currentUser = supabase.auth.currentUser;
    final userEmail = currentUser?.email ?? 'Guest';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.purple, width: 3),
                ),
                child: ClipOval(
                  child:Image.network(
                    'https://picsum.photos/400/600?random=20',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 40, color: Colors.grey);
                    },
                  )
                // : const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userName ?? 'User Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
           '$userEmail',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          // if (bio != null && bio.isNotEmpty)
            Text(
              userBio ?? 'Write Something',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Following', '24'),
          _buildStatItem('Followers', '1.2k'),
          _buildStatItem('Reviews', '47'),
          _buildStatItem('Orders', '89'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          )
        )
      ]
    );
  }

  Widget _buildMenuOptions(BuildContext context, /*AuthProvider authProvider*/) {
    /*final dynamic user = authProvider.user;
    final university = user == null
        ? 'Not set'
        : (user is Map ? (user['university'] ?? 'Not set') : (user.university ?? 'Not set'));
    final location = user == null
        ? 'Not set'
        : (user is Map ? (user['location'] ?? 'Not set') : (user.location ?? 'Not set'));
    final phone = user == null
        ? 'Not set'
        : (user is Map ? (user['phone'] ?? 'Not set') : (user.phone ?? 'Not set'));
    */
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          _buildMenuTile(
            icon: Icons.school_outlined,
            title: 'University',
            subtitle: 'university',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.location_on_outlined,
            title: 'Location',
            subtitle: 'location',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.phone_outlined,
            title: 'Phone',
            subtitle: 'phone',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            subtitle: 'Track your purchases',
            onTap: () {
              // Navigate to orders screen
            },
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.favorite_outline,
            title: 'Wishlist',
            subtitle: 'Your saved items',
            onTap: () {
              // Navigate to wishlist screen
            },
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.store_outlined,
            title: 'Following Shops',
            subtitle: 'Manage followed shops',
            onTap: () {
              // Navigate to following shops screen
            },
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences',
            onTap: () {
              // Navigate to settings screen
            },
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'FAQs and contact',
            onTap: () {
              // Navigate to help screen
            },
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.shield_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
            onTap: () {
              // Navigate to privacy policy
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.green, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72, right: 16),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  void _showLogoutDialog(BuildContext context, /*AuthProvider authProvider*/) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // authProvider.logout();
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}