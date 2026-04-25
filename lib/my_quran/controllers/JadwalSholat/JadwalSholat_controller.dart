import 'package:aisyiyah_smartlife/modules/my_quran/service/JadwalSholatAlarm_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/service/JadwalSholat_service.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/models/JadwalSholat/JadwalSholat_model.dart';

class JadwalSholat_controller extends GetxController {
  // Services
  final JadwalSholat_service _apiService = JadwalSholat_service();
  final JadwalSholatAlarmService _alarmService = JadwalSholatAlarmService(); // Instance Alarm Service
  final box = GetStorage();

  // State Variables
  var isLoading = true.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;

  var jadwal = Rxn<JadwalSholat_model>();

  // State UI untuk status alarm (ON/OFF)
  var alarmStates = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Load preferensi user (mana alarm yang aktif)
    Map<String, dynamic>? savedStates = box.read('sholat_alarm_states');
    if (savedStates != null) {
      alarmStates.assignAll(savedStates.map((key, value) => MapEntry(key, value as bool)));
    }

    fetchJadwal();
  }

  void fetchJadwal() async {
    try {
      isLoading(true);
      isError(false);

      var result = await _apiService.getJadwalSholat();
      jadwal.value = result;

      await _alarmService.syncAlarms(result, alarmStates);

    } catch (e) {
      isError(true);
      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  // Fungsi User Interaction (Tombol Lonceng)
  void toggleAlarm(String name, String timeStr) async {
    bool currentStatus = alarmStates[name] ?? false;
    bool newStatus = !currentStatus;


    alarmStates[name] = newStatus;
    box.write('sholat_alarm_states', alarmStates);

    if (newStatus) {
      await _alarmService.scheduleAlarm(name, timeStr);
      Get.snackbar("Alarm Aktif", "Pengingat $name berhasil diatur", duration: const Duration(seconds: 2));
    } else {
      await _alarmService.cancelAlarm(name);
      Get.snackbar("Alarm Mati", "Pengingat $name dimatikan", duration: const Duration(seconds: 1));
    }
  }
}