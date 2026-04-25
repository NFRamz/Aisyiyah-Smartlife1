import 'package:aisyiyah_smartlife/core/utils/SafePrint.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/jadwal_kegiatan_controller.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/ProfileModel.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/RegionModel.dart';
import 'package:get/get.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/KegiatanModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum DateFilterType { all, today, tomorrow, thisWeek, customDays, dateRange }

class SearchAndSort {
  SafePrint logger = SafePrint('SearchAndSort');

  // --- STATE VARIABLES ---
  var searchQuery         = ''.obs;
  var activeDateFilter    = DateFilterType.all.obs;
  var showOnlyMyKegiatan  = false.obs;


  // UI State for Dropdowns (Added for the new requirement)
  var uiSelectedLevel     = RxnString(); // 'Wilayah', 'Daerah', 'Cabang', 'Ranting'
  var uiSelectedPlaceId   = RxnString();


  // Filter Custom
  var customNextDays  = Rxn<int>();
  var startDate       = Rxn<DateTime>();
  var endDate         = Rxn<DateTime>();

  // Filter Tingkatan
  var filterWilayahId = RxnString();
  var filterDaerahId  = RxnString();
  var filterCabangId  = RxnString();
  var filterRantingId = RxnString();

  final supabase               = Supabase.instance.client;

  var isLoading          = true.obs;
  var isLoadingScheduled = false.obs;
  var allKegiatan       = <KegiatanModel>[].obs;
  var displayedKegiatan = <KegiatanModel>[].obs;
  var myScheduledData   = <KegiatanModel>[].obs;

  var allWilayah = <RegionModel>[].obs;
  var allDaerah  = <RegionModel>[].obs;
  var allCabang  = <RegionModel>[].obs;
  var allRanting = <RegionModel>[].obs;


  List<KegiatanModel> filterKegiatan(List<KegiatanModel> allKegiatan, {required String? role, required String? myWilayahId, required String? myDaerahId, required String? myCabangId, required String? myRantingId}){
    var filtered = List<KegiatanModel>.from(allKegiatan);

    // 1. Filter Pencarian Teks
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((k) => k.nama.toLowerCase().contains(query) || (k.deskripsi != null && k.deskripsi!.toLowerCase().contains(query))).toList();
    }

    // 2. Filter Kegiatan Saya (Berdasarkan Scope ID & tipe kegiatan)
    if (showOnlyMyKegiatan.value && role != null) {
      if (role.contains("ranting")) {
        filtered = filtered.where((k) => k.rantingId  == myRantingId && k.tipe  == 'ranting').toList();

      } else if (role.contains("cabang")) {
        filtered = filtered.where((k) => k.cabangId   == myCabangId && k.tipe   == 'cabang') .toList();

      } else if (role.contains("daerah")) {
        filtered = filtered.where((k) => k.daerahId   == myDaerahId && k.tipe   == 'daerah') .toList();

      } else if (role.contains("wilayah")) {
        filtered = filtered.where((k) => k.wilayahId  == myWilayahId && k.tipe  == 'wilayah').toList();
      }
    }

    // 3. Filter Tingkatan
    if (filterWilayahId.value != null) {
      filtered = filtered.where((k) => k.wilayahId == filterWilayahId.value && k.tipe == 'wilayah').toList();
    }
    if (filterDaerahId.value != null) {
      filtered = filtered.where((k) => k.daerahId == filterDaerahId.value && k.tipe == 'daerah').toList();
    }
    if (filterCabangId.value != null) {
      filtered = filtered.where((k) => k.cabangId == filterCabangId.value && k.tipe == 'cabang').toList();
    }
    if (filterRantingId.value != null) {
      filtered = filtered.where((k) => k.rantingId == filterRantingId.value && k.tipe == 'ranting').toList();
    }

