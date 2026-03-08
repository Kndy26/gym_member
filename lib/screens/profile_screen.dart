// lib/screens/profile_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart'; // Pastikan import ini ada

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(); // [BARU] No HP
  final _passwordController = TextEditingController();

  String? _photoUrl;
  String _selectedGender = 'Laki-laki'; // [BARU] Default Gender
  bool _isLoading = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_user != null) {
      try {
        var doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();
        if (doc.exists && mounted) {
          final data = doc.data();
          setState(() {
            _nameController.text = data?['name'] ?? '';
            _phoneController.text = data?['phoneNumber'] ?? ''; // Load No HP
            _selectedGender = data?['gender'] ?? 'Laki-laki'; // Load Gender
            _photoUrl = data?['photoUrl'];
          });
        }
      } catch (e) {
        // Silent error
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    setState(() => _isLoading = true);

    try {
      String? newPhotoUrl = _photoUrl;

      // 1. Upload Foto
      if (_imageBytes != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_photos')
            .child('${_user!.uid}.jpg');
        await ref.putData(
            _imageBytes!, SettableMetadata(contentType: 'image/jpeg'));
        newPhotoUrl = await ref.getDownloadURL();
      }

      // 2. Update Firestore (Termasuk data baru: Phone & Gender)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(), // [BARU]
        'gender': _selectedGender, // [BARU]
        'photoUrl': newPhotoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Update Password (Opsional)
      if (_passwordController.text.isNotEmpty) {
        if (_passwordController.text.length < 6) {
          throw FirebaseAuthException(
              code: 'weak-password', message: 'Password minimal 6 karakter');
        }
        await _user!.updatePassword(_passwordController.text);
      }

      // 4. Update Auth Profile
      await _user!.updateDisplayName(_nameController.text.trim());
      if (newPhotoUrl != null) {
        await _user!.updatePhotoURL(newPhotoUrl);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profil berhasil diperbarui!'),
              backgroundColor: Colors.green),
        );
        setState(() {
          _passwordController.clear();
          _imageBytes = null;
          _photoUrl = newPhotoUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal update: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // [BARU] Fungsi Hapus Akun
  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun?'),
        content: const Text(
            'Tindakan ini PERMANEN. Semua data profil, membership, dan riwayat akan hilang selamanya.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus Permanen',
                style: TextStyle(color: Colors.white)),
            onPressed: () async {
              // 1. Tutup Dialog dulu
              Navigator.pop(ctx);

              // 2. Tampilkan Loading
              setState(() => _isLoading = true);

              try {
                // A. Hapus Foto Profil di Storage (Jika ada)
                if (_photoUrl != null && _photoUrl!.isNotEmpty) {
                  try {
                    // Pastikan path sesuai dengan saat upload ('user_photos/UID.jpg')
                    final ref = FirebaseStorage.instance.refFromURL(_photoUrl!);
                    await ref.delete();
                  } catch (e) {
                    print("Gagal hapus foto (mungkin sudah hilang): $e");
                    // Lanjut saja, jangan stop proses hanya karena foto gagal dihapus
                  }
                }

                // B. Hapus Data User di Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_user!.uid)
                    .delete();

                // C. Hapus User dari Firebase Authentication
                // PENTING: Ini butuh 'Recent Login'. Jika user sudah lama login,
                // Firebase akan menolak (error 'requires-recent-login').
                await _user!.delete();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Akun Anda telah dihapus.')),
                  );
                  // D. Kembali ke Login Screen
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                }
              } on FirebaseAuthException catch (e) {
                // Handle Error Khusus Auth
                if (mounted) {
                  String message = 'Gagal menghapus akun: ${e.message}';

                  // Jika error karena sesi habis (requires-recent-login)
                  if (e.code == 'requires-recent-login') {
                    message =
                        'Demi keamanan, silakan Logout dan Login ulang sebelum menghapus akun.';
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
              } finally {
                if (mounted) setState(() => _isLoading = false);
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
      // Kita pakai Body custom, bukan AppBar biasa agar bisa melengkung
      body: SingleChildScrollView(
        child: Column(
          children: [
            // === HEADER CUSTOM (CURVED) ===
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Background Lengkung
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8AC6D1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                ),

                // Judul Halaman di tengah atas
                Positioned(
                  top: 60,
                  child: Text(
                    'Edit Profil',
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),

                // Foto Profil (Positioned agar "nangkring" di garis lengkung)
                Positioned(
                  bottom: -50,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white,
                                  width: 4), // Border putih tebal
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5))
                              ]),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _imageBytes != null
                                ? MemoryImage(_imageBytes!) as ImageProvider
                                : (_photoUrl != null && _photoUrl!.isNotEmpty
                                    ? NetworkImage(_photoUrl!)
                                    : null),
                            child: (_imageBytes == null &&
                                    (_photoUrl == null || _photoUrl!.isEmpty))
                                ? const Icon(Icons.person,
                                    size: 60, color: Colors.grey)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70), // Jarak kompensasi foto profile

            // === FORM FIELDS ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Email (Read Only)
                  _buildTextField(
                    label: 'Email',
                    controller: TextEditingController(text: _user?.email),
                    icon: Icons.email_outlined,
                    isReadOnly: true,
                  ),
                  const SizedBox(height: 16),

                  // Nama Lengkap
                  _buildTextField(
                    label: 'Nama Lengkap',
                    controller: _nameController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // [BARU] Nomor HP
                  _buildTextField(
                    label: 'Nomor WhatsApp / HP',
                    controller: _phoneController,
                    icon: Icons.phone_android_outlined,
                    inputType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // [BARU] Dropdown Gender
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF8AC6D1)),
                        items: ['Laki-laki', 'Perempuan'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  value == 'Laki-laki'
                                      ? Icons.male
                                      : Icons.female,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedGender = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Baru
                  _buildTextField(
                    label: 'Password Baru (Opsional)',
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    isObscure: true,
                    hint: 'Kosongkan jika tidak ubah',
                  ),
                  const SizedBox(height: 30),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8AC6D1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Simpan Perubahan',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // [BARU] Tombol Hapus Akun (Zona Bahaya)
                  TextButton.icon(
                    onPressed: _deleteAccount,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text('Hapus Akun Saya',
                        style: TextStyle(color: Colors.red)),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Text Field yang Konsisten
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isReadOnly = false,
    bool isObscure = false,
    TextInputType inputType = TextInputType.text,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      obscureText: isObscure,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF8AC6D1)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8AC6D1), width: 2),
        ),
        filled: true,
        fillColor: isReadOnly ? Colors.grey[100] : Colors.white,
      ),
    );
  }
}
