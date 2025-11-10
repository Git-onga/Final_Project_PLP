import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {

  final supabase = Supabase.instance.client;
  bool hasShop = false;
  bool isLoading = true;
    bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _checkIfUserHasShop();
  }

  Future<void> _checkIfUserHasShop() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
        hasShop = false;
      });
      return;
    }

    final response = await supabase
        .from('shops')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();

    setState(() {
      hasShop = response != null;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C254A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2C254A) : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.group,
                activeIcon: Icons.group,
                label: 'Hub',
                index: 1,
              ),
              
              _buildNavItem(
                icon: hasShop
                  ? Icons.storefront_outlined
                  : Icons.add_circle_outline,
                activeIcon:  hasShop ? Icons.storefront : Icons.add_circle,
                label: hasShop ? 'Kyosk' : 'Create',
                index: 2,
                isCenter: true,
              ),
              _buildNavItem(
                icon: Icons.store,
                activeIcon: Icons.store,
                label: 'Shop',
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.message,
                activeIcon: Icons.message,
                label: 'Messo',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool isCenter = false,
  }) {
    final isActive = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: isCenter
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: isDark ?  [Color.fromARGB(255, 213, 196, 242), Color.fromARGB(255, 193, 207, 248)] : [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            )
          : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isCenter
                  ? (isDark ? const Color(0xFF2C254A) : Colors.white)
                  : (isActive
                      ? (isDark ? Colors.blue[300] : Colors.blue[700])
                      : (isDark ? Colors.grey[300] : Colors.grey[600])),
              size: isCenter ? 24 : 22,
            ),

            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isCenter
                  ? (isDark ? const Color(0xFF2C254A) : Colors.white)
                  : (isActive
                      ? (isDark ? Colors.blue[300] : Colors.blue[700])
                      : (isDark ? Colors.grey[300] : Colors.grey[600])),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
