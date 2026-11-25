import 'package:aisyiyah_smartlife/modules/my_quran/controllers/test_MyQuran_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockIMyQuranUIHandler extends Mock implements IMyQuranUIHandler {}

void main() {
  late TestMyQuranController controller;
  late MockIMyQuranUIHandler mockUI;

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    
    mockUI = MockIMyQuranUIHandler();
    controller = TestMyQuranController(uiHandler: mockUI);
  });

  group('MyQuranController - loadSettings', () {
    test('should load pinMyQuran from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({"pinMyQuran": true});
      
      await controller.loadSettings();
      
      expect(controller.pinMyQuran_view.value, true);
    });

    test('should default to false if pinMyQuran not set', () async {
      await controller.loadSettings();
      expect(controller.pinMyQuran_view.value, false);
    });
  });

  group('MyQuranController - runAction', () {
    test('should execute action if not in maintenance', () {
      bool actionExecuted = false;
      controller.isMaintenance.value = false;

      controller.runAction(() {
        actionExecuted = true;
      });

      expect(actionExecuted, true);
      verifyNever(() => mockUI.showSnackbar(any(), any()));
    });

    test('should show snackbar and not execute action if in maintenance', () {
      bool actionExecuted = false;
      controller.isMaintenance.value = true;

      controller.runAction(() {
        actionExecuted = true;
      });

      expect(actionExecuted, false);
      verify(() => mockUI.showSnackbar(any(), any())).called(1);
    });
  });

  group('MyQuranController - Navigation', () {
    test('should navigate to HOME if logged in', () async {
      SharedPreferences.setMockInitialValues({
        "isLoggedIn": true,
        "email": "test@example.com"
      });

      await controller.appbarNavigate();

      verify(() => mockUI.navigateToHome()).called(1);
    });

    test('should navigate to LOGIN if not logged in', () async {
      SharedPreferences.setMockInitialValues({
        "isLoggedIn": false
      });

      await controller.appbarNavigate();

      verify(() => mockUI.navigateToLogin()).called(1);
    });
  });
}

// Semantic Commit: test(myquran): add unit tests for loadSettings, runAction, and navigation logic
