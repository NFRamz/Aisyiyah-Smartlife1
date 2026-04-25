import 'package:aisyiyah_smartlife/modules/umkm/model/Umkm_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KelolaUmkm_controller extends GetxController {
  final supabase = Supabase.instance.client;


  var isLoading = true.obs;
  var umkmList = <Umkm_model>[].obs;

  String? userCabangId;
  String? userRantingId;
  String? role_id_tipe;
  bool? role_id_fullAccess;

  @override
  void onInit() {
    super.onInit();
    fetchUmkmByScope();
  }

  Future<void> fetchUmkmByScope() async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;

      if (user == null) {
        Get.snackbar("Error", "User tidak terautentikasi");
        return;
      }

      final profileResponse = await supabase
          .from('profiles')
          .select('role_id(tipe, full_access), cabang_id, ranting_id')
          .eq('id', user.id)
          .single();

      userCabangId    = profileResponse["cabang_id"];
      userRantingId   = profileResponse["ranting_id"];
      role_id_tipe       = profileResponse["role_id"]["tipe"];
      role_id_fullAccess = profileResponse["role_id"]["full_access"];

      var query         = supabase.from('umkm').select();

      if (userRantingId != null && role_id_tipe?.contains("ranting") == true && role_id_fullAccess == true) {
        query = query.eq('ranting_id', userRantingId!);

      } else if (userCabangId != null && role_id_tipe?.contains("cabang") == true && role_id_fullAccess == true) {
        query = query.eq('cabang_id', userCabangId!);
      }
      final List<dynamic> response = await query.order('created_at', ascending: false);
      umkmList.value = response.map((e) => Umkm_model.fromJson(e)).toList();

    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUmkm(String id, String? imageUrl) async {
    try {
      if (imageUrl != null && imageUrl.contains('umkm-gambar')) {
        try {
          final fileName = imageUrl.split('/').last;
          await supabase.storage.from('umkm-gambar').remove(['umkm/$fileName']);
        } catch (_) {}
      }

      await supabase.from('umkm').delete().eq('id', id);

      umkmList.removeWhere((item) => item.id == id);
      Get.snackbar("Sukses", "Data berhasil dihapus");
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus data: $e");
    }
  }
}