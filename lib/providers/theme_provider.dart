import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // --- DEFINISI TEMA ---

  // 1. TEMA TERANG (Light Mode)
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF8AC6D1),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Abu muda
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF8AC6D1),
      foregroundColor: Colors.white, // Warna teks/icon AppBar
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8AC6D1),
      secondary: Colors.amber,
      surface: Colors.white,
    ),
    cardColor: Colors.white,
  );

  // 2. TEMA GELAP (Dark Mode)
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF8AC6D1),
    scaffoldBackgroundColor: const Color(0xFF121212), // Hitam pekat
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F), // Abu tua
      foregroundColor: Color(0xFF8AC6D1), // Warna teks jadi biru pastel
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8AC6D1),
      secondary: Colors.amber,
      surface: Color(0xFF1E1E1E), // Warna kartu di mode gelap
    ),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: Colors.grey[800],
  );
}
