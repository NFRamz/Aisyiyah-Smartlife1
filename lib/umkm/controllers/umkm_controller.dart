import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UmkmController extends GetxController {
  final supabase = Supabase.instance.client;

  var umkmList = <Map<String, dynamic>>[].obs;

  // -- List Data untuk Dropdown Filter --
  var availableRanting = <String>[].obs;
  var availableCabang = <String>[].obs;
  var availableDaerah = <String>[].obs;
  var availableWilayah = <String>[].obs;

  var loading = true.obs;

  // -- State Filter Terpilih --
  TextEditingController searchController = TextEditingController();
  var searchQuery = ''.obs;
  var selectedRanting = RxnString();
  var selectedCabang = RxnString();
  var selectedDaerah = RxnString();
  var selectedWilayah = RxnString();

  var searchResults = <Map<String, dynamic>>[].obs;

  // role
  final userRole = Rx<String?>(null);

  bool get showEditButton =>
      userRole.value?.contains("ranting") == true || userRole.value?.contains("cabang") == true;

  bool get hasActiveFilter =>
      searchQuery.value.isNotEmpty ||
          selectedRanting.value != null ||
          selectedCabang.value != null ||
          selectedDaerah.value != null ||
          selectedWilayah.value != null;

  @override
  void onInit() {
    super.onInit();
    fetchUmkm();
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final r = await supabase
            .from("profiles")
            .select("role(tipe)")
            .eq("id", user.id)
            .single();
        userRole.value = r["role"]?['tipe']??'anggota';
      }
    } catch (_) {}
  }

  Future<void> fetchUmkm() async {
    try {
      loading.value = true;

      // PERBAIKAN QUERY:
      // 1. Menggunakan format enter (aman dengan ''').
      // 2. Mengganti 'daderah' menjadi 'nama' (karena biasanya kita ambil nama daerah).
      // 3. Mengganti select kolom 'ranting' menjadi 'nama' (asumsi nama kolom di DB adalah 'nama').
      // 4. Struktur: alias:foreign_key(kolom_yang_mau_diambil)

      final data = await supabase.from("umkm").select('''
      "id","nama","deskripsi","gambar","maps_link", "ranting_id","cabang_id","social_media",
      
      relasi_ranting:"ranting_id"(ranting,
      cabang        :"cabang_id"(cabang,
      daerah        :"daerah_id"(daerah,
      wilayah       :"wilayah_id"(provinsi)
      )
      )
      ),
      relasi_cabang:"cabang_id"(cabang,
      daerah       :"daerah_id"(daerah,
      wilayah      :"wilayah_id"(provinsi)
      )
      )
      ''');

      List<Map<String, dynamic>> rawList = List<Map<String, dynamic>>.from(data);

      // -- NORMALISASI DATA--
      for (var i in rawList) {
        String? lokasi_ranting;
        String? lokasi_cabang;
        String? lokasi_daerah;
        String? lokasi_wilayah;

        // Cek Jalur Ranting
        if (i['relasi_ranting'] != null) {
          lokasi_ranting = i['relasi_ranting']['ranting'];

          if (i['relasi_ranting']['cabang'] != null) {
            lokasi_cabang = i['relasi_ranting']['cabang']['cabang'];

            if (i['relasi_ranting']['cabang']['daerah'] != null) {
              lokasi_daerah = i['relasi_ranting']['cabang']['daerah']['daerah'];

              if (i['relasi_ranting']['cabang']['daerah']['wilayah'] != null) {
                lokasi_wilayah = i['relasi_ranting']['cabang']['daerah']['wilayah']['provinsi'];
              }
            }
          }
        }
        // Cek Jalur Cabang (Jika Ranting Null)
        else if (i['relasi_cabang'] != null) {
          lokasi_cabang = i['relasi_cabang']['nama'];

          if (i['relasi_cabang']['daerah'] != null) {
            lokasi_daerah = i['relasi_cabang']['daerah']['nama'];

            if (i['relasi_cabang']['daerah']['wilayah'] != null) {
              lokasi_wilayah = i['relasi_cabang']['daerah']['wilayah']['nama'];
            }
          }
        }

        // Simpan ke level root item agar mudah difilter
        i['filter_ranting'] = lokasi_ranting;
        i['filter_cabang'] = lokasi_cabang;
        i['filter_daerah'] = lokasi_daerah;
        i['filter_wilayah'] = lokasi_wilayah;
      }

      umkmList.value = rawList;

      // -- Populate Dropdown Options --
      availableRanting.value = umkmList
          .map((e) => e['filter_ranting'] as String?)
          .where((e) => e != null && e.isNotEmpty)
          .toSet().toList().cast<String>();

      availableCabang.value = umkmList
          .map((e) => e['filter_cabang'] as String?)
          .where((e) => e != null && e.isNotEmpty)
          .toSet().toList().cast<String>();

      availableDaerah.value = umkmList
          .map((e) => e['filter_daerah'] as String?)
          .where((e) => e != null && e.isNotEmpty)
          .toSet().toList().cast<String>();

      availableWilayah.value = umkmList
          .map((e) => e['filter_wilayah'] as String?)
          .where((e) => e != null && e.isNotEmpty)
          .toSet().toList().cast<String>();

      loading.value = false;
      applyFilter();
    } catch (e) {
      loading.value = false;
      print("ERR fetchUmkm: $e");
    }
  }

  void updateFiltersAndSearch({
    String? query,
    String? ranting,
    String? cabang,
    String? daerah,
    String? wilayah
  }) {
    if(query != null) searchQuery.value = query;

    selectedRanting.value = ranting;
    selectedCabang.value = cabang;
    selectedDaerah.value = daerah;
    selectedWilayah.value = wilayah;

    applyFilter();
  }

  void applyFilter() {
    final q = searchQuery.value.toLowerCase().trim();

    searchResults.value = umkmList.where((u) {
      // 1. Filter Text
      bool matchQ = q.isEmpty || (u['nama'] ?? '').toLowerCase().contains(q) || (u['deskripsi_singkat'] ?? '').toLowerCase().contains(q);

      // 2. Filter Ranting
      bool matchR = selectedRanting.value == null || (u['filter_ranting'] ?? '').toLowerCase() == selectedRanting.value!.toLowerCase();

      // 3. Filter Cabang
      bool matchC = selectedCabang.value == null || (u['filter_cabang'] ?? '').toLowerCase() == selectedCabang.value!.toLowerCase();

      // 4. Filter Daerah
      bool matchD = selectedDaerah.value == null || (u['filter_daerah'] ?? '').toLowerCase() == selectedDaerah.value!.toLowerCase();

      // 5. Filter Wilayah
      bool matchW = selectedWilayah.value == null || (u['filter_wilayah'] ?? '').toLowerCase() == selectedWilayah.value!.toLowerCase();

      return matchQ && matchR && matchC && matchD && matchW;
    }).toList();
  }
}