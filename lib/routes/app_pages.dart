import 'package:aisyiyah_smartlife/modules/donasi/bindings/DetailDonasi_binding.dart';
import 'package:aisyiyah_smartlife/modules/donasi/bindings/Donasi_binding.dart';
import 'package:aisyiyah_smartlife/modules/donasi/bindings/KelolaDonasi_binding.dart';
import 'package:aisyiyah_smartlife/modules/donasi/bindings/RiwayatDonasi_binding.dart';
import 'package:aisyiyah_smartlife/modules/donasi/views/DetailDonasi_view.dart';
import 'package:aisyiyah_smartlife/modules/donasi/views/Donasi_view.dart';
import 'package:aisyiyah_smartlife/modules/donasi/views/KelolaDonasi_view.dart';
import 'package:aisyiyah_smartlife/modules/donasi/views/RiwayatDonasi_view.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/bindings/QuranAudioPlayer/QuranAudioDownloader_binding.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/bindings/QuranAudioPlayer/QuranAudioPlayer_binding.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/views/QuranAudioPlayer/QuranAudioDownloader_view.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/views/QuranAudioPlayer/QuranAudioList_view.dart';
import 'package:aisyiyah_smartlife/modules/profile/bindings/DetailStats_binding.dart';
import 'package:aisyiyah_smartlife/modules/profile/bindings/EditProfile_bindings.dart';
import 'package:aisyiyah_smartlife/modules/profile/views/DetailStats_view.dart';
import 'package:aisyiyah_smartlife/modules/profile/views/EditProfile_view.dart';
import 'package:aisyiyah_smartlife/modules/umkm/bindings/KelolaUmkm_binding.dart';
import 'package:aisyiyah_smartlife/modules/umkm/controllers/KelolaUmkm_controller.dart';
import 'package:aisyiyah_smartlife/modules/umkm/views/KelolaUmkm_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

// Auth & Initial
import 'package:aisyiyah_smartlife/modules/splash_screen/bindings/splashscreen_binding.dart';
import 'package:aisyiyah_smartlife/modules/login/bindings/login_binding.dart';
import 'package:aisyiyah_smartlife/modules/signup/bindings/signup_binding.dart';

// Home & Main Features
import 'package:aisyiyah_smartlife/modules/home/bindings/home_binding.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/bindings/jadwal_kegiatan_binding.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/bindings/MyQuran_binding.dart';
import 'package:aisyiyah_smartlife/modules/umkm/bindings/umkm_binding.dart';
import 'package:aisyiyah_smartlife/modules/profile/bindings/Profile_binding.dart';

// Details
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/bindings/DetailKegiatan_binding.dart';
import 'package:aisyiyah_smartlife/modules/umkm/bindings/detailUmkm_binding.dart';

// MyQuran Sub-features
import 'package:aisyiyah_smartlife/modules/my_quran/bindings/AsmaulHusna/AsmaulHusna_binding.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/bindings/BacaQuran/Quran_binding.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/bindings/JadwalSholat/jadwal_sholat_binding.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/bindings/KalenderHijriyah/KalenderHijriyah_binding.dart';


// ===== VIEWS =====
// Auth & Initial
import 'package:aisyiyah_smartlife/modules/splash_screen/views/splashscreen_view.dart';
import 'package:aisyiyah_smartlife/modules/login/views/login_view.dart';
import 'package:aisyiyah_smartlife/modules/signup/views/signup_view.dart';

// Home & Main Features
import 'package:aisyiyah_smartlife/modules/home/views/home_view.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/views/jadwal_kegiatan_view.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/views/MyQuran_view.dart';
import 'package:aisyiyah_smartlife/modules/umkm/views/umkm_view.dart';
import 'package:aisyiyah_smartlife/modules/profile/views/Profile_view.dart';


// Details
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/views/DetailKegiatan_view.dart';
import 'package:aisyiyah_smartlife/modules/umkm/views/detailUmkm_view.dart';

