import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/services/AlarmService.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/service/JadwalSholatAlarm_service.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart'; // PENTING: Jangan lupa import ini untuk Get.back()

class AlarmRingScreen_view extends StatelessWidget {
  final AlarmSettings alarmSettings;
  final bool coldStartApp;

  final JadwalSholatAlarmService sholatAlarmService = JadwalSholatAlarmService();
  AlarmRingScreen_view({Key? key, required this.alarmSettings, this.coldStartApp = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green_1,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.alarm, size: 80, color: Colors.white),
              const SizedBox(height: 20),

              // PERBAIKAN 1: Akses title via notificationSettings
              Text(
                alarmSettings.notificationSettings.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),

              const SizedBox(height: 10),

              // PERBAIKAN 2: Akses body via notificationSettings
              Text(
                alarmSettings.notificationSettings.body,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),

              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () async {
                  await Alarm.stop(alarmSettings.id);
                  await sholatAlarmService.rescheduleForTomorrow(alarmSettings);
                  if(coldStartApp) {

                    SystemNavigator.pop();
                  }
                  else{
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                ),
                child: const Text("MATIKAN", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}