// lib/screens/inbox_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InboxScreen extends StatefulWidget {
  final bool isAdmin;

  const InboxScreen({super.key, this.isAdmin = false});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  // Variabel Filter
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    if (!widget.isAdmin) {
      _markAsRead();
    }
  }

  Future<void> _markAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'lastCheckedInbox': FieldValue.serverTimestamp(),
      });
    }
  }

  // ... (Fungsi _deleteNews dan _showEditDialog tetap sama, tidak berubah) ...
  void _deleteNews(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Berita?'),
        content:
            const Text('Berita ini akan dihapus permanen dari semua user.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('news')
                  .doc(docId)
                  .delete();
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String docId, String currentTitle,
      String currentContent, String currentCategory) {
    final titleController = TextEditingController(text: currentTitle);
    final contentController = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Berita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul')),
            const SizedBox(height: 16),
            TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Isi'),
                maxLines: 4),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8AC6D1)),
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('news')
                    .doc(docId)
                    .update({
                  'title': titleController.text,
                  'content': contentController.text,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUid = currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'Kelola Berita' : 'Inbox Berita'),
        backgroundColor: const Color(0xFF8AC6D1),
        elevation: 0, // Hilangkan shadow agar menyatu dengan filter container
      ),
      body: Column(
        children: [
          // === 1. BAGIAN FILTER (Sama seperti Admin Member Screen) ===
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8AC6D1)
                  .withOpacity(0.2), // Warna latar filter
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text("Filter: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  _buildFilterChip('Semua'),
                  _buildFilterChip('INFO'),
                  _buildFilterChip('PROMO'),
                  _buildFilterChip('PENTING'),
                ],
              ),
            ),
          ),

          // === 2. LIST BERITA ===
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('news')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final allDocs = snapshot.data!.docs;

                // === LOGIKA FILTERING ===
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final targetId = data['targetUserId'];
                  final categoryFromDb = data['category'] ?? 'INFO';

                  // 1. Cek Permission (User vs Admin)
                  bool isVisibleToUser = false;
                  if (widget.isAdmin) {
                    isVisibleToUser = true; // Admin lihat semua
                  } else {
                    // User lihat: Public, Null, atau milik sendiri
                    if (targetId == 'all' ||
                        targetId == null ||
                        targetId == currentUid) {
                      isVisibleToUser = true;
                    }
                  }

                  if (!isVisibleToUser) return false;

                  // 2. Tentukan Tipe Berita yang Sebenarnya
                  bool isPrivate = targetId != null && targetId != 'all';
                  String actualCategory = 'INFO'; // Default

                  if (isPrivate) {
                    actualCategory = 'PENTING';
                  } else if (categoryFromDb == 'PROMO') {
                    actualCategory = 'PROMO';
                  } else {
                    actualCategory = 'INFO';
                  }

                  // 3. Cek dengan Filter yang Dipilih (_selectedFilter)
                  if (_selectedFilter == 'Semua') return true;
                  return actualCategory == _selectedFilter;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.filter_list_off,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text('Tidak ada berita "$_selectedFilter"',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (ctx, index) {
                    final doc = filteredDocs[index];
                    final news = doc.data() as Map<String, dynamic>;

                    final createdAt = news['createdAt'] as Timestamp?;
                    final updatedAt = news['updatedAt'] as Timestamp?;
                    final targetId = news['targetUserId'];
                    final category = news['category'] ?? 'INFO';

                    String dateDisplay = '';
                    if (updatedAt != null) {
                      final date = updatedAt.toDate();
                      dateDisplay =
                          'last edited ${DateFormat('dd MMM, HH:mm').format(date)}';
                    } else if (createdAt != null) {
                      final date = createdAt.toDate();
                      dateDisplay = DateFormat('dd MMM, HH:mm').format(date);
                    }

                    bool isPrivate = targetId != null && targetId != 'all';

                    // Tampilan Badge
                    Color badgeColor = Colors.amber; // Default INFO (Kuning)
                    Color badgeBgColor = Colors.amber.withOpacity(0.2);
                    String badgeText = category;

                    if (isPrivate) {
                      badgeText = 'PENTING';
                      badgeColor = Colors.redAccent;
                      badgeBgColor = Colors.redAccent.withOpacity(0.1);
                    } else if (category == 'PROMO') {
                      badgeColor = Colors.green;
                      badgeBgColor = Colors.green.withOpacity(0.1);
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        // PERUBAHAN DISINI: Gunakan badgeColor untuk border
                        side: BorderSide(
                            color: badgeColor.withOpacity(
                                0.5), // Sedikit transparan agar tidak terlalu tebal
                            width: 1.5),
                      ),
                      child: Padding(
                        // ... (Isi child tetap sama) ...
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeBgColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(badgeText,
                                      style: TextStyle(
                                          color: badgeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                ),
                                Text(dateDisplay,
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              news['title'] ?? 'Tanpa Judul',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              news['content'] ?? '',
                              style: const TextStyle(color: Colors.black87),
                            ),
                            if (widget.isAdmin) ...[
                              const Divider(height: 30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isPrivate
                                        ? 'To: Specific User'
                                        : 'To: Everyone',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic),
                                  ),
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _showEditDialog(
                                            context,
                                            doc.id,
                                            news['title'],
                                            news['content'],
                                            category),
                                        icon: const Icon(Icons.edit, size: 18),
                                        label: const Text('Edit'),
                                        style: TextButton.styleFrom(
                                            foregroundColor: Colors.blue),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _deleteNews(context, doc.id),
                                        icon:
                                            const Icon(Icons.delete, size: 18),
                                        label: const Text('Hapus'),
                                        style: TextButton.styleFrom(
                                            foregroundColor: Colors.red),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Filter Chip
  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF8AC6D1),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFilter = label;
            });
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text('Belum ada berita baru', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
