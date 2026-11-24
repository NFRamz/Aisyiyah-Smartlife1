import 'package:aisyiyah_smartlife/modules/donasi/controllers/test_Donasi_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockDonasiRepository extends Mock implements DonasiRepository {}
class MockDonasiUiHandler extends Mock implements DonasiUiHandler {}
class MockUser extends Mock implements User {}

void main() {
  late TestDonasiController controller;
  late MockDonasiRepository mockRepo;
  late MockDonasiUiHandler mockUiHandler;

  setUp(() {
    mockRepo = MockDonasiRepository();
    mockUiHandler = MockDonasiUiHandler();

    // Default Stubs
    when(() => mockRepo.currentUser).thenReturn(null);
    when(() => mockRepo.fetchDonasi()).thenAnswer((_) async => []);
    when(() => mockRepo.fetchRegions(any())).thenAnswer((_) async => []);
    when(() => mockRepo.checkPimpinanStatus(any())).thenAnswer((_) async => null);

    controller = TestDonasiController(repository: mockRepo, uiHandler: mockUiHandler);
  });

  group('DonasiController Tests', () {
    test('Initial state is correct', () {
      expect(controller.loading.value, isTrue);
      expect(controller.donasiList, isEmpty);
      expect(controller.isPimpinan.value, isFalse);
    });

    test('fetchRegions populates available regions', () async {
      when(() => mockRepo.fetchRegions('wilayah')).thenAnswer((_) async => [{'nama': 'Wilayah A'}]);
      
      await controller.fetchRegions();

      expect(controller.availableWilayah, contains('Wilayah A'));
    });

    test('checkPimpinanStatus sets isPimpinan to true for admin role', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user123');
      when(() => mockRepo.currentUser).thenReturn(mockUser);
      when(() => mockRepo.checkPimpinanStatus('user123')).thenAnswer((_) async => {
        'role': {'tipe': 'admin_pusat'}
      });

      await controller.checkPimpinanStatus();

      expect(controller.isPimpinan.value, isTrue);
    });

    test('fetchDonasi updates donasiList and sets loading to false', () async {
      final mockData = [{'id': '1', 'nama': 'Donasi Masjid'}];
      when(() => mockRepo.fetchDonasi()).thenAnswer((_) async => mockData);

      await controller.fetchDonasi();

      expect(controller.donasiList.length, 1);
      expect(controller.donasiList[0]['nama'], 'Donasi Masjid');
      expect(controller.loading.value, isFalse);
    });

    test('processPayment shows snackbar if user not logged in', () {
      when(() => mockRepo.currentUser).thenReturn(null);

      controller.processPayment({'id': '1', 'nama': 'Test'});

      verify(() => mockUiHandler.showSnackbar(
        any(that: contains('Ditolak')), 
        any(that: contains('login')),
        backgroundColor: any(named: 'backgroundColor'),
        colorText: any(named: 'colorText'),
      )).called(1);
    });

    test('updateFiltersAndSearch filters data correctly by name', () {
      controller.donasiList.assignAll([
        {'nama': 'Bantuan Gaza', 'profiles': {}},
        {'nama': 'Sedekah Subuh', 'profiles': {}},
      ]);

      controller.updateFiltersAndSearch(query: 'Gaza');

      expect(controller.searchResults.length, 1);
      expect(controller.searchResults[0]['nama'], 'Bantuan Gaza');
    });
  });
}

// Semantic Commit: test(donasi): implementasi unit test untuk alur pembayaran dan filter wilayah

