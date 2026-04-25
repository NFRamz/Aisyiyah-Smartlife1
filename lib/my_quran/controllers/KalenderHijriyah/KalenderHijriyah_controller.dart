import 'package:get/get.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/service/KalenderHijriyah_service.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/models/Kalender Hijriyah/KalenderHijriyah_model.dart';

class KalenderHijriyah_controller extends GetxController {
  final KalenderHijriyah_service _service = KalenderHijriyah_service();

  var isLoading = true.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;

  var listKalender = <KalenderHijriyah_model>[].obs;

  // VARIABLE BARU: Menyimpan tanggal yang sedang diklik user
  var selectedDate = Rxn<KalenderHijriyah_model>();

  var currentMonth = DateTime.now().month.obs;
  var currentYear = DateTime.now().year.obs;

  @override
  void onInit() {
    super.onInit();
    fetchKalender();
  }

  void fetchKalender() async {
    try {
      isLoading(true);
      isError(false);
      selectedDate.value = null; // Reset seleksi saat ganti bulan

      var result = await _service.getKalenderBulanan(currentMonth.value, currentYear.value);
      listKalender.assignAll(result);

    } catch (e) {
      isError(true);
      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  void nextMonth() {
    if (currentMonth.value == 12) {
      currentMonth.value = 1;
      currentYear.value++;
    } else {
      currentMonth.value++;
    }
    fetchKalender();
  }

  void prevMonth() {
    if (currentMonth.value == 1) {
      currentMonth.value = 12;
      currentYear.value--;
    } else {
      currentMonth.value--;
    }
    fetchKalender();
  }

  // FUNGSI BARU: Memilih tanggal
  void selectDate(KalenderHijriyah_model model) {
    selectedDate.value = model;
  }

  String getNamaBulanMasehi() {
    List<String> months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return months[currentMonth.value - 1];
  }
}