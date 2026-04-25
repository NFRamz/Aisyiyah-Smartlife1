import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/DetailKegiatan_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailKegiatanView extends GetView<DetailKegiatanController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Kegiatan")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final item = controller.getOne_kegiatan.value;
        if (item == null) {
          return const Center(child: Text("Data tidak ditemukan"));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(item.nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("📍 Lokasi: ${item.lokasi ?? 'Tidak ada lokasi'}"),
            Text("Tanggal: ${item.tanggal}"),
            const Divider(),
            Text(item.deskripsi ?? "Tidak ada deskripsi"),
          ],
        );
      }),
    );
  }
}