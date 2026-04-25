import 'package:aisyiyah_smartlife/core/services/notification/LocalNotificationService.dart';
import 'package:aisyiyah_smartlife/core/utils/SafePrint.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/components/JadwalKegiatanOtomatisModal.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/SearchAndSort.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/KegiatanModel.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/ProfileModel.dart';


class JadwalKegiatanController extends GetxController {
  final supabase               = Supabase.instance.client;
  final jadwalKegiatanOtomatis = JadwalKegiatanOtomatisModal();
  final LocalNotificationService localNotif = LocalNotificationService();

  var isLoading          = true.obs;
  var isLoadingScheduled = false.obs;
  var allKegiatan       = <KegiatanModel>[].obs;
  var displayedKegiatan = <KegiatanModel>[].obs;
  var myScheduledData   = <KegiatanModel>[].obs;
  var currentUser       = Rxn<ProfileModel>();
  var activeAlarmIds    = <String>{}.obs;

  // Class buat cari/filter/sort
  final searchAndSort = SearchAndSort();


  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    loadSavedAlarms();
  }

  // 1. FETCH LOGIC
  Future<void> fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final response = await supabase.from('profiles').select('*,role(tipe, full_access)').eq('id', user.id).maybeSingle();

        if (response != null) {
          currentUser.value = ProfileModel(
            id        : response['id'],
            role      : response['role']?['tipe'] ?? 'anggota',
            full_access : response['role']?['full_access'] ?? false,
            wilayahId : response['wilayah_id'],
            daerahId  : response['daerah_id'],
            cabangId  : response['cabang_id'],
            rantingId : response['ranting_id'],
          );
          fetchKegiatan();
          searchAndSort.fetchKegiatan_withFilterDataLocation();
        }
      } catch (e) {
        //print("Error fetch profile: $e");
      }
    }
  }

  Future<void> fetchKegiatan() async {
    if (currentUser.value == null) return;
    isLoading.value = true;

    try {
      var query = supabase.from('kegiatan').select('*, wilayah:wilayah_id(nama), daerah:daerah_id(nama), cabang:cabang_id(nama), ranting:ranting_id(nama)');

      String filterCondition = '';
      final role      = currentUser.value?.role.toLowerCase()?? 'anggota';
      final full_access = currentUser.value?.full_access ?? false;
      final wilayahId = currentUser.value?.wilayahId;
      final daerahId  = currentUser.value?.daerahId;
      final cabangId  = currentUser.value?.cabangId;
      final rantingId = currentUser.value?.rantingId;

      if (role.contains('wilayah')&& wilayahId != null&& full_access) {
        filterCondition = 'wilayah_id.eq.$wilayahId';
      }
      else if (role.contains('daerah')&& daerahId != null&& full_access) {
        filterCondition = 'daerah_id.eq.$daerahId,and(tipe.eq.wilayah,wilayah_id.eq.$wilayahId)';
      }
      else if (role.contains('cabang')&& cabangId != null&& full_access) {
        filterCondition = 'cabang_id.eq.$cabangId';
        if (wilayahId != null) filterCondition += ',and(tipe.eq.wilayah,wilayah_id.eq.$wilayahId)';
        if (daerahId  != null) filterCondition += ',and(tipe.eq.daerah,daerah_id.eq.$daerahId)';
      }
      else {
        // Anggota / Ranting
        List<String> conditions = [];
        if (rantingId != null) conditions.add('ranting_id.eq.$rantingId');
        if (cabangId  != null) conditions.add('and(tipe.eq.cabang,cabang_id.eq.$cabangId)');
        if (daerahId  != null) conditions.add('and(tipe.eq.daerah,daerah_id.eq.$daerahId)');
        if (wilayahId != null) conditions.add('and(tipe.eq.wilayah,wilayah_id.eq.$wilayahId)');

        if (conditions.isNotEmpty) {
          filterCondition = conditions.join(',');
        } else {
          filterCondition = 'id.is.null';
        }
      }

      if (filterCondition.isNotEmpty) {
        final response = await query.or(filterCondition).order('tanggal', ascending: true);

        // Parsing List
        List<KegiatanModel> fetchedData = jadwalKegiatanOtomatis.parseKegiatanList(response as List);

        allKegiatan.assignAll(fetchedData);
        await localNotif.syncAlarms(allKegiatan);
        applyLocalFilters();
      } else {
        allKegiatan.clear();
        displayedKegiatan.clear();
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat kegiatan.");
    } finally {
      isLoading.value = false;
    }
  }


  // 2. CRUD Operations
  Future<void> addKegiatan(String nama, DateTime tanggal, String deskripsi, String? mapsLink, String? lokasi, String frekuensi) async {
    if (currentUser.value == null) return;

    String tipe = '';
    final role      = currentUser.value?.role.toLowerCase()?? 'anggota';
    final full_access = currentUser.value?.full_access ?? false;
    final wilayahId = currentUser.value?.wilayahId;
    final daerahId  = currentUser.value?.daerahId;
    final cabangId  = currentUser.value?.cabangId;
    final rantingId = currentUser.value?.rantingId;
    Map<String, dynamic> locationData = {};

    if (role.contains('wilayah')&& wilayahId != null&& full_access) {
      tipe = 'wilayah';
      locationData = {'wilayah_id': currentUser.value!.wilayahId};
    } else if (role.contains('daerah')&& daerahId != null&& full_access) {
      tipe = 'daerah';
      locationData = {'wilayah_id': currentUser.value!.wilayahId, 'daerah_id': currentUser.value!.daerahId};
    } else if (role.contains('cabang')&& cabangId != null&& full_access) {
      tipe = 'cabang';
      locationData = {'wilayah_id': currentUser.value!.wilayahId, 'daerah_id': currentUser.value!.daerahId, 'cabang_id': currentUser.value!.cabangId};
    } else if (role.contains('ranting')&& rantingId != null&& full_access) {
      tipe = 'ranting';
      locationData = {'wilayah_id': currentUser.value!.wilayahId, 'daerah_id': currentUser.value!.daerahId, 'cabang_id': currentUser.value!.cabangId, 'ranting_id': currentUser.value!.rantingId};
    } else {
      Get.snackbar("Akses Ditolak", "Anggota biasa tidak bisa membuat kegiatan");
      return;
    }

    try {
      //Convert ke UTC sebelum kirim ke DB
      final insertData = {
        'nama'                : nama,
        'tanggal'             : tanggal.toUtc().toIso8601String(),
        'deskripsi'           : deskripsi,
        'lokasi'              : lokasi,
        'google_maps_link'    : mapsLink,
        'tipe'                : tipe,
        'frekuensi_ulang'     : frekuensi,
        ...locationData
      };



      await supabase.from('kegiatan').insert(insertData);

      await fetchKegiatan();
      fetchMyScheduled_dataKegiatan();

      Get.back();
      Get.snackbar("Sukses", "Kegiatan berhasil ditambahkan");
    } catch (e) {

      Get.snackbar("Error", "Gagal menambah kegiatan");
    }
  }

  Future<void> updateKegiatan(KegiatanModel item, String nama, DateTime tanggal, String deskripsi, String? mapsLink, String? lokasi, String? frekuensi) async {
    if (!canAction(item)) {
      Get.snackbar("Gagal", "Anda tidak memiliki izin mengedit kegiatan ini");
      return;
    }

    try {
      await supabase.from('kegiatan').update({
        'nama'            : nama,
        'tanggal'         : tanggal.toUtc().toIso8601String(),
        'deskripsi'       : deskripsi,
        'lokasi'          : lokasi,
        'google_maps_link': mapsLink,
        'frekuensi_ulang': frekuensi
      }).eq('id', item.id);

      await fetchKegiatan();
      fetchMyScheduled_dataKegiatan();

      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Gagal update");
    }
  }

  Future<void> deleteKegiatan(KegiatanModel item) async {
    if (!canAction(item)) return;
    try {
      await supabase.from('kegiatan').delete().eq('id', item.id);
      fetchKegiatan();
      fetchMyScheduled_dataKegiatan();
    } catch (e) {
      Get.snackbar("Error", "Gagal hapus");
    }
  }

  bool canAction(KegiatanModel item) {
    final role      = currentUser.value?.role.toLowerCase()?? 'anggota';
    final full_access = currentUser.value?.full_access ?? false;
    final wilayahId = currentUser.value?.wilayahId;
    final daerahId  = currentUser.value?.daerahId;
    final cabangId  = currentUser.value?.cabangId;
    final rantingId = currentUser.value?.rantingId;

    if (currentUser.value == null && full_access == false) return false;
    if (role.contains('wilayah')&& wilayahId != null&& full_access)  return item.tipe == 'wilayah' && item.wilayahId == currentUser.value!.wilayahId;
    if (role.contains('daerah')&& daerahId != null&& full_access)   return item.tipe == 'daerah'  && item.daerahId  == currentUser.value!.daerahId;
    if (role.contains('cabang')&& cabangId != null&& full_access)   return item.tipe == 'cabang'  && item.cabangId  == currentUser.value!.cabangId;
    if (role.contains('ranting')&& rantingId != null&& full_access)  return item.tipe == 'ranting' && item.rantingId == currentUser.value!.rantingId;
    return false;
  }

  // 3. For Button
  Future<void> openMap(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Tidak bisa membuka link maps");
    }
  }

  // 4. For Filter
  void applyLocalFilters() {
    final role  = currentUser.value?.role.toLowerCase()?? 'anggota';
    final wId   = currentUser.value?.wilayahId;
    final dId   = currentUser.value?.daerahId;
    final cId   = currentUser.value?.cabangId;
    final rId   = currentUser.value?.rantingId;


    var result = searchAndSort.filterKegiatan(
      allKegiatan,
      role        : role,
      myWilayahId : wId,
      myDaerahId  : dId,
      myCabangId  : cId,
      myRantingId : rId,
    );
    displayedKegiatan.assignAll(result);
  }


  // -- JADWAL OTOMATIS BERULANG & method untuk Alarm Icon --
  Future<void> fetchMyScheduled_dataKegiatan() async {
    if (currentUser.value == null) {
      await fetchUserProfile();
      if (currentUser.value == null) return;
    }

    isLoadingScheduled.value = true;
    try {
      final data = await jadwalKegiatanOtomatis.fetchData(currentUser.value!);
      myScheduledData.assignAll(data);
    } catch (e){
      Get.snackbar("Error", "Gagal memuat Jadwal Otomatis");
    }finally{
      isLoadingScheduled.value = false;
    }
  }

  bool hasAlarm(String id) {
    return activeAlarmIds.contains(id);
  }

  void addActiveAlarm(String id) {
    activeAlarmIds.add(id);
  }

  void removeActiveAlarm(String id) {
    activeAlarmIds.remove(id);
  }
  void loadSavedAlarms() {
    final box = GetStorage();

    List<dynamic> myAlarms = box.read<List>('my_alarms') ?? [];
    if (myAlarms.isNotEmpty) {
      final savedIds = myAlarms.map((e) => e['id'].toString()).toSet();
      activeAlarmIds.assignAll(savedIds);

    }
  }
}