// lib/screens/admin/admin_post_news.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPostNews extends StatefulWidget {
  const AdminPostNews({super.key});

  @override
  State<AdminPostNews> createState() => _AdminPostNewsState();
}

class _AdminPostNewsState extends State<AdminPostNews> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  // Variabel untuk menyimpan kategori yang dipilih
  String _selectedCategory = 'INFO'; // Default

  Future<void> _postNews() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan isi pesan tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('news').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'category': _selectedCategory, // SIMPAN KATEGORI KE FIREBASE
        'createdAt': FieldValue.serverTimestamp(),
        'targetUserId': 'all',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Berita berhasil diposting!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Buat Pengumuman'),
        backgroundColor: const Color(0xFF8AC6D1),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER ILUSTRASI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF8AC6D1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.campaign_outlined,
                        size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Sampaikan Kabar Terbaru",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Pesan ini akan dikirim ke semua member aktif",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            // FORM INPUT
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Detail Pesan",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 20),

                    // PILIHAN KATEGORI (Tagline)
                    const Text("Kategori Pesan:",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildCategoryChip('INFO', Colors.amber),
                        const SizedBox(width: 12),
                        _buildCategoryChip('PROMO', Colors.green),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Input Judul
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul Berita',
                        hintText: 'Contoh: Promo Spesial Akhir Tahun',
                        prefixIcon:
                            const Icon(Icons.title, color: Color(0xFF8AC6D1)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input Isi Pesan
                    TextField(
                      controller: _contentController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: 'Isi Pesan',
                        hintText: 'Tuliskan informasi lengkap di sini...',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 100),
                          child:
                              Icon(Icons.edit_note, color: Color(0xFF8AC6D1)),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Kirim
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _postNews,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.send),
                        label: Text(
                          _isLoading ? 'Mengirim...' : 'Kirim Pengumuman',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8AC6D1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Pilihan Kategori
  Widget _buildCategoryChip(String label, Color color) {
    bool isSelected = _selectedCategory == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedCategory = label);
      },
      selectedColor: color.withOpacity(0.2),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey,
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.transparent,
        width: 1.5,
      ),
    );
  }
}
