// lib/screens/home.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:intl/intl.dart';

import '../models/membership.dart';
import '../providers/membership_provider.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'inbox_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MembershipProvider>(context, listen: false)
          .loadActiveMembership();
    });
  }

  @override
  Widget build(BuildContext context) {
    final membershipProvider = Provider.of<MembershipProvider>(context);
    final List<Membership> memberships = membershipProvider.memberships;

    String dateNow =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: _buildUserDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // === 1. SMART SLIVER APP BAR ===
          StreamBuilder<DocumentSnapshot>(
              stream: _currentUser != null
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .doc(_currentUser!.uid)
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                String userName = 'User';
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.exists) {
                  userName = snapshot.data!.get('name') ?? 'User';
                }

                return SliverAppBar(
                  backgroundColor: const Color(0xFF8AC6D1),
                  // KITA PERBESAR SEDIKIT LAGI EXPANED HEIGHTNYA AGAR LEGA
                  expandedHeight: 220.0,
                  pinned: true,
                  stretch: true,
                  elevation: 0,
                  leading: null,
                  automaticallyImplyLeading: false,

                  // Isi Header
                  flexibleSpace: Stack(
                    children: [
                      // LAYER 1: Background & Title Animation
                      FlexibleSpaceBar(
                        stretchModes: const [
                          StretchMode.zoomBackground,
                          StretchMode.blurBackground,
                        ],
                        centerTitle: false,
                        titlePadding:
                            const EdgeInsets.only(left: 70, bottom: 20),
                        // Title ini yang akan menyusut dan tetap ada
                        title: Text(
                          'Halo, $userName!',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        // Background ini yang akan hilang saat discroll
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 1. Gambar Background Pudar
                            Image.asset(
                              'assets/images/gym_1.png',
                              fit: BoxFit.cover,
                              opacity: const AlwaysStoppedAnimation(0.15),
                            ),
                            // 2. Gradient
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF8AC6D1).withOpacity(0.8)
                                  ],
                                ),
                              ),
                            ),

                            // === [BARU] NAMA GYM BESAR DI ATAS ===
                            // Ditaruh di sini agar ikut hilang saat discroll
                            Positioned(
                              top: 50,
                              left: 70,
                              child: Text(
                                'MUGENGYM',
                                style: GoogleFonts.bebasNeue(
                                    fontSize: 70, // Ukuran besar
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing:
                                        2.0, // Jarak antar huruf biar keren
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Positioned(
                              bottom: 80,
                              left: 70,
                              child: Text(
                                'Multi Generational Gym',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                            ),
                            // 4. Tanggal (di bawah sapaan)
                            Positioned(
                              bottom: 50,
                              left: 70,
                              child: Text(
                                dateNow,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // LAYER 2: Tombol Menu & Cart (Selalu di Tengah Vertikal)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Tombol Hamburger (Kiri)
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 20,
                                child: IconButton(
                                  icon: const Icon(Icons.menu,
                                      color: Color(0xFF8AC6D1), size: 20),
                                  onPressed: () =>
                                      _scaffoldKey.currentState!.openDrawer(),
                                ),
                              ),

                              // Tombol Cart (Kanan)
                              CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                radius: 20,
                                child: IconButton(
                                  icon: const Icon(Icons.shopping_cart,
                                      color: Colors.white, size: 20),
                                  onPressed: () async {
                                    final result = await Navigator.pushNamed(
                                        context, '/cart');
                                    if (result == 'checkout_success' &&
                                        context.mounted) {
                                      showSuccessDialog(context);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

          // === 2. ISI KONTEN (Membership List) ===
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return MembershipCard(membership: memberships[index]);
                },
                childCount: memberships.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === DRAWER (Tidak berubah) ===
  Widget _buildUserDrawer() {
    return Drawer(
      child: StreamBuilder<DocumentSnapshot>(
        // 1. STREAM USER (PEMBUNGKUS UTAMA)
        stream: _currentUser != null
            ? FirebaseFirestore.instance
                .collection('users')
                .doc(_currentUser!.uid)
                .snapshots()
            : null,
        builder: (context, snapshot) {
          // --- DEFINISI VARIABEL DI SINI AGAR BISA DIPAKAI DI BAWAH ---
          String displayName = 'User';
          String? photoUrl;
          String? activeMembershipId;
          Timestamp?
              lastCheckedInbox; // <--- Variabel ini didefinisikan di sini

          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            displayName = data['name'] ?? 'User';
            photoUrl = data['photoUrl'];
            activeMembershipId = data['activeMembershipId'];
            lastCheckedInbox =
                data['lastCheckedInbox']; // <--- Diisi datanya di sini
          }

          bool hasValidPhoto = photoUrl != null && photoUrl.isNotEmpty;

          // Logika Badge Membership
          String badgeLabel = '';
          Color badgeBgColor = Colors.transparent;
          Color badgeTextColor = Colors.transparent;
          bool hasBadge = false;

          if (activeMembershipId == '1') {
            badgeLabel = 'SILVER';
            badgeBgColor = Colors.grey.shade200;
            badgeTextColor = Colors.grey.shade800;
            hasBadge = true;
          } else if (activeMembershipId == '2') {
            badgeLabel = 'GOLD';
            badgeBgColor = const Color(0xFFFFF9C4);
            badgeTextColor = const Color(0xFFFBC02D);
            hasBadge = true;
          } else if (activeMembershipId == '3') {
            badgeLabel = 'PLATINUM';
            badgeBgColor = const Color(0xFFE1BEE7);
            badgeTextColor = const Color(0xFF8E24AA);
            hasBadge = true;
          }

          // Return ListView DI DALAM Builder User agar variabel lastCheckedInbox terbaca
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // HEADER
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF8AC6D1)),
                accountName: Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasBadge) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: badgeTextColor.withOpacity(0.3),
                              width: 0.5),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                accountEmail: Text(_currentUser?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage:
                      hasValidPhoto ? NetworkImage(photoUrl!) : null,
                  child: !hasValidPhoto
                      ? Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              fontSize: 24, color: Color(0xFF8AC6D1)))
                      : null,
                ),
              ),

              // MENU ITEMS
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF4A4A4A)),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()));
                },
              ),

              // === 2. STREAM NEWS (NESTED DI DALAM BUILDER USER) ===
              StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance.collection('news').snapshots(),
                  builder: (context, newsSnapshot) {
                    int unreadCount = 0;

                    if (newsSnapshot.hasData) {
                      final allNews = newsSnapshot.data!.docs;
                      for (var doc in allNews) {
                        final data = doc.data() as Map<String, dynamic>;
                        final Timestamp? createdAt = data['createdAt'];
                        final targetId = data['targetUserId'];

                        bool isRelevant = targetId == 'all' ||
                            targetId == null ||
                            targetId == _currentUser?.uid;

                        if (isRelevant && createdAt != null) {
                          // Di sini kita mengakses variabel 'lastCheckedInbox' dari scope di atas
                          if (lastCheckedInbox == null) {
                            unreadCount++;
                          } else if (createdAt.compareTo(lastCheckedInbox) >
                              0) {
                            unreadCount++;
                          }
                        }
                      }
                    }

                    return ListTile(
                      leading:
                          const Icon(Icons.inbox, color: Color(0xFF4A4A4A)),
                      title: const Text('Inbox'),
                      trailing: unreadCount > 0
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const InboxScreen()));
                      },
                    );
                  }),

              ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFF4A4A4A)),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Color(0xFF4A4A4A)),
                title: const Text('About Us'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Provider.of<MembershipProvider>(context, listen: false)
                      .reset();
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// Dialog Sukses
void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Pembayaran Berhasil'),
      content: const Text('Terima kasih, pesanan telah kami terima.'),
      actions: <Widget>[
        TextButton(
            child: const Text('OK'), onPressed: () => Navigator.of(ctx).pop()),
      ],
    ),
  );
}

