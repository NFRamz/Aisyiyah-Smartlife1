import 'package:aisyiyah_smartlife/data/services/google_auth_service.dart';
import 'package:aisyiyah_smartlife/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LoginController extends GetxController {
  final supabase = Supabase.instance.client;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final failedAttempts = 0.obs;
  final lockoutUntil = Rxn<DateTime>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email dan password harus diisi", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Error", "Format email tidak valid (wajib mengandung @ dan domain)", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (lockoutUntil.value != null && DateTime.now().isBefore(lockoutUntil.value!)) {
      final remaining = lockoutUntil.value!.difference(DateTime.now()).inMinutes;
      final remainingSec = lockoutUntil.value!.difference(DateTime.now()).inSeconds % 60;
      Get.snackbar("Terblokir", "Terlalu banyak percobaan gagal. Silakan coba lagi dalam $remaining menit $remainingSec detik.", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password
      );

      if (response.user == null) throw const AuthException("User tidak ditemukan.");

      failedAttempts.value = 0;
      lockoutUntil.value = null;

      final profile = await supabase.from('profiles').select().eq('id', response.user!.id).maybeSingle();
      if (profile == null) throw const AuthException("Profil tidak ditemukan.");

      String fullName = "${profile['nama_depan']} ${profile['nama_belakang'] ?? ''}".trim();
      await _saveLoginStatus(profile['email'] ?? '', fullName, profile['role_id']?.toString() ?? 'anggota', profile['ranting_id']?.toString() ?? '', profile['daerah_id']?.toString() ?? '');

      Get.offAllNamed(Routes.HOME);
    } on AuthException catch (e) {
      failedAttempts.value++;
      if (failedAttempts.value >= 3) {
        lockoutUntil.value = DateTime.now().add(const Duration(minutes: 2));
        Get.snackbar("Terblokir", "3x Gagal login. Percobaan login ditangguhkan selama 2 menit.", backgroundColor: Colors.redAccent, colorText: Colors.white);
      } else {
        Get.snackbar("Gagal Login", "${e.message} (Percobaan: ${failedAttempts.value}/3)", backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan sistem.", backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // 1. Ambil Akun Google
      final googleUser = await _googleAuthService.signInWithGoogle();
      if (googleUser == null) return;

      // 2. Login ke Supabase
      final response = await _googleAuthService.loginToSupabase(googleUser);
      final user = response.user;
      if (user == null) throw 'Gagal autentikasi Supabase';

      // 3. Ambil data profil
      final profile = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();

      // 4. CEK KELENGKAPAN PROFIL (Skenario 3 & 4)
      // Gunakan nama_depan sebagai indikator apakah profil sudah dilengkapi atau belum
      bool isNewUser = profile == null || profile['nama_depan'] == "user" || profile['nama_depan'].toString().isEmpty;

      if (isNewUser) {
        Get.toNamed(Routes.SIGNUP, arguments: {
          'email': googleUser.email,
          'photoUrl': googleUser.photoUrl,
          'isGoogleAuth': true,
        });
      } else {
        // Sudah terdaftar lengkap
        String fullName = "${profile['nama_depan']} ${profile['nama_belakang'] ?? ''}".trim();
        await _saveLoginStatus(profile['email'] ?? '', fullName, profile['role_id']?.toString() ?? 'anggota', profile['ranting_id']?.toString() ?? '', profile['daerah_id']?.toString() ?? '');
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      Get.snackbar("Gagal Login", e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveLoginStatus(String email, String fullName, String role, String rantingId, String daerahId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('email', email);
    await prefs.setString('nama_pengguna', fullName);
    await prefs.setString('role', role);
    await prefs.setString('ranting_id', rantingId);
    await prefs.setString('daerah_id', daerahId);
  }

  void togglePasswordVisibility() => isPasswordVisible.value = !isPasswordVisible.value;
  void navigateToSignUp() => Get.toNamed(Routes.SIGNUP);
  void navigateToForgotPassword() => Get.toNamed(Routes.FORGOT_PASSWORD);

  @override
  void onClose() {
    super.onClose();
  }
}
