import 'package:aisyiyah_smartlife/modules/umkm/controllers/KelolaUmkm_controller.dart';
import 'package:aisyiyah_smartlife/modules/umkm/views/TambahUmkm_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class KelolaUmkm_view extends GetView<KelolaUmkm_controller> {
  KelolaUmkm_view({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola UMKM', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.fetchUmkmByScope(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.umkmList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_mall_directory_outlined, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text("Belum ada data UMKM", style: GoogleFonts.poppins(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.umkmList.length,
          itemBuilder: (context, index) {
            final umkm = controller.umkmList[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // Opsional: Detail view
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        image: umkm.gambar != null
                            ? DecorationImage(image: NetworkImage(umkm.gambar!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: umkm.gambar == null
                          ? const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            umkm.nama,
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            umkm.deskripsi ?? '-',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final result = await Get.to(() => TambahUmkm_view(umkmData: umkm));
                                  if (result == true) {
                                    controller.fetchUmkmByScope();
                                  }
                                },
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text("Edit"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  side: const BorderSide(color: Colors.orange),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => _confirmDelete(context, umkm.id, umkm.gambar, umkm.nama),
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text("Hapus"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Get.to(() => TambahUmkm_view());
          controller.fetchUmkmByScope();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String? gambar, String nama) {
    Get.defaultDialog(
      title: "Hapus Data",
      middleText: "Apakah Anda yakin ingin menghapus '$nama'?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteUmkm(id, gambar);
      },
    );
  }
}