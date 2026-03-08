// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'user',
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 1. Simpan Data User
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'name': name,
        'email': email,
        'role': role,
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. [BARU] Simpan Log Aktivitas 'REGISTER'
      await _firestore.collection('activity_logs').add({
        'type': 'REGISTER',
        'userName': name,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> getUserRole() async {
    if (currentUser != null) {
      final doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      return doc.data()?['role'] ?? 'user';
    }
    return 'user';
  }
}
