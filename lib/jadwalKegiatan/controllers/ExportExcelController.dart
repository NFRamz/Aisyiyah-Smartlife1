import 'dart:io';
import 'package:flutter/material.dart' hide Border;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as ex; // Alias Excel
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/KegiatanModel.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/ProfileModel.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/components/JadwalKegiatanOtomatisModal.dart';

class ExportExcelController extends GetxController {
  final supabase = Supabase.instance.client;
  final jadwalKegiatanOtomatis = JadwalKegiatanOtomatisModal();
  late ProfileModel currentUser;

  // Filter State
  var startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  var endDate = DateTime.now().add(const Duration(days: 30)).obs;

  var selectedScope = 'all'.obs; // 'all', 'wilayah', 'daerah', 'cabang', 'ranting'

  // State untuk Multi-Select Lokasi (Requirement No. 1 & 2)
  var availableLocations = <Map<String, String>>[].obs; // {id: "123", nama: "Cabang A"}
  var selectedLocationIds = <String>[].obs; // ["123", "456"]
  var isFetchingLocations = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is ProfileModel) {
      currentUser = Get.arguments as ProfileModel;
    } else {
      Get.back();
      Get.snackbar("Error", "Gagal memuat profil user");
    }

    // Listener: Jika scope berubah, reset pilihan lokasi spesifik
    ever(selectedScope, (_) => _onScopeChanged());
  }

  // --- LOGIC 1: FETCH OPSI LOKASI (Atas ke Bawah / Bawah ke Atas) ---
  void _onScopeChanged() async {
    selectedLocationIds.clear();
    availableLocations.clear();

    String scope = selectedScope.value;
    if (scope == 'all') return;

    // Cek Role User
    String myRole = currentUser.role.toLowerCase();

    // --- SKENARIO 1: BAWAH KE ATAS (User Ranting mau lihat Daerah) ---
    // User tidak punya pilihan, otomatis terkunci ke ID induknya.
    if ((myRole.contains('ranting') && (scope == 'daerah' || scope == 'cabang' || scope == 'wilayah')) ||
        (myRole.contains('cabang') && (scope == 'daerah' || scope == 'wilayah')) ||
        (myRole.contains('daerah') && (scope == 'wilayah'))) {

      // Tidak perlu fetch API, karena ID-nya sudah ada di Profile User
      // Kita biarkan list kosong, nanti di query filter otomatis pakai ID user.
      return;
    }

    // --- SKENARIO 2: ATAS KE BAWAH (User Wilayah mau pilih Cabang Spesifik) ---
    isFetchingLocations.value = true;
    try {
      String table = '';
      String foreignKey = '';
      String myId = '';

      // Tentukan tabel target berdasarkan scope yang dipilih
      if (scope == 'daerah') {
        table = 'daerah';
      } else if (scope == 'cabang') {
        table = 'cabang';
      } else if (scope == 'ranting') {
        table = 'ranting';
      } else if (scope == 'wilayah') {
        // Jarang terjadi, tapi jika sesama wilayah mau lihat (biasanya cuma 1)
        availableLocations.clear();
        isFetchingLocations.value = false;
        return;
      }

      // Tentukan Filter Induk (User Login sebagai apa?)
      if (myRole.contains('wilayah')) {
        foreignKey = 'wilayah_id';
        myId = currentUser.wilayahId!;
      } else if (myRole.contains('daerah')) {
        foreignKey = 'daerah_id';
        myId = currentUser.daerahId!;
      } else if (myRole.contains('cabang')) {
        foreignKey = 'cabang_id';
        myId = currentUser.cabangId!;
      }

      if (table.isNotEmpty && myId.isNotEmpty) {
        // Ambil daftar lokasi bawahan
        // Contoh: Ambil semua Cabang dimana wilayah_id = ID SAYA
        String colName = scope; // biasanya nama kolom 'daerah', 'cabang', 'ranting'
        if (scope == 'wilayah') colName = 'provinsi'; // khusus wilayah nama kolomnya provinsi

        final res = await supabase.from(table)
            .select('id, $colName')
            .eq(foreignKey, myId)
            .order(colName, ascending: true);

        List<Map<String, String>> temp = [];
        for(var item in res) {
          temp.add({
            'id': item['id'].toString(),
            'nama': item[colName].toString(),
          });
        }
        availableLocations.assignAll(temp);
      }

    } catch (e) {
      print("Error fetching filter options: $e");
    } finally {
      isFetchingLocations.value = false;
    }
  }

  // --- LOGIC 2: QUERY DATABASE (Menggabungkan Filter & History) ---
  Future<List<KegiatanModel>> _fetchData(DateTime start, DateTime end, String scope) async {
    // Columns
    String columns = '*, wilayah:wilayah_id(nama), daerah:daerah_id(nama), cabang:cabang_id(nama), ranting:ranting_id(nama)';
    String startStr = start.toUtc().toIso8601String();
    String endStr = end.add(const Duration(hours: 23, minutes: 59)).toUtc().toIso8601String();

    List<String> conditions = [];

    // A. FILTER DASAR (HIRARKI)
    // Jika scope 'all', ambil semua bawahan
    if (scope == 'all') {
      if (isValid(currentUser.rantingId)) conditions.add('ranting_id.eq.${currentUser.rantingId}');
      if (isValid(currentUser.cabangId)) conditions.add('cabang_id.eq.${currentUser.cabangId}');
      if (isValid(currentUser.daerahId)) conditions.add('daerah_id.eq.${currentUser.daerahId}');
      if (isValid(currentUser.wilayahId)) conditions.add('wilayah_id.eq.${currentUser.wilayahId}');
    }
    else {
      // B. FILTER SPESIFIK (Requirement No. 1: Pilih Lokasi Tertentu)

      // Jika User ATASAN dan MEMILIH checkbox lokasi tertentu
      if (selectedLocationIds.isNotEmpty) {
        // Contoh: cabang_id.in.(ID_A, ID_B)
        String idList = selectedLocationIds.join(','); // "id1,id2,id3"
        conditions.add('${scope}_id.in.($idList)');

        // Pastikan tipe kegiatannya sesuai scope
        conditions.add('tipe.eq.$scope');
      }
      // Jika User BAWAHAN (Inverse Hierarchy) atau ATASAN yg pilih "SEMUA" di dropdown
      else {
        // Logic Bawah-ke-Atas: Otomatis pakai ID user sendiri
        // Contoh: Ranting mau rekap Daerah -> daerah_id = currentUser.daerahId
        if (scope == 'daerah') {
          if (currentUser.daerahId != null) conditions.add('daerah_id.eq.${currentUser.daerahId}');
          else if (currentUser.wilayahId != null) conditions.add('wilayah_id.eq.${currentUser.wilayahId}'); // Fallback utk atasan
        }
        else if (scope == 'cabang') {
          if (currentUser.cabangId != null) conditions.add('cabang_id.eq.${currentUser.cabangId}');
          else if (currentUser.daerahId != null) conditions.add('daerah_id.eq.${currentUser.daerahId}'); // Fallback
          else if (currentUser.wilayahId != null) conditions.add('wilayah_id.eq.${currentUser.wilayahId}'); // Fallback
        }
        // ... dst sesuaikan logic

        conditions.add('tipe.eq.$scope');
      }
    }

    if (conditions.isEmpty) return [];
    String filterString = conditions.join(',');

    try {
      // Parallel Fetch (Aktif + History)
      final futures = await Future.wait([
        supabase.from('kegiatan').select(columns).or(filterString).gte('tanggal', startStr).lte('tanggal', endStr),
        supabase.from('kegiatan_history').select(columns).or(filterString).gte('tanggal', startStr).lte('tanggal', endStr)
      ]);

      List<dynamic> merged = [];
      merged.addAll(futures[0] as List);
      merged.addAll(futures[1] as List);

      List<KegiatanModel> allData = jadwalKegiatanOtomatis.parseKegiatanList(merged);
      // Sort by Date
      allData.sort((a, b) => a.tanggal.compareTo(b.tanggal));

      return allData;

    } catch (e) {
      print("Error Fetching Data: $e");
      // Jika error relasi masih muncul, berarti SQL langkah 1 belum dijalankan
      if (e.toString().contains("Could not find a relationship")) {
        Get.snackbar("Database Error", "Hubungi admin: Tabel history belum di-link ke wilayah");
      }
      return [];
    }
  }

  // --- LOGIC 3: PROSES EXCEL (Styling Rapi) ---
  Future<void> processExport() async {
    isLoading.value = true;
    try {
      final dataList = await _fetchData(startDate.value, endDate.value, selectedScope.value);

      if (dataList.isEmpty) {
        Get.snackbar("Info", "Tidak ada data ditemukan.");
        isLoading.value = false;
        return;
      }

      var excel = ex.Excel.createExcel();
      ex.Sheet sheet = excel['Laporan'];
      excel.delete('Sheet1');

      // Styles
      ex.CellStyle titleStyle = ex.CellStyle(bold: true, fontSize: 14, horizontalAlign: ex.HorizontalAlign.Center);
      ex.CellStyle headerStyle = ex.CellStyle(
        bold: true,
        backgroundColorHex: ex.ExcelColor.blueGrey200,
        horizontalAlign: ex.HorizontalAlign.Center,
        topBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
        bottomBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
        leftBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
        rightBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
      );
      ex.CellStyle contentStyle = ex.CellStyle(
          topBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
          bottomBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
          leftBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
          rightBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
          textWrapping: ex.TextWrapping.WrapText
      );

      // Titles
      sheet.merge(ex.CellIndex.indexByString("A1"), ex.CellIndex.indexByString("F1"));
      sheet.cell(ex.CellIndex.indexByString("A1"))
        ..value = ex.TextCellValue("REKAP JADWAL KEGIATAN")
        ..cellStyle = titleStyle;

      sheet.merge(ex.CellIndex.indexByString("A2"), ex.CellIndex.indexByString("F2"));
      sheet.cell(ex.CellIndex.indexByString("A2"))
        ..value = ex.TextCellValue("Periode: ${DateFormat('dd MMM yyyy').format(startDate.value)} s/d ${DateFormat('dd MMM yyyy').format(endDate.value)}")
        ..cellStyle = ex.CellStyle(horizontalAlign: ex.HorizontalAlign.Center);

      int rowIndex = 4;

      // Grouping per Lokasi (Requirement No. 4 & 5)
      Map<String, List<KegiatanModel>> grouped = {};
      for(var item in dataList) {
        String key = _getHierarchyName(item);
        if(!grouped.containsKey(key)) grouped[key] = [];
        grouped[key]!.add(item);
      }

      grouped.forEach((locationName, items) {
        // Group Header
        var locHeader = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
        locHeader.value = ex.TextCellValue(locationName.toUpperCase());
        locHeader.cellStyle = ex.CellStyle(bold: true, fontColorHex: ex.ExcelColor.blue800);
        rowIndex++;

        // Table Headers
        List<String> headers = ["No", "Nama Kegiatan", "Tipe", "Tanggal", "Lokasi", "Deskripsi"];
        for(int i=0; i<headers.length; i++){
          var cell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
          cell.value = ex.TextCellValue(headers[i]);
          cell.cellStyle = headerStyle;
        }
        rowIndex++;

        // Rows
        int no = 1;
        for(var item in items){
          List<String> rowData = [
            no.toString(),
            item.nama,
            item.tipe.toUpperCase(),
            DateFormat('dd/MM/yyyy HH:mm').format(item.tanggal),
            item.lokasi ?? "-",
            item.deskripsi ?? "-"
          ];
          for(int i=0; i<rowData.length; i++){
            var cell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
            cell.value = ex.TextCellValue(rowData[i]);
            cell.cellStyle = contentStyle;
          }
          rowIndex++;
          no++;
        }
        rowIndex += 2; // Spasi antar tabel
      });

      // Set Width
      sheet.setColumnWidth(1, 35.0);
      sheet.setColumnWidth(3, 22.0);
      sheet.setColumnWidth(5, 40.0);

      // Save & Share
      final fileBytes = excel.save();
      final directory = await getApplicationDocumentsDirectory();
      final fileName = "Rekap_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx";
      final file = File('${directory.path}/$fileName');

      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes);
        await Share.shareXFiles([XFile(file.path)], text: 'File Rekap Kegiatan');
      }

    } catch (e) {
      Get.snackbar("Error", "Gagal export: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- HELPER LAIN ---
  List<DropdownMenuItem<String>> getScopeItems() {
    final role = currentUser.role.toLowerCase();
    List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem(value: 'all', child: Text("Semua Cakupan Saya (Total)")),
    ];

    // Logic Dropdown (Sama seperti sebelumnya)
    if (role.contains('wilayah')) {
      items.add(const DropdownMenuItem(value: 'wilayah', child: Text("Tingkat Wilayah")));
      items.add(const DropdownMenuItem(value: 'daerah', child: Text("Tingkat Daerah")));
      items.add(const DropdownMenuItem(value: 'cabang', child: Text("Tingkat Cabang")));
      items.add(const DropdownMenuItem(value: 'ranting', child: Text("Tingkat Ranting")));
    } else if (role.contains('daerah')) {
      items.add(const DropdownMenuItem(value: 'daerah', child: Text("Tingkat Daerah")));
      items.add(const DropdownMenuItem(value: 'cabang', child: Text("Tingkat Cabang")));
      items.add(const DropdownMenuItem(value: 'ranting', child: Text("Tingkat Ranting")));
    } else if (role.contains('cabang')) {
      items.add(const DropdownMenuItem(value: 'cabang', child: Text("Tingkat Cabang")));
      items.add(const DropdownMenuItem(value: 'ranting', child: Text("Tingkat Ranting")));
    } else if (role.contains('ranting')) {
      // Requirement No. 2: Bawah ke Atas (Ranting mau lihat Daerah)
      // Kita tambahkan opsi, tapi nanti di logic _fetchData, kita kunci filter ID nya.
      items.add(const DropdownMenuItem(value: 'cabang', child: Text("Lihat Data Cabang Saya")));
      items.add(const DropdownMenuItem(value: 'daerah', child: Text("Lihat Data Daerah Saya")));
      items.add(const DropdownMenuItem(value: 'wilayah', child: Text("Lihat Data Wilayah Saya")));
    }
    return items;
  }

  String _getHierarchyName(KegiatanModel item) {
    if (item.tipe == 'wilayah') return "${item.wilayahNama ?? '-'} (Wilayah)";
    if (item.tipe == 'daerah') return "${item.daerahNama ?? '-'} (Daerah)";
    if (item.tipe == 'cabang') return "${item.cabangNama ?? '-'} (Cabang)";
    if (item.tipe == 'ranting') return "${item.rantingNama ?? '-'} (Ranting)";
    return "Lainnya";
  }

  bool isValid(String? val) => val != null && val.isNotEmpty && val != 'null';
}