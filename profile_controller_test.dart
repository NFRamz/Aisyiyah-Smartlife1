import 'package:aisyiyah_smartlife/modules/profile/controllers/test_Profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aisyiyah_smartlife/core/services/notification/NotificationService.dart';
import 'package:flutter/material.dart';

class MockIProfileRepository extends Mock implements IProfileRepository {}
class MockIProfileUIHandler extends Mock implements IProfileUIHandler {}
class MockNotificationService extends Mock implements NotificationService {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  late TestProfileController controller;
  late MockIProfileRepository mockRepo;
  late MockIProfileUIHandler mockUI;
  late MockNotificationService mockNotif;
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    
    mockRepo = MockIProfileRepository();
    mockUI = MockIProfileUIHandler();
    mockNotif = MockNotificationService();
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('user-123');

    controller = TestProfileController(
      repository: mockRepo,
      uiHandler: mockUI,
      notificationService: mockNotif,
      supabase: mockSupabase,
    );
  });

  group('ProfileController - fetchUserContext', () {
    test('should fetch user context and load layanan data on success', () async {
      final userData = {
        'wilayah_id': 'W1',
        'daerah_id': 'D1',
        'cabang_id': 'C1',
        'ranting_id': 'R1'
      };

      when(() => mockRepo.fetchUserContext('user-123')).thenAnswer((_) async => userData);
      when(() => mockRepo.fetchLayananData(any())).thenAnswer((_) async => []);

      await controller.fetchUserContext();

      expect(controller.userWilayahId, 'W1');
      verify(() => mockRepo.fetchLayananData(any())).called(1);
    });

    test('should handle null response from repository', () async {
      when(() => mockRepo.fetchUserContext('user-123')).thenAnswer((_) async => null);

      await controller.fetchUserContext();

      expect(controller.userWilayahId, isNull);
    });
  });

  group('ProfileController - fetchLayananData', () {
    test('should group layanan data correctly into lists', () async {
      controller.userWilayahId = 'W1';
      controller.userDaerahId = 'D1';
      
      final mockData = [
        {'id': 1, 'wilayah_id': 'W1', 'daerah_id': null, 'cabang_id': null, 'ranting_id': null},
        {'id': 2, 'wilayah_id': 'W1', 'daerah_id': 'D1', 'cabang_id': null, 'ranting_id': null},
      ];

      when(() => mockRepo.fetchLayananData(any())).thenAnswer((_) async => mockData);

      await controller.fetchLayananData();

      expect(controller.layananWilayahList.length, 1);
      expect(controller.layananDaerahList.length, 1);
    });
  });

  group('ProfileController - handleLogout', () {
    test('should unsubscribe from topics, sign out, and navigate to login', () async {
      when(() => mockNotif.unsubscribeFromAllTopics()).thenAnswer((_) async => {});
      when(() => mockRepo.signOut()).thenAnswer((_) async => {});

      await controller.handleLogout();

      verify(() => mockNotif.unsubscribeFromAllTopics()).called(1);
      verify(() => mockRepo.signOut()).called(1);
      verify(() => mockUI.navigateToLogin()).called(1);
      verify(() => mockUI.showSnackbar(any(), any(), backgroundColor: any(named: 'backgroundColor'), colorText: any(named: 'colorText'))).called(1);
    });
  });
}

// Semantic Commit: test(profile): add unit tests for fetchUserContext, fetchLayananData, and handleLogout
