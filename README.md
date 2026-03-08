# MugenGym App 🏋️‍♂️

MugenGym adalah aplikasi mobile manajemen keanggotaan kebugaran (gym) yang dibangun menggunakan Flutter. Aplikasi ini memfasilitasi interaksi yang efisien antara pengelola gym (Admin) dan pelanggan (Member) dengan sistem otentikasi berbasis peran (Role-based Access).

## 🚀 Fitur Utama

### 👤 User (Member)
* **Otentikasi Aman:** Pendaftaran akun dan login.
* **Manajemen Profil:** Edit detail informasi dan unggah foto profil.
* **Transaksi Membership:** Pilih paket langganan dan proses *checkout*.
* **Akses Gym Digital:** Menampilkan QR Code unik untuk melakukan pembayaran secara digital.
* **Pusat Informasi:** Menerima pengumuman dan berita terbaru dari admin.

### 🛡️ Admin
* **Dashboard Terpusat:** Pantau operasional gym dari satu tempat.
* **Manajemen Member:** Lihat daftar anggota aktif dan fitur *force cancel* membership jika diperlukan.
* **Manajemen Konten:** Buat, edit, dan hapus berita/pengumuman untuk disiarkan ke member.
* **Pemantauan Sistem:** Lihat dan bersihkan riwayat aktivitas (Log Transaksi).

## 🛠️ Tech Stack
* **Framework:** [Flutter](https://flutter.dev/)
* **Backend:** [Firebase](https://firebase.google.com/)
  * Firebase Authentication (Manajemen User & Role)
  * Cloud Firestore (Database NoSQL Real-time)
  * Firebase Storage (Penyimpanan Foto Profil & Media)

---

## ⚙️ Persyaratan Sistem (Prerequisites)
Sebelum menjalankan project ini, pastikan Anda telah menginstal:
* Flutter SDK (Versi terbaru disarankan)
* Dart SDK
* Akun Firebase yang aktif

## 📥 Cara Instalasi & Menjalankan Project

**PENTING:** Project ini menggunakan Firebase, namun file konfigurasi rahasia (`google-services.json`, `GoogleService-Info.plist`, dan `firebase_options.dart`) **tidak disertakan** dalam repository ini demi alasan keamanan. Anda harus menghubungkan aplikasi ini dengan project Firebase Anda sendiri.

1. **Clone Repository ini:**
   ```bash
   git clone https://github.com/Kndy26/gym_member.git
   cd gym_member

2. **Install Dependencies:**
   ```bash
   flutter pub get

3. **Setup Firebase:**
   * Buat project baru di [Firebase Console](https://console.firebase.google.com/)
   * Aktifkan layanan Authentication (Email/Password), Firestore Database, dan Storage.
   * Buka terminal di folder root project ini dan jalankan perintah Firebase CLI:
        ```bash
        flutterfire configure
   * Perintah di atas akan otomatis mengenerate file `lib/firebase_options.dart` dan mengunduh file konfigurasi platform (seperti `google-services.json` untuk Android) ke dalam folder project Anda. 

4. **Jalankan Aplikasi:**
   ```bash
   flutter run