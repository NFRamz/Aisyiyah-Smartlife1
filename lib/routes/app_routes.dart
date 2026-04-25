part of "app_pages.dart";

abstract class Routes {
  Routes._();

  // ==== INITAL ROUTE =====
  static const SPLASHSCREEN   = _Paths.SPLASHSCREEN;

  //===== AUTH =====
  static const LOGIN          = _Paths.LOGIN;
  static const SIGNUP         = _Paths.SIGNUP;

  //=====HomePage=====
  static const HOME           = _Paths.HOME;

  // ===== Menu Feature =====
  static const JADWALKEGIATAN = _Paths.JADWALKEGIATAN;
  static const MY_QURAN       = _Paths.MY_QURAN;
  static const UMKM           = _Paths.UMKM;

  //detail donasi khusus matkul RK
  static const DETAILDONASI   = _Paths.DETAILDONASI;
  static const RIWAYATDONASI = _Paths.RIWAYATDONASI;

  static const DONASI         = _Paths.DONASI;


  static const PROFILE        = _Paths.PROFILE;

  // ===== Detail Page =====
  static const DETAILKEGIATAN =  _Paths.DETAILKEGIATAN;
  static const DETAILUMKM     = _Paths.DETAILUMKM;


  // ===== Manage Page =====
  static const KELOLAUMKM = _Paths.KELOLAUMKM;
  static const KELOLADONASI = _Paths.KELOLADONASI;


  //> MyQuran
  static const ASMAULHUSNA    = _Paths.ASMAULHUSNA;
  static const BACA_QURAN     = _Paths.BACA_QURAN;
  static const JADWALSHOLAT   = _Paths.JADWALSHOLAT;
  static const KALENDERHIJRIYAH = _Paths.KALENDERHIJRIYAH;
  static const QURANAUDIOPLAYER = _Paths.QURANAUDIOPLAYER;

  //>>MyQuran/Baca_Quran
  static const DETAIL_SURAH   = _Paths.DETAIL_SURAH;

  //>>MyQuran/QuranAudioPlayer
  static const QURANAUDIODOWNLOADER = _Paths.QURANAUDIODOWNLOADER;

  //Profiles
  static const PROFILE_EDIT = _Paths.PROFILE_EDIT;
  static const PROFILE_DETAIL = _Paths.PROFILE_DETAIL;

}


abstract class _Paths {
  _Paths._();

  // ======================= INITAL ROUTE =================================
  static const SPLASHSCREEN       = "/splash_screen/";

  //============================ AUTH =====================================
  static const LOGIN              = "/login";
  static const SIGNUP             = "/signup";

  //=============================HomePage==================================
  static const HOME               = "/home";

  // ========================= Menu Feature ===============================
  static const JADWALKEGIATAN     = "/jadwalkegiatan";
  static const MY_QURAN           = "/my-quran";
  static const UMKM               = "/umkm";

  //khusus matkul RK saja
  static const DETAILDONASI       = "/donasi/detail/:id";
  static const RIWAYATDONASI      = "/donasi/riwayat";

  static const DONASI             = "/donasi";
  static const PROFILE            = "/profile";


  // ========================== Detail Page ===============================
  static const DETAILKEGIATAN     = "/detail-kegiatan";
  static const DETAILUMKM         = "/umkm/detail/:id";

  // ===== Manage Page =====
  static const KELOLAUMKM = "/umkm/kelolaUmkm";
  static const KELOLADONASI = "/donasi/kelolaDonasi";

  //> MyQuran
  static const ASMAULHUSNA        = "/asmaulhusna";
  static const BACA_QURAN         = "/baca-quran";
  static const JADWALSHOLAT       = "/jadwalsholat";
  static const KALENDERHIJRIYAH   = "/kalenderhijriyah";
  static const QURANAUDIOPLAYER   = "/quranaudioplayer";

  //>>MyQuran/Baca_Quran
  static const DETAIL_SURAH       = "/detail-surah";

  //>>MyQuran/QuranAudioPlayer
  static const QURANAUDIODOWNLOADER = "/quranaudiodownloader";

  //Profiles
  static const PROFILE_DETAIL = '/profile/detail';
  static const PROFILE_EDIT = '/profile/edit';
}
