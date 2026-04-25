import 'package:aisyiyah_smartlife/core/services/notification/NotificationService.dart';
import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:aisyiyah_smartlife/modules/home/controllers/home_controller.dart';

class Profile_controller extends GetxController {
  final supabase = Supabase.instance.client;
  final HomeController homeController = Get.find<HomeController>();
  final NotificationService notificationService = NotificationService();

  var isLoading = false.obs;
  var statsList = <Map<String, dynamic>>[].obs;

  // Variabel ID Lokasi User
  String? userWilayahId;
  String? userDaerahId;
  String? userCabangId;
  String? userRantingId;

  // Observable Lists untuk UI
  var layananWilayahList = <Map<String, dynamic>>[].obs;
  var layananDaerahList = <Map<String, dynamic>>[].obs;
  var layananCabangList = <Map<String, dynamic>>[].obs;
  var layananRantingList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Panggil stats dashboard
    fetchDashboardStats();

    // Panggil data user dulu -> baru panggil layanan
    fetchUserContext();
  }

  /// 1. AMBIL DATA PROFIL USER TERLEBIH DAHULU
  /// Fungsi ini penting untuk mengisi userWilayahId, userDaerahId, dll
  /// sebelum melakukan query ke tabel layanan.
  Future<void> fetchUserContext() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Asumsi: Ada tabel 'users' atau 'profiles' yang menyimpan detail lokasi user
      // Sesuaikan nama tabel ('users') dan nama kolom dengan database Anda
      final response = await supabase
          .from('profiles')
          .select('wilayah_id, daerah_id, cabang_id, ranting_id')
          .eq('id', user.id)
          .single();

      if (response != null) {
        userWilayahId = response['wilayah_id']?.toString();
        userDaerahId = response['daerah_id']?.toString();
        userCabangId = response['cabang_id']?.toString();
        userRantingId = response['ranting_id']?.toString();

        // Setelah ID didapatkan, baru ambil data layanan
        fetchLayananData();
      }
    } catch (e) {
      print("Error fetching user context: $e");
    }
  }

  Future<void> fetchDashboardStats() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase.rpc(
          'get_dashboard_stats',
          params: {'request_user_id': user.id}
      );

      if (response != null) {
        List<dynamic> data = response;
        statsList.assignAll(data.map((e) => e as Map<String, dynamic>).toList());
      }
    } catch (e) {
      print("Error fetching stats via RPC: $e");
    }
  }

  Future<void> fetchLayananData() async {
    try {
      layananWilayahList.clear();
      layananDaerahList.clear();
      layananCabangList.clear();
      layananRantingList.clear();

      List<String> conditions = [];

      // Debugging IDs
      print("Fetching Layanan for IDs -> W:$userWilayahId, D:$userDaerahId, C:$userCabangId, R:$userRantingId");

      // 1. Layanan Ranting: Cocokkan ID Ranting
      if (userRantingId != null) {
        conditions.add('ranting_id.eq.$userRantingId');
      }

      // 2. Layanan Cabang: Cocokkan ID Cabang DAN Pastikan bukan milik ranting manapun (ranting_id is null)
      if (userCabangId != null) {
        conditions.add('and(cabang_id.eq.$userCabangId,ranting_id.is.null)');
      }

      // 3. Layanan Daerah: Cocokkan ID Daerah DAN Pastikan bukan milik cabang manapun
      if (userDaerahId != null) {
        conditions.add('and(daerah_id.eq.$userDaerahId,cabang_id.is.null)');
      }

      // 4. Layanan Wilayah: Cocokkan ID Wilayah DAN Pastikan bukan milik daerah manapun
      if (userWilayahId != null) {
        conditions.add('and(wilayah_id.eq.$userWilayahId,daerah_id.is.null)');
      }

      if (conditions.isEmpty) {
        print("Warning: User tidak memiliki ID wilayah/daerah/cabang/ranting.");
        return;
      }

      // Eksekusi Query dengan Filter Ketat
      final response = await supabase
          .from('layanan')
          .select()
          .or(conditions.join(',')); // Gabungkan dengan koma untuk logika OR

      final List<dynamic> data = response as List<dynamic>;

      // Grouping Data ke List masing-masing
      for (var item in data) {
        if (item['ranting_id'] != null) {
          layananRantingList.add(item);
        } else if (item['cabang_id'] != null) {
          layananCabangList.add(item);
        } else if (item['daerah_id'] != null) {
          layananDaerahList.add(item);
        } else if (item['wilayah_id'] != null) {
          layananWilayahList.add(item);
        }
      }
    } catch (e) {
      print("Error fetching layanan: $e");
    }
  }

  Future<void> handleLogout() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      await notificationService.unsubscribeFromAllTopics();
      await supabase.auth.signOut();

      await prefs.clear();
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar('Berhasil', 'Anda telah logout', backgroundColor: AppColors.green_1, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}