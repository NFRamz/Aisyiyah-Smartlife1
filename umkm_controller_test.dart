import 'package:aisyiyah_smartlife/modules/umkm/controllers/test_umkm_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockUmkmRepository extends Mock implements UmkmRepository {}
class MockUser extends Mock implements User {}

void main() {
  late TestUmkmController controller;
  late MockUmkmRepository mockRepo;

  setUp(() {
    mockRepo = MockUmkmRepository();
    
    when(() => mockRepo.currentUser).thenReturn(null);
    when(() => mockRepo.fetchUmkm()).thenAnswer((_) async => []);
    when(() => mockRepo.fetchRole(any())).thenAnswer((_) async => null);

    controller = TestUmkmController(repository: mockRepo);
  });

  group('UmkmController Tests', () {
    test('Initial state', () {
      expect(controller.loading.value, isTrue);
      expect(controller.umkmList, isEmpty);
    });

    test('fetchUmkm normalizes location data correctly', () async {
      final mockData = [
        {
          'id': '1',
          'nama': 'Warung A',
          'relasi_ranting': {
            'ranting': 'Ranting X',
            'cabang': {
              'cabang': 'Cabang Y',
              'daerah': {
                'daerah': 'Daerah Z',
                'wilayah': {'provinsi': 'Wilayah W'}
              }
            }
          }
        }
      ];
      when(() => mockRepo.fetchUmkm()).thenAnswer((_) async => mockData);

      await controller.fetchUmkm();

      expect(controller.umkmList[0]['filter_ranting'], 'Ranting X');
      expect(controller.availableRanting, contains('Ranting X'));
      expect(controller.loading.value, isFalse);
    });

    test('applyFilter filters by search query', () async {
       controller.umkmList.assignAll([
        {'nama': 'Bakso Enak', 'deskripsi': 'Bakso urat'},
        {'nama': 'Mie Ayam', 'deskripsi': 'Mie lezat'},
      ]);

      controller.updateFiltersAndSearch(query: 'Bakso');

      expect(controller.searchResults.length, 1);
      expect(controller.searchResults[0]['nama'], 'Bakso Enak');
    });

    test('showEditButton returns true for ranting role', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('u1');
      when(() => mockRepo.currentUser).thenReturn(mockUser);
      when(() => mockRepo.fetchRole('u1')).thenAnswer((_) async => {
        'role': {'tipe': 'pimpinan_ranting'}
      });

      await controller.fetchRole(); // Manually await the async role fetch

      expect(controller.showEditButton, isTrue);
    });
  });
}

// Semantic Commit: test(umkm): pengujian normalisasi data hirarki lokasi dan filter pencarian

