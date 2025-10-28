import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/product_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'wrapper.dart';
import 'screens/shop/shop_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/message/message_screen.dart';
import 'screens/create/create_screen.dart';
import 'screens/auth/reset_password.dart';

// Firebase packages
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform, );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
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
          '/shops': (context) => const ShopScreen(),
          '/community': (context) => const CommunityScreen(),
          '/message': (context) => const MessageScreen(),
          '/create': (context) => const CreateScreen(),
          '/reset': (context) => const ResetPasswordScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}