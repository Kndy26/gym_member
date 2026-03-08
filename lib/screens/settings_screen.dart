// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'help_support_screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini
import 'package:firebase_storage/firebase_storage.dart'; // Tambahkan ini

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State Dummy untuk UI
  bool _notifEnabled = true;

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa klik luar untuk tutup
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun?'),
        content: const Text(
            'Tindakan ini PERMANEN. Semua data profil, membership, dan riwayat akan hilang selamanya.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus Permanen',
                style: TextStyle(color: Colors.white)),
            onPressed: () async {
              // 1. Tutup Dialog konfirmasi
              Navigator.pop(ctx);

              // Tampilkan loading indicator (opsional, bisa pakai snackbar atau dialog loading)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Sedang memproses penghapusan...')),
              );

              final user = FirebaseAuth.instance.currentUser;

              if (user == null) return;

              try {
                // A. Ambil data user dulu untuk mendapatkan photoUrl (karena di settings kita tidak pegang datanya)
                DocumentSnapshot userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();

                // B. Hapus Foto Profil di Storage (Jika ada)
                if (userDoc.exists) {
                  final data = userDoc.data() as Map<String, dynamic>?;
                  final photoUrl = data?['photoUrl'];

                  if (photoUrl != null && photoUrl.toString().isNotEmpty) {
                    try {
                      final ref = FirebaseStorage.instance.refFromURL(photoUrl);
                      await ref.delete();
                    } catch (e) {
                      print("Gagal hapus foto (mungkin sudah hilang): $e");
                    }
                  }
                }

                // C. Hapus Data User di Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .delete();

                // D. Hapus User dari Firebase Authentication
                await user.delete();

                if (mounted) {
                  // Navigasi ke Login Screen
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Akun Anda telah dihapus selamanya.')),
                  );
                }
              } on FirebaseAuthException catch (e) {
                // Handle Error Khusus Auth (Biasanya requires-recent-login)
                if (mounted) {
                  String message = 'Gagal menghapus akun: ${e.message}';

                  if (e.code == 'requires-recent-login') {
                    message =
                        'Demi keamanan, silakan Logout dan Login ulang, lalu coba hapus akun kembali.';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(message), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Terjadi kesalahan: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color(0xFF8AC6D1),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // === SECTION 1: UMUM ===
          _buildSectionHeader('Umum'),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            subtitle: 'Terima info berita & promo terbaru',
            value: _notifEnabled,
            onChanged: (val) => setState(() => _notifEnabled = val),
          ),

          _buildNavigationTile(
            icon: Icons.language,
            title: 'Bahasa',
            trailingText: 'Indonesia',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // === SECTION 2: KEAMANAN ===
          _buildSectionHeader('Keamanan'),
          _buildNavigationTile(
            icon: Icons.lock_outline,
            title: 'Ubah Password',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),

          const SizedBox(height: 24),

          // === SECTION 3: INFO LAINNYA ===
          _buildSectionHeader('Bantuan & Lainnya'),
          _buildNavigationTile(
            icon: Icons.help_outline,
            title: 'Pusat Bantuan (FAQ)',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FAQScreen()));
            },
          ),
          _buildNavigationTile(
            icon: Icons.description_outlined,
            title: 'Syarat & Ketentuan',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TermsScreen()));
            },
          ),
          _buildNavigationTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Kebijakan Privasi',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PrivacyScreen()));
            },
          ),

          const SizedBox(height: 24),

          // === TOMBOL HAPUS AKUN ===
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever, color: Colors.red),
              ),
              title: const Text(
                'Hapus Akun',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: _showDeleteAccountDialog,
            ),
          ),

          const SizedBox(height: 30),

          // Versi Aplikasi
          const Center(
            child: Text(
              'Versi 1.0.0 (Beta)',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8AC6D1).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF8AC6D1)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12))
            : null,
        value: value,
        activeColor: const Color(0xFF8AC6D1),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(trailingText, style: const TextStyle(color: Colors.grey)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
