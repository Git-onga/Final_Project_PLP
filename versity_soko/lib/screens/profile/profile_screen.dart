import 'package:flutter/material.dart';
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
  bool _isLoading = true;
  String? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadBio();
  }

  /// ✅ Fetch user data from Supabase profiles table
  Future<void> _loadUserProfile() async {
    final dbService = DatabaseService();
    final authService = AuthService();

    try {
      final name = await dbService.loadName();
      final data = await authService.fetchUserProfile();


      if (name != null) {
        setState(() {
          userName = name['name'] as String?;
          _profileImage = data?['avatar_url'] as String?;
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

  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    // Add your theme switching logic here
    // e.g., Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false, // prevent default back button
        backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[50],
        elevation: 1,
        leading: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: _isDarkMode ? Colors.grey[50] : Colors.grey[900]), // menu icon on left
          onSelected: (value) {
            switch (value) {
              case 'logout':
                _showLogoutDialog(context);
                break;
              case 'privacy':
                // Navigate to privacy screen
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
            color: _isDarkMode ? Colors.grey[50] : Colors.grey[900],
          ),
        ),


        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward_outlined, color: _isDarkMode ? Colors.grey[50] : Colors.grey[900]),
            onPressed: () => Navigator.pop(context),
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
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: _isDarkMode
              ? [
                  const Color(0xFF1E1A33), // deep indigo-black
                  const Color(0xFF2C254A), // dark lavender hue
                ]
              : [
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
                    '$_profileImage',
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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.grey[50] : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
           '$userEmail',
            style: TextStyle(
              fontSize: 16,
              color: _isDarkMode ? Colors.grey[600] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Container(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
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
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
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
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors:  _isDarkMode
              ? [
                  const Color(0xFF1E1A33), // deep indigo-black
                  const Color(0xFF2C254A), // dark lavender hue
                ]
              : [
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Following', '24'),
          _buildStatItem('Events', '47'),
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.grey[50] : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _isDarkMode ? Colors.grey[600] : Colors.grey[700],
          )
        )
      ]
    );
  }

  Widget _buildMenuOptions(BuildContext context) {

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: _isDarkMode
              ? [
                  const Color(0xFF1E1A33), // deep indigo-black
                  const Color(0xFF2C254A), // dark lavender hue
                ]
              : [
                  const Color.fromARGB(255, 241, 238, 246),
                  const Color.fromARGB(255, 225, 230, 244),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
       
      ),
      child: Column(
        children: [
          // _buildMenuTile(
          //   icon: Icons.nightlight_outlined,
          //   title: 'University',
          //   subtitle: 'university',
          //   onTap: () {},
          // ),
          // _buildDivider(),
          themeToggleTile(
            isDarkMode: _isDarkMode,
            onToggle: _toggleTheme,
            showIcons: true,
          ),
        ],
      ),
    );
  }

  Widget themeToggleTile({
    required bool isDarkMode,
    required VoidCallback onToggle,
    bool showIcons = true,
  }) {
    final color =Colors.green;
    final bool _isToggled = isDarkMode;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isToggled
                  ? [Colors.green.shade100, Colors.green.shade50]
                  : [Color.fromARGB(255, 241, 238, 246), Color.fromARGB(255, 225, 230, 244)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isToggled ? Icons.wb_sunny : Icons.nightlight_outlined,
              color: color,
              size: 22,
              key: ValueKey(_isToggled),
            ),
          ),
        ),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: _isDarkMode ? Colors.grey[50] : Colors.grey[900],
          ),
          child: Text(
            _isToggled ? 'Dark Mode' : 'Light Mode',
          ),
        ),
        subtitle: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _isToggled
                ? 'Currently using dark theme'
                : 'Currently using light theme',
            style: TextStyle(
              color: _isDarkMode ? Colors.grey[600] : Colors.grey[700],
              fontSize: 12,
            ),
            key: ValueKey(_isToggled),
          ),
        ),
        trailing: _buildAnimatedToggle(_isToggled, onToggle, showIcons),
        onTap: onToggle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildAnimatedToggle(bool isToggled, VoidCallback onToggle, bool showIcons) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          width: 72,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: isToggled
                ? LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            
          ),
          child: Stack(
            children: [
              // Background icons
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isToggled ? 0 : 1,
                  child: Icon(
                    Icons.light_mode,
                    color: Colors.white.withOpacity(0.7),
                    size: 18,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isToggled ? 1 : 0,
                  child: Icon(
                    Icons.dark_mode,
                    color: Colors.white.withOpacity(0.7),
                    size: 18,
                  ),
                ),
              ),
              // Toggle knob
              AnimatedAlign(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutBack,
                alignment: isToggled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: showIcons
                      ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isToggled ? Icons.nightlight_round : Icons.wb_sunny,
                            color: isToggled ? Colors.green : Colors.grey,
                            size: 18,
                            key: ValueKey(isToggled),
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildMenuTile({
  //   required IconData icon,
  //   required String title,
  //   required String subtitle,
  //   required VoidCallback onTap,
  // }) {
  //   return ListTile(
  //     leading: Container(
  //       width: 40,
  //       height: 40,
  //       decoration: BoxDecoration(
  //         color: Colors.green.withOpacity(0.1),
  //         shape: BoxShape.circle,
  //       ),
  //       child: Icon(icon, color: Colors.green, size: 20),
  //     ),
  //     title: Text(
  //       title,
  //       style: const TextStyle(
  //         fontWeight: FontWeight.w500,
  //         fontSize: 16,
  //       ),
  //     ),
  //     subtitle: Text(
  //       subtitle,
  //       style: TextStyle(
  //         color: Colors.grey[600],
  //         fontSize: 12,
  //       ),
  //     ),
  //     trailing: const Icon(Icons.chevron_right, color: Colors.grey),
  //     onTap: onTap,
  //   );
  // }

  // Widget _buildDivider() {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 72, right: 16),
  //     child: Divider(height: 1, color: Colors.grey[200]),
  //   );
  // }

  void _showLogoutDialog(BuildContext context,) {
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