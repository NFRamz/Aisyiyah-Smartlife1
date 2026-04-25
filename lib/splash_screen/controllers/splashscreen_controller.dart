import 'package:aisyiyah_smartlife/core/services/notification/NotificationService.dart';
import 'package:aisyiyah_smartlife/core/services/update/update_service.dart';
import 'package:aisyiyah_smartlife/data/services/supabase_service.dart';
import 'package:aisyiyah_smartlife/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

class Splashscreen_controller extends GetxController {
  final isLoading     = true.obs;
  final statusMessage = 'Menyiapkan aplikasi...'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      statusMessage.value = 'Menginisialisasi aplikasi...';

      await _getReadyAll();

      statusMessage.value = 'Memeriksa status login...';

      await _checkLoginStatus();

    } catch (e) {
      statusMessage.value = 'Terjadi kesalahan: $e';
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> _getReadyAll() async {
    await Get.putAsync(() => SupabaseService().init());
    final notificationService = NotificationService();
    await notificationService.initNotifications();
    notificationService.setupForegroundHandler();

  }


  Future<void> _checkLoginStatus() async {
    final prefs       = await SharedPreferences.getInstance();
    final isLoggedIn  = prefs.getBool('isLoggedIn') ?? false;
    final email       = prefs.getString("email") ?? null;
    final notif = NotificationService();


     if (isLoggedIn && email != null) {
      Get.offAllNamed(Routes.HOME);
      notif.checkTerminatedNotification();
    } else if (isLoggedIn){
      Get.offAllNamed(Routes.MY_QURAN);
    }else{
      Get.offAllNamed(Routes.LOGIN);
    }
  }

}
