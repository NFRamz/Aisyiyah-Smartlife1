import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class FormDonasi_controller extends GetxController {
  final supabase = Supabase.instance.client;

  final namaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final nominalController = TextEditingController();
  
  var fixAmount = false.obs;
  var isLoading = false.obs;
  var selectedImage = Rxn<File>();
  var currentImageUrl = ''.obs;

  String? editId;

  @override
  void onInit() {
    super.onInit();
    // Ambil data dari arguments jika sedang mode EDIT
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      initFormData(Get.arguments);
    }
  }

  void initFormData(Map<String, dynamic>? data) {
    if (data != null) {
      editId = data['id'];
      namaController.text = data['nama'] ?? '';
      deskripsiController.text = data['deskripsi'] ?? '';
      nominalController.text = data['nominal']?.toString() ?? '0';
      fixAmount.value = data['fix_amount'] ?? false;
      currentImageUrl.value = data['gambar'] ?? '';
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  Future<void> saveDonasi() async {
    if (isLoading.value) return; // Mencegah double click
    
    if (namaController.text.isEmpty) {
      Get.snackbar("Peringatan", "Nama donasi wajib diisi", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "Sesi berakhir, silakan login kembali", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      String? imageUrl = currentImageUrl.value;

      // 1. Upload Image ke storage jika ada file baru
      if (selectedImage.value != null) {
        final file = selectedImage.value!;
        final fileExt = file.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = 'donasi/$fileName';

        await supabase.storage.from('donasi-gambar').upload(filePath, file);
        imageUrl = supabase.storage.from('donasi-gambar').getPublicUrl(filePath);
      }

      final data = {
        'nama': namaController.text,
        'deskripsi': deskripsiController.text,
        'nominal': double.tryParse(nominalController.text) ?? 0,
        'fix_amount': fixAmount.value,
        'gambar': imageUrl,
        'profiles_id': user.id,
      };

      if (editId != null) {
        await supabase.from('donasi_rk').update(data).eq('id', editId!);
      } else {
        await supabase.from('donasi_rk').insert(data);
      }

      // Berikan result TRUE agar halaman sebelumnya tahu ada perubahan data
      Get.back(result: true); 

      // Tampilkan snackbar setelah halaman tertutup agar tidak mengganggu Get.back()
      Get.snackbar(
        "Sukses", 
        editId != null ? "Program berhasil diperbarui" : "Program berhasil ditambahkan",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print("Error saveDonasi: $e");
      Get.snackbar("Error", "Gagal menyimpan data: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    deskripsiController.dispose();
    nominalController.dispose();
    super.onClose();
  }
}