// MyQuran Sub-features
import 'package:aisyiyah_smartlife/modules/my_quran/views/AsmaulHusna/AsmaulHusna.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/views/BacaQuran/QuranList_view.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/views/JadwalSholat/JadwalSholat_view.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/views/KalenderHijriyah/KalenderHijriyah_view.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/views/BacaQuran/QuranDetail_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASHSCREEN;

  static final routes = [

    // ==== INITAL ROUTE =====
    GetPage(
      name: _Paths.SPLASHSCREEN,
      page: () => const Splashscreen_view(),
      binding: Splashscreen_binding(),
    ),

    //===== AUTH =====
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignUp_view(),
      binding: SignUpBinding(),
    ),


    //=====HomePage=====
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
        transition: Transition.leftToRight,
        transitionDuration: Duration(milliseconds: 320)
    ),

    // ===== Menu Feature =====
    GetPage(
      name: _Paths.JADWALKEGIATAN,
      page: () => const JadwalKegiatanView(),
      binding: JadwalKegiatanBinding(),
    ),
    GetPage(
      name: _Paths.MY_QURAN,
      page: () => const MyQuranView(),
      binding: MyQuranBinding(),
    ),
    GetPage(
      name: _Paths.UMKM,
      page: () => const UmkmView(),
      binding: UmkmBinding(),
    ),
    GetPage(
      name: _Paths.DONASI,
      page: () => Donasi_view(),
      binding: Donasi_binding(),
    ),

    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 320)
    ),

    // ===== Detail Page =====
    //khsus buat RK
    GetPage(
      name: _Paths.DETAILDONASI,
      page: () => DetailDonasi_view(),
      binding: DetailDonasi_binding(),
    ),
    GetPage(
      name: _Paths.RIWAYATDONASI,
      page: () => RiwayatDonasi_view(),
      binding: RiwayatDonasi_binding(),
    ),
    GetPage(
      name: _Paths.KELOLADONASI,
      page: () => KelolaDonasi_view(),
      binding: KelolaDonasi_binding(),
    ),


    GetPage(
      name: _Paths.DETAILKEGIATAN,
      page: () => DetailKegiatanView(),
      binding: DetailKegiatanBinding(),
    ),
    GetPage(
      name: _Paths.DETAILUMKM,
      page: () => const DetailUmkmView(),
      binding: DetailUmkmBinding(),
    ),


    // ===== Manage Page =====
    GetPage(
      name: _Paths.KELOLAUMKM,
      page: () => KelolaUmkm_view(),
      binding: KelolaUmkm_binding(),
    ),


    //> MyQuran
    GetPage(
      name: _Paths.ASMAULHUSNA,
      page: () => AsmaulHusnaView(),
      binding: AsmaulHusna_binding(),
    ),
    GetPage(
      name: _Paths.BACA_QURAN,
      page: () => QuranListView(),
      binding: QuranBinding(),
    ),
    GetPage(
      name: _Paths.JADWALSHOLAT,
      page: () => JadwalSholat_view(),
      binding: JadwalSholat_binding(),
    ),
    GetPage(
      name: _Paths.KALENDERHIJRIYAH,
      page: () => KalenderHijriyah_view(),
      binding: KalenderHijriyah_binding(),
    ),
    GetPage(
      name: _Paths.QURANAUDIOPLAYER,
      page: () => const QuranAudioList_view(),
      binding: QuranAudioPlayer_binding(),
    ),

    //>>MyQuran/Baca_Quran
    GetPage(
      name: _Paths.DETAIL_SURAH,
      page: () => QuranDetailView(surah: Get.arguments),
      binding: QuranBinding(),
    ),

  //>>MyQuran/QuranAudioPlayer
    GetPage(
        name: _Paths.QURANAUDIODOWNLOADER,
        page: () => QuranAudioDownloader_view(),
        binding:QuranAudioDownloader_bindings(),
    ),

    //Profiles
    GetPage(
      name: _Paths.PROFILE_DETAIL,
      page: () => const DetailStats_view(),
      binding: DetailStatsBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_EDIT,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
  ];
}