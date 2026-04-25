import 'dart:io';
import 'package:aisyiyah_smartlife/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileController extends GetxController {
  final supabase = Supabase.instance.client;
  final HomeController homeController = Get.find<HomeController>();

  // Text Controllers
  late TextEditingController firstNameC;
  late TextEditingController lastNameC;
  late TextEditingController emailC;
  late TextEditingController phoneC;
  late TextEditingController oldPassC;
  late TextEditingController newPassC;

  // State
  var isLoading = false.obs;
  var imagePath = ''.obs;
  File? imageFile;

  // Data awal untuk deteksi perubahan
  String? _initialEmail;
  var currentPhotoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi controller
    firstNameC = TextEditingController();
    lastNameC = TextEditingController();
    emailC = TextEditingController();
    phoneC = TextEditingController();
    oldPassC = TextEditingController();
    newPassC = TextEditingController();

    // Load data langsung dari database agar akurat
    fetchFreshProfileData();
  }

  @override
  void onClose() {
    firstNameC.dispose();
    lastNameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    oldPassC.dispose();
    newPassC.dispose();
    super.onClose();
  }

  // --- H. LOAD DATA DARI SUPABASE ---
  Future<void> fetchFreshProfileData() async {
    isLoading.value = true;
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Ambil data raw dari tabel profiles untuk pre-fill
      final data = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();

      if (data != null) {
        firstNameC.text = data['nama_depan'] ?? '';
        lastNameC.text = data['nama_belakang'] ?? '';
        phoneC.text = data['no_telepon'] ?? '';
        emailC.text = data['email'] ?? user.email ?? '';
        currentPhotoUrl.value = data['foto_profile']?? '';
        _initialEmail = emailC.text;
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data profil", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --- A. IMAGE PICKER & COMPRESS (< 150KB) ---
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Logic Kompresi
      final dir = File(pickedFile.path).parent.path;
      final targetPath = "$dir/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg";
      var result2 = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        quality: 40,
        minWidth: 400,
        minHeight: 400,
      );
      imageFile = File(result2!.path);
      imagePath.value = result2.path;
    }
    }


  // --- LOGIC UTAMA SIMPAN ---
  Future<void> saveProfile() async {
    // 1. VALIDASI INPUT
    if (firstNameC.text.trim().isEmpty || emailC.text.trim().isEmpty) {
      Get.snackbar("Gagal", "Nama, Email, dan Telepon wajib diisi", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (!GetUtils.isEmail(emailC.text.trim())) {
      Get.snackbar("Gagal", "Email tidak valid", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw "Sesi berakhir, silakan login ulang.";

      // 2. CEK & VALIDASI PASSWORD (Jika diisi)
      String? newPasswordToUpdate;
      if (newPassC.text.isNotEmpty) {
        String newPass = newPassC.text;
        String oldPass = oldPassC.text;

        if (newPass.length < 6) throw "Password baru minimal 6 karakter.";
        if (oldPass.isEmpty) throw "Masukkan password lama untuk konfirmasi.";

        // Verifikasi Password Lama
        try {
          await supabase.auth.signInWithPassword(email: user.email!, password: oldPass);
        } catch (_) {
          throw "Password lama salah.";
        }
        newPasswordToUpdate = newPass;
      }

      // 3. UPLOAD FOTO (Jika ada)
      String photoUrl = currentPhotoUrl.value; // Default pakai yang lama

      if (imageFile != null) {
        final fileName = '${user.id}.jpg'; // Static filename (UUID)

        // Upload dengan UPSERT (Timpa file lama)
        await supabase.storage.from('Profiles_photo').upload(
          fileName,
          imageFile!,
          fileOptions: const FileOptions(upsert: true),
        );

        // Cache Busting URL
        final baseUrl = supabase.storage.from('Profiles_photo').getPublicUrl(fileName);
        photoUrl = "$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}";
      }

      // 4. UPDATE DATA PROFIL (Tabel Public)
      await supabase.from('profiles').update({
        'nama_depan': firstNameC.text.trim(),
        'nama_belakang': lastNameC.text.trim(),
        'no_telepon': phoneC.text.trim(),
        'email': emailC.text.trim(), // Tetap update email di tabel public
        'foto_profile': photoUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      // 5. UPDATE AUTH (Email & Password) - PERBAIKAN LOGIC DISINI
      final currentEmail = user.email;
      final newEmailInput = emailC.text.trim();

      String? emailToUpdate;

      // Cek apakah email berubah
      if (currentEmail != newEmailInput) {
        emailToUpdate = newEmailInput;
      }

      // Jalankan Update Auth HANYA jika ada perubahan Email ATAU Password
      if (emailToUpdate != null || newPasswordToUpdate != null) {
        final attributes = UserAttributes(
          email: emailToUpdate,      // Akan null jika email tidak berubah (aman)
          password: newPasswordToUpdate, // Akan null jika password tidak berubah (aman)
        );

        await supabase.auth.updateUser(attributes);

        Get.snackbar("Akun Diperbarui",
            "Data tersimpan. ${emailToUpdate != null ? 'Silakan cek email baru Anda untuk konfirmasi.' : ''}",
            backgroundColor: Colors.orange, colorText: Colors.white, duration: const Duration(seconds: 4));
      } else {
        Get.snackbar("Sukses", "Data profil berhasil diperbarui",
            backgroundColor: Colors.green, colorText: Colors.white);
      }

      homeController.fetchUserData();
      Get.back();

    } catch (e) {
      // Menangani error spesifik Storage
      String msg = e.toString();
      if (msg.contains("403")) {
        msg = "Gagal upload foto: Izin ditolak. Coba logout dan login kembali.";
      }
      Get.snackbar("Gagal", msg.replaceAll("Exception:", "").trim(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}