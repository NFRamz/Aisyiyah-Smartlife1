import 'dart:async';
import 'package:aisyiyah_smartlife/core/services/update/update_service.dart';
import 'package:aisyiyah_smartlife/core/utils/SafePrint.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Service Notifikasi
import 'package:aisyiyah_smartlife/core/services/notification/NotificationService.dart';

class HomeController extends GetxController {
  final supabase  = Supabase.instance.client;
  final initNotif = NotificationService().initNotifications();


  final logger          = SafePrint("home_controller.dart");
  final userData        = Rx<Map<String, dynamic>?>(null);
  final kegiatanFuture  = Rx<Future<List<Map<String, dynamic>>>?>(null);
  final isLoading       = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserDataAndKegiatan();
    _checkUpdate();
  }

  Future<void> fetchUserDataAndKegiatan() async {
    isLoading.value = true;
    try {
      await modeOnline();
    } catch (e) {
      logger.safePrint("fetchUserDataAndKegiatan()", "Catch: Load Data Offline", "33", e);
      await loadOfflineUser();
    }
    isLoading.value = false;
  }

  Future<void> modeOnline() async{
    try {
      await fetchUserData();
      kegiatanFuture.value = fetchKegiatan();
      await initNotif;
    }catch(e){
      logger.safePrint("modeOnline()", "Catch: Rethrow", "45", e);
      rethrow;
    }
  }

  Future<void> fetchUserData() async {
    final user  = supabase.auth.currentUser;
    final prefs = await SharedPreferences.getInstance();

    try {
      //get data ranting/cabang/daerah/provinsi
      if (user != null) {
        final data = await supabase.from('profiles')
                                    .select('*, role(tipe, full_access), ranting(ranting), cabang(cabang), daerah(daerah), wilayah(provinsi)')
                                    .eq('id', user.id)
                                    .maybeSingle();

        if (data != null) {
          String fullName = "${data['nama_depan']} ${data['nama_belakang'] ?? ''}".trim();
          Map<String, dynamic> newUserMap = {
            'email'         : data['email'] ?? "-",
            'nama_pengguna' : fullName ,
            'foto_profile'  : data['foto_profile'] ?? "-",
            'role'          : data['role']?['tipe'] ?? 'anggota',
            'full_access'   : data['role']?['full_access']??false,
            // ID (untuk filter kegiatan)
            'ranting_id'    : data['ranting_id']?.toString()  ?? '-',
            'cabang_id'     : data['cabang_id']?.toString()   ?? '-',
            'daerah_id'     : data['daerah_id']?.toString()   ?? '-',
            'wilayah_id'    : data['wilayah_id']?.toString()  ?? '-',

            // Nama Lokasi, untuk view User profileCard
            'ranting_nama'  : data['ranting'] != null ? data['ranting']['ranting']  : '-',
            'cabang_nama'   : data['cabang']  != null ? data['cabang']['cabang']    : '-',
            'daerah_nama'   : data['daerah']  != null ? data['daerah']['daerah']    : '-',
            'wilayah_nama'  : data['wilayah'] != null ? data['wilayah']['provinsi'] : '-',
          };

          userData.value = newUserMap;

          // save lokal untuk mode offline
          await prefs.setString('email',         newUserMap['email']);
          await prefs.setString('nama_pengguna', newUserMap['nama_pengguna']);
          await prefs.setString('foto_profile',  newUserMap['foto_profile']);
          await prefs.setString('role',          newUserMap['role']);
          await prefs.setBool('full_access',     newUserMap['full_access']);

          await prefs.setString('ranting_id',    newUserMap['ranting_id']);
          await prefs.setString('cabang_id',     newUserMap['cabang_id']);
          await prefs.setString('daerah_id',     newUserMap['daerah_id']);
          await prefs.setString('wilayah_id',    newUserMap['wilayah_id']);

          await prefs.setString('ranting_nama',  newUserMap['ranting_nama']);
          await prefs.setString('cabang_nama',   newUserMap['cabang_nama']);
          await prefs.setString('daerah_nama',   newUserMap['daerah_nama']);
          await prefs.setString('wilayah_nama',  newUserMap['wilayah_nama']);
        }
      }
    } catch (e) {
      logger.safePrint("fetchUserData()", "Catch: Rethrow", "101", e);
      rethrow;
    }
  }


  Future<List<Map<String, dynamic>>> fetchKegiatan() async {
    // 1. Siapkan Hive Box
    var box = Hive.box('home_JadwalKegiatan');

    // 2. Ambil Data User
    bool fullAccess = userData.value?['full_access'] ?? false;
    String wilayahId = userData.value?['wilayah_id'] ?? "-";
    String daerahId  = userData.value?['daerah_id'] ?? "-";
    String cabangId  = userData.value?['cabang_id'] ?? "-";
    String rantingId = userData.value?['ranting_id'] ?? "-";

    try {
      // --- 3. LOGIC FILTER HIRARKI TERBALIK ---
      // Konsep: User melihat kegiatan di levelnya sendiri DAN level di atasnya.

      List<String> conditions = [];

      // A. Jika user punya ID Ranting, dia bisa melihat kegiatan Ranting-nya sendiri
      if (isValid(rantingId)) {
        conditions.add('ranting_id.eq.$rantingId');
      }

      // B. Jika user punya ID Cabang (atau anggota ranting yang bernaung di cabang ini)
      // Dia bisa melihat kegiatan tipe 'cabang' milik cabang tersebut
      if (isValid(cabangId)) {
        conditions.add('and(tipe.eq.cabang,cabang_id.eq.$cabangId)');
      }

      // C. Jika user punya ID Daerah, lihat kegiatan tipe 'daerah' milik daerah tersebut
      if (isValid(daerahId)) {
        conditions.add('and(tipe.eq.daerah,daerah_id.eq.$daerahId)');
      }

      // D. Jika user punya ID Wilayah, lihat kegiatan tipe 'wilayah' milik wilayah tersebut
      if (isValid(wilayahId)) {
        conditions.add('and(tipe.eq.wilayah,wilayah_id.eq.$wilayahId)');
      }

      String filterCondition = conditions.join(',');

      if (filterCondition.isEmpty) {
        logger.safePrint("fetchKegiatan()", "No valid IDs", "150", "return []");
        return [];
      }

      // --- 4. EKSEKUSI QUERY SUPABASE (ONLINE) ---
      var query = supabase.from('kegiatan')
          .select('*, wilayah:wilayah_id(nama), daerah:daerah_id(nama), cabang:cabang_id(nama), ranting:ranting_id(nama)');

      final response = await query
          .or(filterCondition)
          .gte('tanggal', DateTime.now().toUtc().toIso8601String())
          .order('tanggal', ascending: true)
          .limit(5); // Limit disesuaikan

      final dataList = List<Map<String, dynamic>>.from(response);

      // --- 5. SIMPAN KE HIVE (CACHE) ---
      if (dataList.isNotEmpty) {

        await box.clear();
        await box.addAll(dataList);
        logger.safePrint("fetchKegiatan()", "Online Fetch Success & Cached", "170", "${dataList.length} items");
      }

      return dataList;

    } catch (e) {
      // --- 6. FALLBACK: LOAD DARI HIVE (OFFLINE) ---
      logger.safePrint("fetchKegiatan()", "Error/Offline - Loading Cache", "180", e);

      if (box.isNotEmpty) {
        // Konversi data Hive (dynamic) kembali ke List<Map<String, dynamic>>
        final cachedData = box.values.map((e) {
          return Map<String, dynamic>.from(e);
        }).toList();

        // Opsional: Tetap filter tanggal di lokal agar yang sudah lewat tidak muncul
        // cachedData.removeWhere((element) => DateTime.parse(element['tanggal']).isBefore(DateTime.now()));

        return cachedData;
      }

      return [];
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await Future.any([
        modeOnline(),
        Future.delayed(const Duration(seconds: 5), () => throw TimeoutException("Timeout")),
      ]);
    } catch (e) {
      logger.safePrint("refreshData()", "Catch:Load data Offline", "174", e);
      await loadOfflineUser();
    }
    isLoading.value = false;
  }

  String getUserFirstName() {return userData.value?['nama_pengguna']?.split(' ')[0] ?? 'User';}

  String formatTanggal(dynamic timestamp) {
    if (timestamp == null || timestamp.toString().isEmpty) return '-';
    try {
      DateTime dt = timestamp is DateTime ? timestamp : DateTime.parse(timestamp.toString());
      dt = dt.toLocal();

      logger.safePrint("formatTanggal()", "Try:get timeStamp", "188", DateFormat('d MMM yyyy • HH:mm').format(dt));
      return DateFormat('d MMM yyyy • HH:mm').format(dt);
      
    } catch (e) {
      logger.safePrint("formatTanggal()", "Catch:timestamp.toString()", "190", e);
      return timestamp.toString();
    }
  }

  Future<void> loadOfflineUser() async {
    final prefs = await SharedPreferences.getInstance();
    userData.value = {
      'email'         : prefs.getString('email'),
      'nama_pengguna' : prefs.getString('nama_pengguna'),
      'role'          : prefs.getString('role'),
      'ranting_id'    : prefs.getString('ranting_id'),
      'cabang_id'     : prefs.getString('cabang_id'),
      'daerah_id'     : prefs.getString('daerah_id'),
      'wilayah_id'    : prefs.getString('wilayah_id'),
      'ranting_nama'  : prefs.getString('ranting_nama'),
      'cabang_nama'  : prefs.getString('cabang_nama'),
      'daerah_nama'  : prefs.getString('daerah_nama'),
      'wilayah_nama'  : prefs.getString('wilayah_nama')
    };
    logger.safePrint("loadOfflineUser()", "Async:Load data offline User", "208", userData);
  }


  String get displayLocationTo_UserProfileCard {
    final data = userData.value;
    if (data == null) return '-';

    /*
    Terbalik karena hanya anggota ranting yang seluruh FK nya terisi di DB. jadi biar yg
    muncul lokasi yg spesifik maka diurutkan dari role terbawah ke atas. Kalau dari
    atas maka yang  kondisi dibawahnya tidak tereksesuki.
    */
    if (isValid(data['ranting_nama'])) {
      return data['ranting_nama'];
    }else if (isValid(data['cabang_nama'])) {
      return data['cabang_nama'];
    }else if (isValid(data['daerah_nama'])) {
      return data['daerah_nama'];
    }else if (isValid(data['wilayah_nama'])) {
      return data['wilayah_nama'];
    }
    return "-";


  }

  // Helperuntuk mengecek string valid
  bool isValid(String? value) {
    return value != null && value.isNotEmpty && value != '-';
  }
  void _checkUpdate() {
    if (Get.context != null) {
      // Panggil Service Update secara manual
      UpdateService.checkForUpdate(Get.context!);
    }
  }
}
