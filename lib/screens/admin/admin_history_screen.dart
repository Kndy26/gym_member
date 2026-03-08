// lib/screens/admin/admin_history_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  bool _isDeleting = false;

  // Fungsi Menghapus Semua Data
  Future<void> _clearAllHistory() async {
    // 1. Tampilkan Dialog Konfirmasi Dulu
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Riwayat?'),
        content: const Text(
            'Tindakan ini akan menghapus PERMANEN semua catatan aktivitas. Data tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // Batal
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true), // Ya, Hapus
            child: const Text('Hapus Semua',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // Jika user pilih Batal atau klik luar, hentikan proses
    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      // 2. Ambil semua dokumen di collection activity_logs
      final collection = FirebaseFirestore.instance.collection('activity_logs');
      final snapshot = await collection.get();

      if (snapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Riwayat sudah kosong.')),
          );
        }
        setState(() => _isDeleting = false);
        return;
      }

      // 3. Gunakan Batch untuk menghapus banyak data sekaligus
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // Komit perubahan (eksekusi hapus)
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua riwayat berhasil dihapus.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
        backgroundColor: const Color(0xFF8AC6D1),
        actions: [
          // TOMBOL SAMPAH (DELETE ALL)
          if (!_isDeleting) // Sembunyikan tombol jika sedang proses hapus
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              tooltip: 'Hapus Semua Riwayat',
              onPressed: _clearAllHistory,
            ),
        ],
      ),
      body: _isDeleting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Menghapus data..."),
                ],
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('activity_logs')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final logs = snapshot.data!.docs;

                if (logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        const Text("Belum ada aktivitas.",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (ctx, i) {
                    final data = logs[i].data() as Map<String, dynamic>;
                    final type = data['type'];
                    final user = data['userName'] ?? 'Unknown';
                    final detail = data['detail'];

                    Timestamp? ts = data['timestamp'];
                    String timeString = ts != null
                        ? DateFormat('dd MMM yyyy, HH:mm').format(ts.toDate())
                        : '-';

                    IconData icon;
                    Color color;
                    String title;
                    String subtitle = timeString;

                    switch (type) {
                      case 'REGISTER':
                        icon = Icons.person_add;
                        color = Colors.blue;
                        title = '$user Baru Mendaftar';
                        break;
                      case 'UPGRADE':
                        icon = Icons.star;
                        color = Colors.orange;
                        title = (detail != null && detail.toString().isNotEmpty)
                            ? '$user $detail'
                            : '$user Melakukan Transaksi Paket';
                        break;
                      case 'CANCEL':
                        icon = Icons.cancel;
                        color = Colors.red;
                        title = '$user Membatalkan Membership';
                        break;
                      default:
                        icon = Icons.info;
                        color = Colors.grey;
                        title = 'Aktivitas $user';
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.1),
                              child: Icon(icon, color: color)),
                          title: Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(subtitle,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
