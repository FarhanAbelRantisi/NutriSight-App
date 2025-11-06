import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;

  bool isLoading = false;

  AuthViewModel(this._repo);

  Future<UserCredential?> signInWithEmail(
      String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email dan password tidak boleh kosong.");
    }

    try {
      isLoading = true;
      notifyListeners();

      final cred = await _repo.signInWithEmail(
        email.trim(),
        password.trim(),
      );
      return cred;
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan.";
      if (e.code == 'user-not-found') {
        message = 'Tidak ada pengguna yang ditemukan untuk email tersebut.';
      } else if (e.code == 'wrong-password') {
        message = 'Password yang dimasukkan salah.';
      }
      throw Exception(message);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (password != confirmPassword) {
      throw Exception("Password tidak cocok.");
    }
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email dan password tidak boleh kosong.");
    }

    try {
      isLoading = true;
      notifyListeners();

      final cred = await _repo.registerWithEmail(
        email.trim(),
        password.trim(),
      );
      return cred;
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan.";
      if (e.code == 'weak-password') {
        message = 'Password terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email sudah digunakan oleh akun lain.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
      }
      throw Exception(message);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      isLoading = true;
      notifyListeners();

      final cred = await _repo.signInWithGoogle();
      return cred;
    } catch (e) {
      throw Exception("Error signing in with Google: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
