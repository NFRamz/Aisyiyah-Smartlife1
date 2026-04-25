import 'package:aisyiyah_smartlife/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUp_controller extends GetxController {
  final supabase = Supabase.instance.client;

  // --- CONTROLLERS ---
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // --- VARIABLES ---
  // Role ID dihapus karena otomatis dihandle Database Trigger
  final selectedWilayahId = RxnString();
  final selectedDaerahId = RxnString();
  final selectedCabangId = RxnString();
  final selectedRantingId = RxnString();

  // --- LIST DATA ---
  // Role List dihapus
  final wilayahList = <Map<String, dynamic>>[].obs;
  final daerahList = <Map<String, dynamic>>[].obs;
  final cabangList = <Map<String, dynamic>>[].obs;
  final rantingList = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final isRegionLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  void fetchInitialData() {
    // Tidak perlu fetchRoles() lagi
    fetchWilayah();
  }

  // --- FETCH FUNCTIONS ---

  Future<void> fetchWilayah() async {
    try {
      final response = await supabase.from('wilayah').select('id, provinsi').order('provinsi');
      wilayahList.value = List<Map<String, dynamic>>.from(response);
    } catch (e) { print("Error wilayah: $e"); }
  }

  Future<void> fetchDaerah(String wilayahId) async {
    try {
      isRegionLoading.value = true;
      selectedDaerahId.value = null; selectedCabangId.value = null; selectedRantingId.value = null;
      cabangList.clear(); rantingList.clear();
      final response = await supabase.from('daerah').select('id, daerah').eq('wilayah_id', wilayahId).order('daerah');
      daerahList.value = List<Map<String, dynamic>>.from(response);
    } catch (e) { print("Error daerah: $e"); } finally { isRegionLoading.value = false; }
  }

  Future<void> fetchCabang(String daerahId) async {
    try {
      isRegionLoading.value = true;
      selectedCabangId.value = null; selectedRantingId.value = null;
      rantingList.clear();
      final response = await supabase.from('cabang').select('id, cabang').eq('daerah_id', daerahId).order('cabang');
      cabangList.value = List<Map<String, dynamic>>.from(response);
    } catch (e) { print("Error cabang: $e"); } finally { isRegionLoading.value = false; }
  }

  Future<void> fetchRanting(String cabangId) async {
    try {
      isRegionLoading.value = true;
      selectedRantingId.value = null;
      final response = await supabase.from('ranting').select('id, ranting').eq('cabang_id', cabangId).order('ranting');
      rantingList.value = List<Map<String, dynamic>>.from(response);
    } catch (e) { print("Error ranting"); } finally { isRegionLoading.value = false; }
  }

  // --- LOGIC PENDAFTARAN (LANGSUNG / TANPA OTP) ---

  Future<void> handleSignUp() async {
    if (firstNameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty || selectedWilayahId.value == null || selectedDaerahId.value == null || selectedCabangId.value == null) {
      Get.snackbar('Data Belum Lengkap', 'Mohon isi data wajib (Nama, Email, Password, Wilayah).',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Konfirmasi password tidak cocok.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final email = emailController.text.trim();

      // 1. CEK WHITELIST
      final checkData = await supabase.from('register').select('email').eq('email', email).maybeSingle();
      if (checkData == null) throw "Email Tertolak (ERR:SignV104)";

      // 2. SIGN UP LANGSUNG
      // Kirim metadata lokasi. Role tidak perlu dikirim karena trigger DB akan set ke 'anggota'.
      await supabase.auth.signUp(
          email: email,
          password: passwordController.text.trim(),
          data: {
            'nama_depan': firstNameController.text.trim(),
            'nama_belakang': lastNameController.text.trim(),
            'no_telepon': phoneController.text.trim(),
            'wilayah_id': selectedWilayahId.value,
            'daerah_id': selectedDaerahId.value,
            'cabang_id': selectedCabangId.value,
            'ranting_id': selectedRantingId.value,
          }
      );

      // 3. SUKSES
      Get.toNamed(Routes.LOGIN);
      Get.snackbar('Sukses', 'Akun berhasil dibuat! Selamat datang.', backgroundColor: Colors.green, colorText: Colors.white);

    } on AuthException catch (e) {
      Get.snackbar('Gagal Registrasi', e.message, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceAll("Exception:", "").trim(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose(); lastNameController.dispose();
    emailController.dispose(); phoneController.dispose();
    passwordController.dispose(); confirmPasswordController.dispose();
    super.onClose();
  }
}