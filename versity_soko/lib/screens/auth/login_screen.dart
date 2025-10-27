import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/fadeinanimation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 250, // Adjust this height to control the wave size
            child: ClipPath(
              clipper: WavyClipper(),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    colors: [
                      Colors.green.shade900,
                      const Color(0xFF4CAF50),
                      Colors.green.shade200,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Versity Soko',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                child: _Form(),
              ),
            ),
          ),
          SizedBox(height: 15,),
          FadeInWidget(
            duration: const Duration(milliseconds: 1600),
              child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 80,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300, // border color
                    width: 2.0,         // border thickness
                  ),
                )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Align icons to the right
                crossAxisAlignment: CrossAxisAlignment.stretch, // Align them to top if needed
                children: [
                  SvgPicture.asset(
                    'assets/icons/google.svg',
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 40), // spacing between icons
                  SvgPicture.asset(
                    'assets/icons/apple.svg',
                    width: 49,
                    height: 49,
                  ),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}

class WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height * 0.6); // Start the wave lower

    // Smooth gentle wave
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.4, 
      size.width * 0.5, size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.8, 
      size.width, size.height * 0.6,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          FadeInWidget(
            duration: const Duration(milliseconds: 1000),
            child: Text(
              'Welcome Back',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 22),
          FadeInWidget(
            duration: const Duration(milliseconds: 1200),
            child: _customEmailInput(),
          ),
          const SizedBox(height: 18),
          FadeInWidget(
            duration: const Duration(milliseconds: 1200),
            child: _customPasswordInput(),
          ),
          const SizedBox(height: 14),
          FadeInWidget(
            duration: const Duration(milliseconds: 1400),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/reset');
                    },
                    child: const Text(
                      ' Forgot Password',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height:8),
          if (authProvider.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Text(
                authProvider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          FadeInWidget(
            duration: const Duration(milliseconds: 1400),
            child: CustomButton(
              text: 'Login',
              width: 220,
              isLoading: authProvider.isLoading,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  authProvider
                      .login(
                    _emailController.text,
                    _passwordController.text,
                  )
                      .then((success) {
                    if (success) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          FadeInWidget(
            duration: const Duration(milliseconds: 1400),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(width: 8,),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      ' Register',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _customEmailInput() {
    return CustomInput(
      controller: _emailController,
      label: 'Email',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        return null;
      },
    );
  }

  Widget _customPasswordInput() {
    return CustomInput(
      controller: _passwordController,
      label: 'Password',
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }
}