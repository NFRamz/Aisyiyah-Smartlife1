import 'dart:io';
import 'package:aisyiyah_smartlife/modules/umkm/controllers/KelolaUmkm_controller.dart';
import 'package:aisyiyah_smartlife/modules/umkm/model/Umkm_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class FormUmkmController extends GetxController {
  final supabase = Supabase.instance.client;

  // Mengambil referensi controller induk untuk mendapatkan ID Cabang/Ranting user
  final KelolaUmkm_controller parentController = Get.find<KelolaUmkm_controller>();

  TextEditingController namaController = TextEditingController();
  TextEditingController mapsLinkController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();

  final Map<String, TextEditingController> socialControllers = {
    'whatsapp': TextEditingController(),
    'instagram': TextEditingController(),
    'facebook': TextEditingController(),
    'tiktok': TextEditingController(),
    'website': TextEditingController(),
    'youtube': TextEditingController(),
    'twitter': TextEditingController(),
  };

  Rx<File?> selectedImage = Rx<File?>(null);
  RxString currentImageUrl = "".obs;
  var isLoading = false.obs;

  final RxMap<String, bool> selectedSocials = <String, bool>{
    'whatsapp': false,
    'instagram': false,
    'facebook': false,
    'tiktok': false,
    'website': false,
    'youtube': false,
    'twitter': false,
  }.obs;

  Umkm_model? editingUmkm;

  void initFormData(Umkm_model? data) {
    if (data != null) {
      editingUmkm = data;
      namaController.text = data.nama;
      deskripsiController.text = data.deskripsi ?? "";
      mapsLinkController.text = data.mapsLink ?? "";
      currentImageUrl.value = data.gambar ?? "";

      // Load Social Media Data dari kolom 'social_media'
      if (data.socialMedia != null) {
        data.socialMedia!.forEach((key, value) {
          if (socialControllers.containsKey(key)) {
            socialControllers[key]!.text = value.toString();
            selectedSocials[key] = true;
          }
        });
      }
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final img = await picker.pickImage(source: source, imageQuality: 70);
      if (img != null) {
        selectedImage.value = File(img.path);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memilih gambar");
    }
  }

  Future<void> saveUmkm() async {
    if (namaController.text.isEmpty) {
      Get.snackbar("Validasi", "Nama UMKM wajib diisi");
      return;
    }

    isLoading.value = true;
    try {
      String? finalImageUrl = editingUmkm?.gambar;

      if (selectedImage.value != null) {
        final fileName = "umkm/${DateTime.now().millisecondsSinceEpoch}.jpg";
        await supabase.storage.from('umkm-gambar').upload(fileName, selectedImage.value!);
        finalImageUrl = supabase.storage.from('umkm-gambar').getPublicUrl(fileName);
      }

      // Prepare JSONB map
      Map<String, String> sosmedData = {};
      selectedSocials.forEach((key, isActive) {
        if (isActive && socialControllers[key]!.text.isNotEmpty) {
          sosmedData[key] = socialControllers[key]!.text;
        }
      });

      // Ambil data profil terbaru
      final user = supabase.auth.currentUser;
      final profile = await supabase
          .from('profiles')
          .select('cabang_id, ranting_id')
          .eq('id', user!.id)
          .single();

      String? cabangId = profile['cabang_id'];
      String? rantingId = profile['ranting_id'];

      // Logika: Jika ranting yang membuat, pastikan cabang_id terisi dari tabel ranting
      if (rantingId != null && cabangId == null) {
        final rantingData = await supabase
            .from('ranting')
            .select('cabang_id')
            .eq('id', rantingId)
            .single();
        cabangId = rantingData['cabang_id'];
      }

      final dataToSave = {
        "nama": namaController.text,
        "deskripsi": deskripsiController.text,
        "maps_link": mapsLinkController.text,
        "gambar": finalImageUrl,
        "social_media": sosmedData,
        "cabang_id": cabangId,
        "ranting_id": rantingId,
      };

      if (editingUmkm != null) {
        await supabase.from('umkm').update(dataToSave).eq('id', editingUmkm!.id);
      } else {
        await supabase.from('umkm').insert(dataToSave);
      }

      // 1. Tutup halaman terlebih dahulu agar tidak tertahan oleh Snackbar
      Get.back(result: true);

      // 2. Tampilkan feedback sukses setelah halaman tertutup
      Get.snackbar(
        "Sukses", 
        "Data berhasil disimpan", 
        backgroundColor: Colors.green, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      print("Error Save UMKM: $e");
      Get.snackbar("Error", "Gagal menyimpan data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    mapsLinkController.dispose();
    deskripsiController.dispose();
    for (var c in socialControllers.values) c.dispose();
    super.onClose();
  }
}