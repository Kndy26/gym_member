// lib/screens/help_support_screens.dart

import 'package:flutter/material.dart';

// ==========================================
// 1. HALAMAN PUSAT BANTUAN (FAQ)
// ==========================================
class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Pusat Bantuan (FAQ)'),
        backgroundColor: const Color(0xFF8AC6D1),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FAQTile(
            question: 'Bagaimana cara mendaftar membership?',
            answer:
                'Anda dapat memilih paket membership di halaman Home, klik "Pilih Membership", lalu selesaikan pembayaran melalui metode yang tersedia (Tunai/QRIS).',
          ),
          _FAQTile(
            question: 'Apakah saya bisa membatalkan membership?',
            answer:
                'Pembatalan membership saat ini hanya dapat dilakukan dengan menghubungi Admin atau datang langsung ke meja resepsionis MuGenGym.',
          ),
          _FAQTile(
            question: 'Apa perbedaan paket Silver, Gold, dan Platinum?',
            answer:
                'Silver: Akses gym dasar.\nGold: Akses gym + Kelas Yoga.\nPlatinum: Akses gym + Yoga + Personal Trainer 2x/bulan.',
          ),
          _FAQTile(
            question: 'Bagaimana cara mengubah profil saya?',
            answer:
                'Pergi ke menu Profile, lalu ubah data yang diinginkan dan klik "Simpan Perubahan". Email tidak dapat diubah.',
          ),
          _FAQTile(
            question: 'Saya lupa password, apa yang harus dilakukan?',
            answer:
                'Silahkan beralih ke halaman Ganti Password pada halaman Settings, atau bisa langsung menuju ke halaman profil. Jika aplikasi sedang tidak dalam kondisi login, silakan hubungi Admin untuk melakukan reset password akun Anda.',
          ),
        ],
      ),
    );
  }
}

class _FAQTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN SYARAT & KETENTUAN
// ==========================================
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Syarat & Ketentuan'),
        backgroundColor: const Color(0xFF8AC6D1),
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('1. Pendahuluan'),
            _SectionText(
                'Selamat datang di aplikasi MuGenGym. Dengan menggunakan aplikasi ini, Anda setuju untuk mematuhi syarat dan ketentuan berikut.'),
            _SectionTitle('2. Keanggotaan'),
            _SectionText(
                'Keanggotaan bersifat pribadi dan tidak dapat dipindahtangankan. Member wajib mematuhi aturan etika dan keselamatan di area gym.'),
            _SectionTitle('3. Pembayaran'),
            _SectionText(
                'Pembayaran membership dilakukan di muka. Kami menerima pembayaran Tunai dan QRIS. Biaya yang sudah dibayarkan tidak dapat dikembalikan (non-refundable).'),
            _SectionTitle('4. Pembatalan'),
            _SectionText(
                'Pihak MuGenGym berhak membatalkan keanggotaan jika ditemukan pelanggaran berat terhadap aturan gym.'),
            _SectionTitle('5. Perubahan Layanan'),
            _SectionText(
                'MuGenGym berhak mengubah jam operasional, fasilitas, dan harga paket sewaktu-waktu dengan pemberitahuan sebelumnya.'),
            SizedBox(height: 30),
            Center(
                child: Text('Terakhir diperbarui: Desember 2025',
                    style: TextStyle(color: Colors.grey, fontSize: 12))),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. HALAMAN KEBIJAKAN PRIVASI
// ==========================================
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
        backgroundColor: const Color(0xFF8AC6D1),
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('1. Pengumpulan Data'),
            _SectionText(
                'Kami mengumpulkan informasi pribadi berupa Nama, Email, Nomor Telepon, dan Jenis Kelamin untuk keperluan administrasi membership.'),
            _SectionTitle('2. Penggunaan Data'),
            _SectionText(
                'Data Anda digunakan untuk memproses transaksi, mengirimkan informasi tagihan, dan memberikan update seputar layanan gym.'),
            _SectionTitle('3. Keamanan Data'),
            _SectionText(
                'Kami berkomitmen menjaga keamanan data Anda. Kami tidak akan menjual atau membagikan data pribadi Anda kepada pihak ketiga tanpa izin, kecuali diwajibkan oleh hukum.'),
            _SectionTitle('4. Akses Kamera & Galeri'),
            _SectionText(
                'Aplikasi membutuhkan akses ke galeri foto Anda hanya untuk keperluan mengunggah foto profil.'),
            SizedBox(height: 30),
            Center(
                child: Text('MuGenGym Privacy Policy © 2025',
                    style: TextStyle(color: Colors.grey, fontSize: 12))),
          ],
        ),
      ),
    );
  }
}

// Helper Widget untuk Text Judul & Isi
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87)),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style:
            const TextStyle(height: 1.5, color: Colors.black54, fontSize: 14),
        textAlign: TextAlign.justify);
  }
}
