import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/create/create_screen.dart';
import '../screens/community/community_screen.dart';
import '../screens/message/message_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart'; // <— your custom nav bar

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CommunityScreen(),
    CreateScreen(),
    ShopScreen(shopId: '',),
    MessageScreen(),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}
