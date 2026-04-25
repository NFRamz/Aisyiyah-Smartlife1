
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/jadwal_kegiatan_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget SearchBarWidget() {
  final controller = Get.find<JadwalKegiatanController>();

  return Padding(
    padding: const EdgeInsets.all(16),
    child: TextField(
      decoration: InputDecoration(
        hintText: "Cari nama kegiatan...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)),
      onChanged: (val) {
        controller.searchAndSort.searchQuery.value = val;
        controller.applyLocalFilters();
      },
    ),
  );
}