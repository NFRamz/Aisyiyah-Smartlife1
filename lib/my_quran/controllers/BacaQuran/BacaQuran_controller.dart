
import 'package:aisyiyah_smartlife/modules/my_quran/controllers/BacaQuran/components/BookmarkManager.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/controllers/BacaQuran/components/LastReadManager.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/controllers/BacaQuran/components/QuranAudioManager.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/controllers/BacaQuran/components/QuranSearchManager.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/models/BacaQuran/components/AyatModel.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/models/BacaQuran/components/SurahModel.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/service/QuranService.dart';
import 'package:get/get.dart';


class BacaQuran_controller extends GetxController with QuranAudio,QuranSearchManager, BookmarkManager, LastReadManager{

  final QuranService quranService = QuranService();
  RxList<Surah> get listSurah => quranService.listSurah;
  RxList<Ayat> get detailAyat => quranService.detailAyat;
  RxBool get isOffline        => quranService.isOffline;
  RxBool get isLoadingList    => quranService.isLoadingList;
  RxBool get isLoadingDetail  => quranService.isLoadingDetail;


  var isWordByWordMode = false.obs;
  var isFootnoteEnabled = true.obs;
  var arabicFontSize = 24.0.obs;
  var latinFontSize = 14.0.obs;

  @override
  void onInit() {
    super.onInit();
    quranService.fetchSurahList();
    initAudio();
    loadBookmarks();
    loadLastRead();

  }

  Future<String?> loadFootnoteContent(int footnoteId) async {
    return await quranService.getFootnoteContent(footnoteId);
  }

  Future<void> fetchDetailSurah(Surah surah) async {
    await stopAudio();
    await quranService.fetchDetailSurah(surah);
  }

  @override
  void onClose() {
    searchController.dispose();
    print("+++++ QURAN SERCICE DISPOSSSSSSEEEEEEE");
    quranService.disposeQuranService();
    disposeAudio();
    super.onClose();
  }

}