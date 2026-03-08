// lib/providers/membership_provider.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/membership.dart';

class MembershipProvider with ChangeNotifier {
  // Data Membership
  final List<Membership> memberships = [
    Membership(
      id: '1',
      nama: 'Silver',
      deskripsi: 'Akses ke semua alat gym dasar dan kelas kardio.',
      harga: 250000,
      gambar: [
        'assets/images/silver.png',
        'assets/images/gym_1.png',
        'assets/images/gym_2.png'
      ],
    ),
    Membership(
      id: '2',
      nama: 'Gold',
      deskripsi: 'Semua keuntungan Silver + akses ke kelas yoga dan pilates.',
      harga: 400000,
      gambar: [
        'assets/images/gold.png',
        'assets/images/gym_3.png',
        'assets/images/gym_4.png'
      ],
    ),
    Membership(
      id: '3',
      nama: 'Platinum',
      deskripsi: 'Semua keuntungan Gold + sesi personal trainer 2x sebulan.',
      harga: 650000,
      gambar: [
        'assets/images/platinum.png',
        'assets/images/gym_5.png',
        'assets/images/gym_6.png'
      ],
    ),
  ];

  Membership? _selectedMembership;
  Membership? _activeMembership;

  Membership? get selectedMembership => _selectedMembership;
  Membership? get activeMembership => _activeMembership;
  bool get isCartEmpty => _selectedMembership == null;

  void addToCart(Membership membership) {
    _selectedMembership = membership;
    notifyListeners();
  }

  void clearCart() {
    _selectedMembership = null;
    notifyListeners();
  }

  // === FUNGSI UTAMA YANG DIMODIFIKASI ===
  Future<void> setActiveMembership(Membership newPackage) async {
    _activeMembership = newPackage;
    _selectedMembership = null;
    notifyListeners();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // 1. AMBIL DATA LAMA DULU (Sebelum di-update)
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        String userName = userData?['name'] ?? 'User';
        String? oldPackageId = userData?['activeMembershipId'];
        String logDetail = '';

        // 2. LOGIKA PENENTUAN PESAN DETAIL
        if (oldPackageId == null || oldPackageId.isEmpty) {
          // Kasus: User belum punya paket sebelumnya
          logDetail = 'Mulai berlangganan paket ${newPackage.nama}';
        } else {
          // Kasus: User sudah punya paket (Ganti Paket/Upgrade/Downgrade)
          // Cari nama paket lama berdasarkan ID
          String oldPackageName = 'Paket Lama';
          try {
            final oldPackage =
                memberships.firstWhere((m) => m.id == oldPackageId);
            oldPackageName = oldPackage.nama;
          } catch (e) {
            oldPackageName = 'Unknown ($oldPackageId)';
          }

          if (oldPackageId == newPackage.id) {
            logDetail = 'Memperpanjang paket ${newPackage.nama}';
          } else {
            logDetail =
                'Ganti paket dari $oldPackageName ke ${newPackage.nama}';
          }
        }

        // 3. UPDATE DATA DI USER (Simpan paket baru)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'activeMembershipId': newPackage.id,
          'membershipUpdatedAt': FieldValue.serverTimestamp(),
        });

        // 4. SIMPAN LOG AKTIVITAS (Dengan detail yang sudah dibuat)
        await FirebaseFirestore.instance.collection('activity_logs').add({
          'type': 'UPGRADE',
          'userName': userName,
          'timestamp': FieldValue.serverTimestamp(),
          'detail': logDetail, // <--- Ini yang akan ditampilkan di admin
        });

        // 5. SIMPAN TRANSAKSI
        await FirebaseFirestore.instance.collection('transactions').add({
          'userId': user.uid,
          'itemName': 'Membership ${newPackage.nama}',
          'amount': newPackage.harga,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Error saving membership data: $e");
      }
    }
  }

  Future<void> loadActiveMembership() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          String? savedId = data?['activeMembershipId'];

          if (savedId != null) {
            try {
              _activeMembership =
                  memberships.firstWhere((m) => m.id == savedId);
              notifyListeners();
            } catch (e) {
              print("ID Membership tidak ditemukan di list lokal");
            }
          }
        }
      } catch (e) {
        print("Gagal load membership: $e");
      }
    }
  }

  void reset() {
    _activeMembership = null;
    _selectedMembership = null;
    notifyListeners();
  }
}
