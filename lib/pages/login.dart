import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _toggleMode() {
    setState(() {
      isLogin = !isLogin;
      _formKey.currentState?.reset();
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLogin ? 'Login successful!' : 'Registration successful!',
          ),
          backgroundColor: const Color(0xFF60A5FA),
          behavior: SnackBarBehavior.floating,
        ),
      );
      String username = isLogin
          ? _emailController.text.split('@')[0]
          : _usernameController.text;

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(username: username),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildGlowSpot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 150, spreadRadius: 50)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: const Color(0xFF030712),
        primaryColor: const Color(0xFF60A5FA),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF60A5FA),
          secondary: const Color(0xFF818CF8),
          error: const Color(0xFFF87171),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            fontSize: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF60A5FA),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 2,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF818CF8),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF60A5FA), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF87171), width: 1),
          ),
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIconColor: Colors.white.withOpacity(0.6),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.75,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.75,
            color: Colors.white,
          ),
          headlineSmall: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.75,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.75,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.75,
            color: Colors.white,
          ),
          titleSmall: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.75,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Stack(
          children: [
            // Background Glow Effects
            Positioned(
              top: -100,
              right: -100,
              child: _buildGlowSpot(
                250,
                const Color(0xFF3B82F6).withOpacity(0.15),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: _buildGlowSpot(
                300,
                const Color(0xFF8B5CF6).withOpacity(0.15),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            // 🔧 PERUBAHAN (AGAR LOGIN NAIK KE ATAS)
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 🔧 PERUBAHAN (PADDING ATAS)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 24,
                                ),
                                child: Text(
                                  isLogin ? 'Login' : 'Register',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              if (!isLogin)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: TextFormField(
                                    controller: _usernameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'Username',
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: Colors.white70,
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your username';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: TextFormField(
                                  controller: _emailController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: Colors.white70,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: TextFormField(
                                  controller: _passwordController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: Colors.white70,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              if (!isLogin)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: TextFormField(
                                    controller: _confirmPasswordController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'Confirm Password',
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: Colors.white70,
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _submit,
                                child: Text(isLogin ? 'Login' : 'Register'),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton(
                                  onPressed: _toggleMode,
                                  child: Text(
                                    isLogin
                                        ? 'Don\'t have an account? Register'
                                        : 'Already have an account? Login',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
