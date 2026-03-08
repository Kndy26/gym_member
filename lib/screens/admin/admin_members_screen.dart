// lib/screens/admin/admin_members_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/membership_provider.dart';
import '../../models/membership.dart';

class AdminMembersScreen extends StatefulWidget {
  const AdminMembersScreen({super.key});

  @override
  State<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends State<AdminMembersScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  final Map<String, String> _membershipIdToName = {
    '1': 'Silver',
    '2': 'Gold',
    '3': 'Platinum',
  };

  // === FUNGSI PEMBATALAN MEMBERSHIP ===
  void _showCancelDialog(
      BuildContext context, String userId, String userName, String activePlan) {
    final reasonController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Batalkan Membership?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Anda akan membatalkan paket $activePlan milik $userName.'),
                  const SizedBox(height: 16),
                  const Text('Alasan Pembatalan (Wajib):',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      hintText: 'Cth: Permintaan user, Pelanggaran...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: const Text('Kembali'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (reasonController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Harap isi alasan pembatalan!')),
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          try {
                            // Menggunakan Batch agar semua proses sukses bersamaan
                            final batch = FirebaseFirestore.instance.batch();

                            // 1. Update User (Hapus Membership)
                            final userRef = FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId);
                            batch.update(userRef, {
                              'activeMembershipId': null, // Set null
                              'membershipUpdatedAt':
                                  FieldValue.serverTimestamp(),
                            });

                            // 2. Log Aktivitas Admin (Riwayat)
                            final logRef = FirebaseFirestore.instance
                                .collection('activity_logs')
                                .doc();
                            batch.set(logRef, {
                              'type': 'CANCEL',
                              'userName': userName,
                              'timestamp': FieldValue.serverTimestamp(),
                              'detail':
                                  'Dibatalkan Admin. Alasan: ${reasonController.text}',
                            });

                            // 3. Kirim Pesan ke Inbox User (News)
                            // Kita tambahkan field 'targetUserId' agar spesifik (opsional, tergantung implementasi inbox)
                            final newsRef = FirebaseFirestore.instance
                                .collection('news')
                                .doc();
                            batch.set(newsRef, {
                              'title': 'Membership Dibatalkan',
                              'content':
                                  'Halo $userName, paket $activePlan Anda telah dibatalkan oleh Admin. \n\nAlasan: ${reasonController.text}',
                              'createdAt': FieldValue.serverTimestamp(),
                              'targetUserId':
                                  userId, // Penanda pesan privat (opsional)
                            });

                            await batch.commit();

                            if (mounted) {
                              Navigator.pop(ctx); // Tutup Dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Membership berhasil dibatalkan')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal: $e')),
                            );
                          } finally {
                            if (mounted) setState(() => isLoading = false);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Batalkan Paket',
                          style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final membershipProvider =
        Provider.of<MembershipProvider>(context, listen: false);
    final List<Membership> allMemberships = membershipProvider.memberships;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Member'),
        backgroundColor: const Color(0xFF8AC6D1),
        elevation: 0,
      ),
      body: Column(
        children: [
          // === SEARCH & FILTER ===
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8AC6D1).withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Cari nama member...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text("Filter: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      _buildFilterChip('Semua'),
                      _buildFilterChip('Silver'),
                      _buildFilterChip('Gold'),
                      _buildFilterChip('Platinum'),
                      _buildFilterChip('Belum Langganan'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // === LIST MEMBER ===
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'user')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return const Center(child: Text('Belum ada member.'));

                final allUsers = snapshot.data!.docs;

                final filteredUsers = allUsers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final activePackageId = data['activeMembershipId'];

                  bool matchesSearch = name.contains(_searchQuery);
                  bool matchesFilter = false;
                  if (_selectedFilter == 'Semua')
                    matchesFilter = true;
                  else if (_selectedFilter == 'Belum Langganan')
                    matchesFilter =
                        (activePackageId == null || activePackageId == '');
                  else {
                    String targetId = _membershipIdToName.keys.firstWhere(
                        (k) => _membershipIdToName[k] == _selectedFilter,
                        orElse: () => '');
                    matchesFilter = (activePackageId == targetId);
                  }
                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                      child:
                          Text('Tidak ditemukan hasil untuk "$_searchQuery"'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (ctx, index) {
                    final data =
                        filteredUsers[index].data() as Map<String, dynamic>;
                    final userId = filteredUsers[index].id;
                    final name = data['name'] ?? 'No Name';
                    final email = data['email'] ?? '-';
                    final photoUrl = data['photoUrl'];
                    final activePackageId = data['activeMembershipId'];

                    String packageName = '';
                    bool isActive = false;

                    if (activePackageId != null && activePackageId != '') {
                      isActive = true;
                      try {
                        final membership = allMemberships
                            .firstWhere((m) => m.id == activePackageId);
                        packageName = membership.nama;
                      } catch (e) {
                        packageName = 'Unknown';
                      }
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              (photoUrl != null && photoUrl.isNotEmpty)
                                  ? NetworkImage(photoUrl)
                                  : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
                              ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U')
                              : null,
                        ),
                        title: Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(email,
                                style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                    isActive
                                        ? Icons.verified
                                        : Icons.cancel_outlined,
                                    size: 16,
                                    color:
                                        isActive ? Colors.green : Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                    isActive
                                        ? 'Member Aktif'
                                        : 'Belum Langganan',
                                    style: TextStyle(
                                        color: isActive
                                            ? Colors.green
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                if (isActive)
                                  Text(' • $packageName',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                        // TOMBOL BATALKAN (Hanya muncul jika user AKTIF)
                        trailing: isActive
                            ? IconButton(
                                icon:
                                    const Icon(Icons.block, color: Colors.red),
                                tooltip: 'Batalkan Membership',
                                onPressed: () => _showCancelDialog(
                                    context, userId, name, packageName),
                              )
                            : null,
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
          if (selected) setState(() => _selectedFilter = label);
        },
      ),
    );
  }
}
