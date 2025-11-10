import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:versity_soko/providers/theme_provider.dart';
import '../../screens/profile/edit_profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';

final supabase = Supabase.instance.client;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? userBio;
  String? _profileImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadBio();
  }

  Future<void> _loadUserProfile() async {
    final dbService = DatabaseService();
    final authService = AuthService();

    try {
      final name = await dbService.loadName();
      final data = await authService.fetchUserProfile();

      setState(() {
        userName = name?['name'] as String?;
        _profileImage = data?['avatar_url'] as String?;
        _isLoading = false;
      });
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
      setState(() {
        userBio = bio?['bio'] as String?;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Failed to load bio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleTheme() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme(!themeProvider.isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        elevation: 1,
        leading: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert,
              color: isDarkMode ? Colors.grey[50] : Colors.grey[900]),
          onSelected: (value) {
            switch (value) {
              case 'logout':
                _showLogoutDialog(context);
                break;
              case 'privacy':
              case 'about':
                break;
            }
          },
          itemBuilder: (context) => [
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
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.grey[50] : Colors.grey[900],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward_outlined,
                color: isDarkMode ? Colors.grey[50] : Colors.grey[900]),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(context, isDarkMode),
            _buildStatsSection(isDarkMode),
            _buildMenuOptions(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDarkMode) {
    final userEmail = supabase.auth.currentUser?.email ?? 'Guest';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDarkMode
              ? [const Color(0xFF1E1A33), const Color(0xFF2C254A)]
              : [const Color.fromARGB(255, 241, 238, 246), const Color.fromARGB(255, 225, 230, 244)],
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
                  child: _profileImage != null
                      ? Image.network(_profileImage!, fit: BoxFit.cover)
                      : const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userName ?? 'User Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[50] : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF764BA2), Color(0xFF667EEA)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDarkMode
              ? [const Color(0xFF1E1A33), const Color(0xFF2C254A)]
              : [const Color.fromARGB(255, 241, 238, 246), const Color.fromARGB(255, 225, 230, 244)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [_buildStatItem('Following', '24', isDarkMode), _buildStatItem('Events', '47', isDarkMode), _buildStatItem('Orders', '89', isDarkMode)],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDarkMode) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.grey[50] : Colors.grey[900])),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[600] : Colors.grey[700])),
      ],
    );
  }

  Widget _buildMenuOptions(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDarkMode
              ? [const Color(0xFF1E1A33), const Color(0xFF2C254A)]
              : [const Color.fromARGB(255, 241, 238, 246), const Color.fromARGB(255, 225, 230, 244)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          themeToggleTile(isDarkMode: isDarkMode, onToggle: _toggleTheme),
        ],
      ),
    );
  }

  Widget themeToggleTile({required bool isDarkMode, required VoidCallback onToggle}) {
    final _isToggled = isDarkMode;

    return ListTile(
      leading: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isToggled ? [Colors.green.shade100, Colors.green.shade50] : [Colors.grey.shade300, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(_isToggled ? Icons.wb_sunny : Icons.nightlight_outlined, color: Colors.green, key: ValueKey(_isToggled)),
        ),
      ),
      title: Text(_isToggled ? 'Dark Mode' : 'Light Mode', style: TextStyle(fontWeight: FontWeight.w600, color: isDarkMode ? Colors.grey[50] : Colors.grey[900])),
      subtitle: Text(_isToggled ? 'Currently using dark theme' : 'Currently using light theme', style: TextStyle(color: isDarkMode ? Colors.grey[600] : Colors.grey[700], fontSize: 12)),
      trailing: _buildAnimatedToggle(_isToggled, onToggle),
      onTap: onToggle,
    );
  }

  Widget _buildAnimatedToggle(bool isToggled, VoidCallback onToggle) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        width: 72,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: isToggled
              ? LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600])
              : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600]),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              alignment: isToggled ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(isToggled ? Icons.nightlight_round : Icons.wb_sunny, color: isToggled ? Colors.green : Colors.grey, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
