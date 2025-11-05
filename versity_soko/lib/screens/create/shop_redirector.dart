import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../create/create_screen.dart';
import '../create/kiosk_screen.dart';
import 'package:shimmer/shimmer.dart';

class ShopRedirector extends StatefulWidget {
  const ShopRedirector({Key? key}) : super(key: key);

  @override
  State<ShopRedirector> createState() => _ShopRedirectorState();
}

class _ShopRedirectorState extends State<ShopRedirector> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _hasShop = false;


  @override
  void initState() {
    super.initState();
    _checkIfUserHasShop();
  }

  Future<void> _checkIfUserHasShop() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      // If user is not logged in, redirect to login or show message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must be logged in to continue")),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await supabase
          .from('shops')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      setState(() {
        _hasShop = response != null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Helper method to get the current shop ID - you need to implement this based on your app's logic
  

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: _buildShimmerLoader());
    }

    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 300)), // short extra buffer
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(body: _buildShimmerLoader());
        }
        return _hasShop ? const KioskScreen() : const CreateScreen();
      },
    );
  }

  Widget _buildShimmerLoader() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Placeholder for shop logo/avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                const SizedBox(height: 16),

                // Placeholder for shop name
                Container(
                  width: 140,
                  height: 20,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 10),

                // Placeholder for subtitle/info text
                Container(
                  width: 180,
                  height: 14,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 30),

                // Small shimmer bars representing data loading
                Column(
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}


class ShopHelper {
  final supabase = Supabase.instance.client;
  Future<String?> getCurrentShopId() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final response = await supabase
          .from('shops')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      return response?['id']?.toString();
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getShopDetails() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final response = await supabase
          .from('shops')
          .select('*')
          .eq('user_id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }
}