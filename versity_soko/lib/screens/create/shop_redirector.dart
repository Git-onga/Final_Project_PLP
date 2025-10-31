import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../create/create_screen.dart';
import '../create/kiosk_screen.dart';

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
      print(user.id);
      setState(() {
        _hasShop = response != null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error checking shop: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _hasShop ? const KioskScreen() : const CreateScreen();
  }
}
