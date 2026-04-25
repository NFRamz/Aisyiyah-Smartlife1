import 'package:aisyiyah_smartlife/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LoginController extends GetxController {
  final supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> handleLogin() async {
    // Validasi input sederhana
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Email dan password harus diisi", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      // 1. Login Auth
      final response = await supabase.auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
      );

      if (response.user == null) {
        throw const AuthException("Login gagal. User tidak ditemukan.");
      }

      // 2. Ambil Profile (Sesuai Tabel Baru)
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (profile == null) {
        throw const AuthException("Profil user tidak ditemukan. Pastikan data tabel profiles sudah terisi.");
      }

      // 3. Olah Data (Sesuaikan kolom database baru ke variabel aplikasi)

      // Gabungkan Nama Depan + Belakang
      String fullName = "${profile['nama_depan']} ${profile['nama_belakang'] ?? ''}".trim();

      // Ambil ID lokasi (pakai ?.toString() karena tipe di DB adalah UUID/Nullable)
      String rantingId = profile['ranting_id']?.toString() ?? '';
      String daerahId = profile['daerah_id']?.toString() ?? '';
      String role = profile['role']?.toString() ?? 'anggota';
      String email = profile['email']?.toString() ?? '';

      // 4. Simpan ke SharedPreferences
      await _saveLoginStatus(email, fullName, role, rantingId, daerahId);

      Get.offAllNamed(Routes.HOME);

    } on AuthException catch (e) {
      String message = e.message;
      if (message.contains("Invalid login credentials")) message = "Email atau password salah.";
      Get.snackbar("Gagal Login", message, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      print("Error Login");
      Get.snackbar("Error", "Terjadi kesalahan sistem.", backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> _saveLoginStatus(String email, String namaLengkap, String role, String rantingId, String daerahId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('email', email);

    await prefs.setString('nama_pengguna', namaLengkap);
    await prefs.setString('role', role);

    //Yang disimpan sekarang adalah ID (UUID), bukan nama tempat.
    await prefs.setString('ranting_id', rantingId);
    await prefs.setString('daerah_id', daerahId);
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void navigateToSignUp() {
    Get.toNamed('/signup');
  }

  //untuk mode tamu
  void navigateToMyQuran() {
    loginWithGuestMode();
    Get.toNamed(Routes.MY_QURAN );
  }
  void loginWithGuestMode()async{
    SharedPreferences sp =await SharedPreferences.getInstance();
    sp.setBool("isLoggedIn", true);


  }


  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}