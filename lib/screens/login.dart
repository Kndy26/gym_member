// lib/screens/login.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // 1. Lakukan Login
      String? error = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (error == null) {
        // 2. Login Sukses, Cek Role User
        String role = await _authService.getUserRole();

        if (mounted) {
          setState(() => _isLoading = false);
          if (role == 'admin') {
            // Jika Admin -> Ke Admin Dashboard
            Navigator.pushReplacementNamed(context, '/admin_dashboard');
          } else {
            // Jika User Biasa -> Ke Home
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } else {
        // 3. Login Gagal
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Login Gagal: $error"),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Cream Pastel
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo MuGenGym dengan Outline
                Stack(
                  children: <Widget>[
                    Text('MuGenGym',
                        style: GoogleFonts.bebasNeue(
                            fontSize: 70, color: const Color(0xFF8AC6D1))),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Silakan Login untuk melanjutkan',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 40),

                // Input Email
                _buildPastelTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined),
                const SizedBox(height: 16),

                // Input Password
                _buildPastelTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true),
                const SizedBox(height: 30),

                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8AC6D1), // Biru Pastel
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Login Masuk',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol ke Register
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()));
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Belum punya akun? ',
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                            text: 'Daftar Sekarang',
                            style: TextStyle(
                                color: Color(0xFFFFB7B2),
                                fontWeight: FontWeight.bold)),
                      ],
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

  // Widget Helper TextField (Sama agar konsisten)
  Widget _buildPastelTextField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: (val) => val!.isEmpty ? '$label tidak boleh kosong' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFFFFB7B2)),
          labelText: label,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