// === KARTU MEMBERSHIP ===
class MembershipCard extends StatelessWidget {
  final Membership membership;

  const MembershipCard({super.key, required this.membership});

  @override
  Widget build(BuildContext context) {
    final membershipProvider = Provider.of<MembershipProvider>(context);
    final isCurrentPackage =
        membershipProvider.activeMembership?.id == membership.id;

    final List<Image> imageSliders = membership.gambar
        .map((path) => Image.asset(
              path,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.image_not_supported, size: 50)),
            ))
        .toList();

    return Card(
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: AnotherCarousel(
              images: imageSliders.map((image) => image.image).toList(),
              dotSize: 6,
              dotBgColor: Colors.transparent,
              dotIncreasedColor: const Color(0xFF8AC6D1),
              indicatorBgPadding: 5.0,
              autoplay: true,
              autoplayDuration: const Duration(seconds: 4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(membership.nama,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(membership.deskripsi,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                const SizedBox(height: 12),
                Text('Rp ${membership.harga.toString()},- / bulan',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8AC6D1))),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isCurrentPackage
                      ? null
                      : () async {
                          Provider.of<MembershipProvider>(context,
                                  listen: false)
                              .addToCart(membership);
                          final result =
                              await Navigator.pushNamed(context, '/cart');
                          if (result == 'checkout_success' && context.mounted) {
                            showSuccessDialog(context);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrentPackage
                        ? Colors.grey
                        : const Color(0xFF8AC6D1),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: Text(
                      isCurrentPackage ? 'Paket Saat Ini' : 'Pilih Membership'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
