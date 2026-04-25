import 'package:aisyiyah_smartlife/modules/my_quran/models/Ensiklopedi%20Hadist/HadistCategory_model.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/models/Ensiklopedi%20Hadist/HadistPreview_model.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/service/EnsiklopediaHadist_service.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/views/EnsiklopediHadist/HadistDetail_view.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/views/EnsiklopediHadist/Hadist_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Hadist_controller extends GetxController {
  final EnsiklopediaHadist_service _service = EnsiklopediaHadist_service();

  final String? currentCategoryId; // Null = Root
  final String title;

  var subCategories = <HadistCategory_model>[].obs;
  var hadithList = <HadistPreview_model>[].obs;

  var isLoading = true.obs;
  var isLoadingMore = false.obs;

  int currentPage = 1;
  var hasMoreHadith = true.obs;
  ScrollController scrollController = ScrollController();

  Hadist_controller({this.currentCategoryId, required this.title});

  @override
  void onInit() {
    super.onInit();
    loadInitialData();

    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        loadMoreHadith();
      }
    });
  }

  /// MEMUAT DATA
  void loadInitialData() async {
    isLoading(true);
    try {
      // 1. Ambil Sub-Kategori (Service akan melakukan Filter Manual jika currentCategoryId != null)
      var cats = await _service.getCategories(parentId: currentCategoryId);
      subCategories.assignAll(cats);

      // 2. Ambil Daftar Hadis (Hanya jika bukan Root)
      if (currentCategoryId != null) {
        currentPage = 1;
        hasMoreHadith(true);
        var hadiths = await _service.getHadithList(currentCategoryId!, currentPage);
        hadithList.assignAll(hadiths);
      }
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      isLoading(false);
    }
  }

  void loadMoreHadith() async {
    if (currentCategoryId == null || isLoadingMore.value || !hasMoreHadith.value) return;

    try {
      isLoadingMore(true);
      currentPage++;
      var newHadiths = await _service.getHadithList(currentCategoryId!, currentPage);

      if (newHadiths.isEmpty) {
        hasMoreHadith(false);
      } else {
        hadithList.addAll(newHadiths);
      }
    } catch (e) {
      hasMoreHadith(false);
    } finally {
      isLoadingMore(false);
    }
  }

  void navigateToSubCategory(HadistCategory_model item) {
    // Navigasi ke halaman yang SAMA tapi dengan ID baru
    // preventDuplicates: false agar bisa menumpuk halaman
    Get.to(
            () => Hadist_view(
            categoryId: item.id,
            categoryTitle: item.title
        ),
        preventDuplicates: false
    );
  }

  void navigateToDetail(String hadithId) {
    Get.to(() => HadithDetailView(hadithId: hadithId));
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
