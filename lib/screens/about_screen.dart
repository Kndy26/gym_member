import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF8AC6D1);
    const backgroundColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // LAYER 1: BACKGROUND MELENGKUNG (Paling Bawah)
          Container(
            height: 260,
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),

          // LAYER 2: KONTEN UTAMA (Scrollable)
          // Dipindah ke sini agar berada di BELAKANG tombol back,
          // tapi di DEPAN background.
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  24, 140, 24, 24), // Sesuaikan top padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                      height: 0), // Spasi tambahan agar tidak nabrak header
                  // --- LOGO & BRANDING ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      size: 60,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'MUGENGYM',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Text(
                    'Versi 1.0.0 (Beta)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Mitra Sehat Anda",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'MuGenGym adalah aplikasi pendaftaran membership gym modern yang memudahkan Anda untuk memulai perjalanan hidup sehat. Kami menyediakan berbagai paket membership yang sesuai dengan kebutuhan Anda.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Bergabunglah dengan komunitas kami dan wujudkan target kebugaran Anda bersama pelatih profesional dan fasilitas terbaik.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                  Column(
                    children: [
                      Text(
                        'Created by Group 7 :',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),

                      _buildMemberText('Kennedy Wang', '32230119'),
                      _buildMemberText('Dharma Tri Sanjaya', '32230120'),
                      _buildMemberText('Darren Daniel', '32230138'),

                      const SizedBox(height: 12),

                      Text(
                        'Universitas Bunda Mulia',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 4),
                      Text(
                        '© 2025 MuGenGym Project, All rights reserved.',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // LAYER 3: HEADER (Tombol Back & Judul) - PALING ATAS (Agar bisa diklik)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Tombol Kembali
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Judul Halaman
                    Text(
                      'Tentang Kami',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
Widget _buildMemberText(String name, String nim) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(
      '$name ($nim)',
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
