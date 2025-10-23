import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  
  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.green.shade900,
              Colors.green.shade500,
              Colors.green.shade200,
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.all(30),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,        // White background
                      shape: BoxShape.circle,     // Makes it round
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,  // Soft shadow
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(width: 30,),
                  Text(   
                    'Register',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                      
                  )
                 
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white
                ),
                child: Padding(
                  padding: EdgeInsetsGeometry.all(30),
                  child: Column(
                    children: [
                      _Form(),
                      Spacer(),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        height: 60,
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
                    ],
                  )
                ),
              )
            ),
            
            
          ],
        ),
      )
        
    );
  }

}


class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _universityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomInput(
            controller: _nameController,
            label: 'Full Name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          CustomInput(
            controller: _emailController,
            label: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomInput(
            controller: _passwordController,
            label: 'Password',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomInput(
            controller: _universityController,
            label: 'University',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your university';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          if (authProvider.error != null)
            Text(
              authProvider.error!,
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Register',
            isLoading: authProvider.isLoading,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                authProvider.register(
                  _nameController.text,
                  _emailController.text,
                  _passwordController.text,
                  _universityController.text,
                ).then((success) {
                  if (success) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 50),
            child: Row(
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(
                    fontSize: 12
                  ),
                ),
                SizedBox(width: 30,),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          )
          
          
        ],
      ),
    );
  }
}