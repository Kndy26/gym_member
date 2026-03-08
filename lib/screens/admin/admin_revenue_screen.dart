// lib/screens/admin/admin_revenue_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminRevenueScreen extends StatefulWidget {
  const AdminRevenueScreen({super.key});

  @override
  State<AdminRevenueScreen> createState() => _AdminRevenueScreenState();
}

class _AdminRevenueScreenState extends State<AdminRevenueScreen> {
  String _selectedFilter = 'Bulan Ini';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Laporan Pendapatan'),
        backgroundColor: const Color(0xFF8AC6D1),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          double totalRevenue = 0;
          int countSilver = 0;
          int countGold = 0;
          int countPlatinum = 0;
          List<DocumentSnapshot> filteredDocs = [];

          final now = DateTime.now();
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final Timestamp? ts = data['createdAt'];
            if (ts == null) continue;

            final date = ts.toDate();
            bool include = false;

            if (_selectedFilter == 'Semua') {
              include = true;
            } else if (_selectedFilter == 'Bulan Ini') {
              if (date.year == now.year && date.month == now.month)
                include = true;
            } else if (_selectedFilter == 'Hari Ini') {
              if (date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day) include = true;
            }

            if (include) {
              filteredDocs.add(doc);
              totalRevenue += (data['amount'] ?? 0);

              String itemName = (data['itemName'] ?? '').toString();
              if (itemName.contains('Silver'))
                countSilver++;
              else if (itemName.contains('Gold'))
                countGold++;
              else if (itemName.contains('Platinum')) countPlatinum++;
            }
          }

          final currencyFormatter = NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

          return Column(
            children: [
              // 1. HERO CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF8AC6D1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Pendapatan ($_selectedFilter)',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormatter.format(totalRevenue),
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 24),

                    // === BAGIAN STATISTIK (DIPERBAIKI) ===
                    Row(
                      children: [
                        // Expanded memaksa widget mengisi ruang kosong secara merata
                        Expanded(
                          child: _buildStatItem('Silver', countSilver,
                              Colors.grey.shade200, Colors.grey.shade800),
                        ),
                        const SizedBox(width: 8), // Jarak antar kotak
                        Expanded(
                          child: _buildStatItem('Gold', countGold,
                              const Color(0xFFFFF9C4), const Color(0xFFFBC02D)),
                        ),
                        const SizedBox(width: 8), // Jarak antar kotak
                        Expanded(
                          child: _buildStatItem('Platinum', countPlatinum,
                              const Color(0xFFE1BEE7), const Color(0xFF8E24AA)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. FILTER CHIPS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text("Filter: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    _buildFilterChip('Hari Ini'),
                    _buildFilterChip('Bulan Ini'),
                    _buildFilterChip('Semua'),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 3. LIST TRANSAKSI
              Expanded(
                child: filteredDocs.isEmpty
                    ? Center(
                        child: Text("Tidak ada transaksi $_selectedFilter",
                            style: const TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        itemCount: filteredDocs.length,
                        itemBuilder: (ctx, i) {
                          final data =
                              filteredDocs[i].data() as Map<String, dynamic>;
                          final date =
                              (data['createdAt'] as Timestamp).toDate();
                          final itemName = data['itemName'] ?? 'Membership';

                          Color iconColor = Colors.green;
                          if (itemName.contains('Silver'))
                            iconColor = Colors.grey;
                          else if (itemName.contains('Gold'))
                            iconColor = Colors.amber.shade700;
                          else if (itemName.contains('Platinum'))
                            iconColor = Colors.purple;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: iconColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.monetization_on,
                                    color: iconColor),
                              ),
                              title: Text(itemName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                DateFormat('dd MMM yyyy, HH:mm').format(date),
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                              trailing: Text(
                                currencyFormatter.format(data['amount'] ?? 0),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: iconColor,
                                    fontSize: 15),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget Statistik (Dengan ukuran tinggi yang konsisten)
  Widget _buildStatItem(
      String label, int count, Color bgColor, Color textColor) {
    return Container(
      // Tinggi fix agar semua kotak tingginya sama,
      // width infinity agar mengisi Expanded
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(count.toString(),
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.9),
                  fontWeight: FontWeight.w500)),
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
