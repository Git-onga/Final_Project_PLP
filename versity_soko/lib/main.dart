import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:versity_soko/providers/notification_provider.dart';
import 'package:versity_soko/services/shop_order_service.dart';
import 'package:versity_soko/splash_screen.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'wrapper.dart';
import 'screens/shop/shop_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/message/message_screen.dart';
import 'screens/auth/reset_password.dart';
import 'screens/create/shop_redirector.dart';

// Supabase packages
import 'package:supabase_flutter/supabase_flutter.dart';

// Theme Provider
import 'providers/theme_provider.dart'; // <-- create this file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
   
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()..initializeAuthListener()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ShopOrderService()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // <-- add ThemeProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Versity Soko',
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
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
    );
  }
}

