import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'wrapper.dart';
import 'screens/shop/shop_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/message/message_screen.dart';
import 'screens/auth/reset_password.dart';
import 'screens/create/shop_redirector.dart';

// supabase packages
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mpdckqnlcxgkfjcidwso.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1wZGNrcW5sY3hna2ZqY2lkd3NvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MDY3NzEsImV4cCI6MjA3NzM4Mjc3MX0.fpZULar3qWOhwChj6b76dNV0jk2nbplH1WzxcS0dm8I',
    
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()..initializeAuthListener()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'Versity Soko',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const MainWrapper(),
          '/shops': (context) => const ShopScreen(shopId: ''),
          '/community': (context) => const CommunityScreen(),
          '/message': (context) => const MessageScreen(),
          '/create': (context) => const ShopRedirector(),
          '/reset': (context) => const ResetPasswordScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}