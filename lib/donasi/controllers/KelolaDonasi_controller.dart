import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KelolaDonasi_controller extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = true.obs;
  var donasiList = <Map<String, dynamic>>[].obs;

  String? userWilayahId;
  String? userDaerahId;
  String? userCabangId;
  String? userRantingId;
  String? roleTipe;
  var roleFullAccess = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDonasiByScope();
  }

  Future<void> fetchDonasiByScope() async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;

      if (user == null) {
        Get.snackbar("Error", "User tidak terautentikasi");
        return;
      }

      // 1. Ambil context profil & role user
      final profileResponse = await supabase
          .from('profiles')
          .select('role:role_id(tipe, full_access), wilayah_id, daerah_id, cabang_id, ranting_id')
          .eq('id', user.id)
          .single();

      userWilayahId = profileResponse["wilayah_id"]?.toString();
      userDaerahId = profileResponse["daerah_id"]?.toString();
      userCabangId = profileResponse["cabang_id"]?.toString();
      userRantingId = profileResponse["ranting_id"]?.toString();
      
      if (profileResponse["role"] != null) {
        roleTipe = profileResponse["role"]["tipe"]?.toString().toLowerCase();
        roleFullAccess.value = profileResponse["role"]["full_access"] ?? false;
      }

      // 2. Build Query berdasarkan tingkatan
      // Asumsi: Tabel donasi_rk memiliki kolom profiles_id yang merujuk ke pembuatnya
      // 2. Build Query
      // Kunci akses hanya untuk data yang dibuat oleh user itu sendiri (berdasarkan profiles_id)
      var query = supabase
          .from('donasi_rk')
          .select('*, profiles(wilayah_id, daerah_id, cabang_id, ranting_id)')
          .eq('profiles_id', user.id);

      final response = await query.order('created_at', ascending: false);
      donasiList.assignAll(List<Map<String, dynamic>>.from(response));

    } catch (e) {
      print("Error fetch donasi: $e");
      Get.snackbar("Error", "Gagal memuat data donasi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDonasi(String id, String? imageUrl) async {
    try {
      // Hapus gambar jika ada
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          // Asumsi path storage: bucket/folder/filename
          // Contoh: donasi-gambar/items/namafile.jpg
          if (pathSegments.length >= 2) {
            final bucket = pathSegments[pathSegments.indexOf('public') + 1]; // Menyesuaikan URL Supabase
            final filePath = pathSegments.sublist(pathSegments.indexOf(bucket) + 1).join('/');
            await supabase.storage.from(bucket).remove([filePath]);
          }
        } catch (e) {
          print("Error deleting image from storage: $e");
        }
      }

      await supabase.from('donasi_rk').delete().eq('id', id);
      donasiList.removeWhere((item) => item['id'] == id);
      Get.snackbar("Sukses", "Donasi berhasil dihapus");
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus donasi: $e");
    }
  }
}
