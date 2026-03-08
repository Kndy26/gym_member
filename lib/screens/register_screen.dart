// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Proses Register
      String? error = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: 'user', // User baru otomatis jadi 'user' (bukan admin)
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (error == null) {
          // Jika sukses, kembali ke login dan tampilkan pesan
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Registrasi Berhasil! Silakan Login.'),
                backgroundColor: Colors.green),
          );
        } else {
          // Jika gagal, tampilkan error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema Warna Pastel
    final bgColor = const Color(0xFFFDFBF7); // Cream
    final primaryColor = const Color(0xFF8AC6D1); // Biru Pastel

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1, size: 80, color: primaryColor),
                const SizedBox(height: 10),
                Text('Daftar Member Baru',
                    style: GoogleFonts.bebasNeue(
                        fontSize: 40, color: Colors.black87)),
                const SizedBox(height: 30),

                // Input Nama
                _buildPastelTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // Input Email
                _buildPastelTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Input Password
                _buildPastelTextField(
                  controller: _passwordController,
                  label: 'Password (8-16 Karakter)',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'Password wajib diisi';
                    if (val.length < 8 || val.length > 16)
                      return 'Password harus 8-16 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Konfirmasi Password
                _buildPastelTextField(
                  controller: _confirmPasswordController,
                  label: 'Ulangi Password',
                  icon: Icons.lock_reset,
                  isPassword: true,
                  validator: (val) {
                    if (val != _passwordController.text)
                      return 'Password tidak sama';
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Buat Akun',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),

                // Link ke Login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Sudah punya akun? Login disini',
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk membuat TextField Pastel
  Widget _buildPastelTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator ??
            (val) => val!.isEmpty ? '$label tidak boleh kosong' : null,
        decoration: InputDecoration(
          prefixIcon:
              Icon(icon, color: const Color(0xFFFFB7B2)), // Pink Pastel Icon
          labelText: label,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