    // 4. Filter Waktu
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (activeDateFilter.value) {

      //case1
      case DateFilterType.today:
        filtered = filtered.where((k) {
          final kDate = k.tanggal;
          return kDate.year == today.year && kDate.month == today.month && kDate.day == today.day;
        }).toList();
        break;

      //case2
      case DateFilterType.tomorrow:
        final tomorrow = today.add(const Duration(days: 1));
        filtered = filtered.where((k) {
          final kDate = k.tanggal;
          return kDate.year == tomorrow.year && kDate.month == tomorrow.month && kDate.day == tomorrow.day;
        }).toList();
        break;

      //case3
      case DateFilterType.thisWeek:
        final startOfWeek   = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek     = startOfWeek.add(const Duration(days: 6));
        filtered = filtered.where((k) => k.tanggal.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && k.tanggal.isBefore(endOfWeek.add(const Duration(days: 1)))).toList();

        //filtered = filtered.where((k) => k.tanggal.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && k.tanggal.isBefore(endOfWeek.add(const Duration(days: 7)))).toList();
        break;

      //case 4
      case DateFilterType.customDays:
        if (customNextDays.value != null) {
          final targetDate = today.add(Duration(days: customNextDays.value!));
          filtered = filtered.where((k) => k.tanggal.isAfter(now) && k.tanggal.isBefore(targetDate.add(const Duration(days: 1)))).toList();
        }
        break;

      //case 5
      case DateFilterType.dateRange:
        if (startDate.value != null && endDate.value != null) {
          filtered = filtered.where((k) =>
          k.tanggal.isAfter(startDate.value!.subtract(const Duration(seconds: 1))) && k.tanggal.isBefore(endDate.value!.add(const Duration(days: 1)))).toList();
        }
        break;
      default:
        break;
    }

    // 5. Sorting
    filtered.sort((a, b) => a.tanggal.compareTo(b.tanggal));

