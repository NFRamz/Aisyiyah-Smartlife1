import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/KegiatanModel.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailKegiatanController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var getOne_kegiatan = Rxn<KegiatanModel>(); // Menyimpan satu data kegiatan

  @override
  void onInit() {
    super.onInit();
    // Ambil ID dari argumen navigasi (dari notifikasi atau list)
    final String? idFromArgs = Get.arguments;
    if (idFromArgs != null) {
      fetchDetailKegiatan(idFromArgs);
    }
  }

  Future<void> fetchDetailKegiatan(String id) async {
    isLoading.value = true;
    try {
      final response = await supabase
          .from('kegiatan')
          .select('*, wilayah:wilayah_id(nama), daerah:daerah_id(nama), cabang:cabang_id(nama), ranting:ranting_id(nama)')
          .eq('id', id)
          .single(); // Mengambil satu data saja

      if (response != null) {
        // Gunakan factory fromJson yang sudah kita buat sebelumnya
        getOne_kegiatan.value = KegiatanModel.fromJson(response);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat detail kegiatan");
    } finally {
      isLoading.value = false;
    }
  }
}