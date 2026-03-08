// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
// 1. Tambahkan import ini
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'providers/membership_provider.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/cart.dart';
import 'screens/admin_dashboard.dart';

// 2. Ubah main menjadi async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Inisialisasi format tanggal untuk bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => MembershipProvider(),
      child: MaterialApp(
        title: 'MuGenGym',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          // Opsional: Set font global jika mau
          // textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        initialRoute: '/',
        routes: {
          '/': (ctx) => const LoginScreen(),
          '/home': (ctx) => const HomeScreen(),
          '/cart': (ctx) => const CartScreen(),
          '/admin_dashboard': (ctx) => const AdminDashboard(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