    return filtered;
  }


  // Logic mengambil Data Lokasi (Wilayah/Daerah/dll) sesuai Scope User
  Future<void> fetchKegiatan_withFilterDataLocation() async {
    final penggunaSekarang =Get.find<JadwalKegiatanController>().currentUser.value;
    if (penggunaSekarang == null) return;

    try {
      // 1. Ambil Wilayah
      if (penggunaSekarang.wilayahId != null) {
        final resWil = await supabase.from('wilayah').select('id, nama').eq('id', penggunaSekarang.wilayahId!);
        allWilayah.assignAll((resWil as List).map((e) => RegionModel.fromJson(e)).toList());
      }

      /* 2. Ambil Daerah
       Jika user pimpinan wilayah, ambil semua daerah di wilayah itu
       Jika user di bawahnya, ambil daerah dia saja*/
      var queryDaerah = supabase.from('daerah').select('id, nama, wilayah_id');
      if (penggunaSekarang.role.contains("wilayah")&& penggunaSekarang.wilayahId != null) {
        queryDaerah = queryDaerah.eq('wilayah_id', penggunaSekarang.wilayahId!);

      } else if (penggunaSekarang.daerahId != null) {
        queryDaerah = queryDaerah.eq('id', penggunaSekarang.daerahId!);
      }
      final resDaerah = await queryDaerah;
      allDaerah.assignAll((resDaerah as List).map((e) => RegionModel.fromJson(e)).toList());

      // 3. Ambil Cabang
      var queryCabang = supabase.from('cabang').select('id, nama, daerah_id, daerah!inner(wilayah_id)');

      if (penggunaSekarang.role.contains("wilayah") &&  penggunaSekarang.wilayahId != null) {
        queryCabang = queryCabang.eq('daerah.wilayah_id', penggunaSekarang.wilayahId!);

      } else if (penggunaSekarang.role.contains("daerah") && penggunaSekarang.daerahId != null) {
        queryCabang = queryCabang.eq('daerah_id', penggunaSekarang.daerahId!);

      } else if (penggunaSekarang.cabangId != null) {
        queryCabang = queryCabang.eq('id', penggunaSekarang.cabangId!);
      }
      final resCabang = await queryCabang;
      allCabang.assignAll((resCabang as List).map((e) => RegionModel.fromJson(e)).toList());

      // 4. Ambil Ranting
      // join bertingkat: ranting -> cabang -> daerah (untuk dapat wilayah_id & daerah_id)
      // Supabase syntax untuk nested join: select('*, cabang!inner(*, daerah!inner(*))')
      // filter berdasarkan ID user
      var queryRanting = supabase.from('ranting').select('id, nama, cabang_id, cabang!inner(daerah_id, daerah!inner(wilayah_id))');

      if (penggunaSekarang.role.contains("wilayah") && penggunaSekarang.wilayahId != null) {
        queryRanting = queryRanting.eq('cabang.daerah.wilayah_id', penggunaSekarang.wilayahId!);

      } else if (penggunaSekarang.role.contains("daerah") && penggunaSekarang.daerahId != null) {
        queryRanting = queryRanting.eq('cabang.daerah_id', penggunaSekarang.daerahId!);

      } else if (penggunaSekarang.role.contains("cabang") && penggunaSekarang.cabangId != null) {
        queryRanting = queryRanting.eq('cabang_id', penggunaSekarang.cabangId!);

      } else if (penggunaSekarang.rantingId != null) {
        queryRanting = queryRanting.eq('id', penggunaSekarang.rantingId!);
      }

      final resRanting = await queryRanting;
      allRanting.assignAll((resRanting as List).map((e) {
        return RegionModel(
          id        : e['id'].toString(),
          nama      : e['nama'],
          cabangId  : e['cabang_id'].toString(),
          daerahId  : e['cabang']?['daerah_id']?.toString(),
          wilayahId : e['cabang']?['daerah']?['wilayah_id']?.toString(),
        );
      }).toList());

    } catch (e, stacktrace) {
      logger.safePrint("fetchKegiatan_withFilterDataLocation()", "line 221", e,stacktrace);
    }
  }

  void resetFilters() {
    searchQuery.value = '';
    showOnlyMyKegiatan.value = false;
    activeDateFilter.value   = DateFilterType.all;
    filterWilayahId.value    = null;
    filterDaerahId.value     = null;
    filterCabangId.value     = null;
    filterRantingId.value    = null;
    startDate.value          = null;
    endDate.value            = null;
    uiSelectedLevel.value    = null;
    uiSelectedPlaceId.value  = null;
    Get.find<JadwalKegiatanController>().applyLocalFilters();
  }

  void setDateFilter(DateFilterType type, {int? days, DateTime? start, DateTime? end}) {
    activeDateFilter.value  = type;
    customNextDays.value    = days;
    startDate.value         = start;
    endDate.value           = end;
    Get.find<JadwalKegiatanController>().applyLocalFilters();
  }

  void setMyActivityFilter(bool value) {
    showOnlyMyKegiatan.value = value;
    Get.find<JadwalKegiatanController>().applyLocalFilters();
  }


  void setLocationFilterFromUI(String level, String? placeId) {
    filterWilayahId.value = null;
    filterDaerahId.value = null;
    filterCabangId.value = null;
    filterRantingId.value = null;

    uiSelectedLevel.value = level;
    uiSelectedPlaceId.value = placeId;

    if (placeId == null) {
      Get.find<JadwalKegiatanController>().applyLocalFilters();
      return;
    }

    switch (level) {
      case 'Wilayah':
        filterWilayahId.value = placeId;
        break;
      case 'Daerah':
        filterDaerahId.value = placeId;
        break;
      case 'Cabang':
        filterCabangId.value = placeId;
        break;
      case 'Ranting':
        filterRantingId.value = placeId;
        break;
    }
    Get.find<JadwalKegiatanController>().applyLocalFilters();
  }

}