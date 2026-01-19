import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final auth = Provider.of<AuthServices>(context, listen: false);
    final success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Failed. Check credentials.')),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!')),
        );
      }
      return;
    }

    final auth = Provider.of<AuthServices>(context, listen: false);
    final success = await auth.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful! Please Login.')),
      );
      _tabController.animateTo(0); // Switch to login tab
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CAMPUS LOAN',
                  style: GoogleFonts.orbitron(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF06B6D4),
                    shadows: [
                       BoxShadow(
                        color: const Color(0xFF06B6D4).withOpacity(0.5),
                        blurRadius: 20,
                      )
                    ]
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Future of Campus Resources',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
                const SizedBox(height: 48),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorColor: const Color(0xFF06B6D4),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white54,
                        tabs: const [
                          Tab(text: 'LOGIN'),
                          Tab(text: 'REGISTER'),
                        ],
                      ),
                      SizedBox(
                        height: 480,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLoginForm(),
                            _buildRegisterForm(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final auth = Provider.of<AuthServices>(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Email', Icons.email_outlined),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Password', Icons.lock_outline),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _handleLogin,
              child: auth.isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('LOGIN'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    final auth = Provider.of<AuthServices>(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
           TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Full Name', Icons.person_outline),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Email', Icons.email_outlined),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Password', Icons.lock_outline),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Confirm Password', Icons.lock_outline),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _handleRegister,
              child: auth.isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text('REGISTER'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: const Color(0xFF06B6D4)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1.5),
      ),
    );
  }
}
